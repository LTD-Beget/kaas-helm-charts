#!/usr/bin/env python3
"""
AddonValue deep-merge audit vs real chart defaults.

1) Per addon per env (infra/client/system) — merged values
2) Compare merged values with real chart values.yaml
3) Find keys in AddonValue that duplicate chart defaults → removable
"""

import copy
import re
import sys
import tarfile
from pathlib import Path
from collections import defaultdict

import yaml

# ── category mapping ─────────────────────────────────────────────────────────

PHASE_CAT = {
    "default": "base", "immutable": "base",
    "infra": "infra",
    "system": "system", "system-and-initialized": "system",
    "system-trivy": "system", "system-migrated": "system",
    "client": "client", "nocsi": "client", "csi": "client", "disable": "client",
}

ENV_INCLUDES = {
    "infra":  {"base", "infra", "dep"},
    "client": {"base", "client", "dep"},
    "system": {"base", "infra", "dep", "system"},
}

ENVS = ["infra", "client", "system"]


def cat_of(name):
    return PHASE_CAT.get(name, "dep")


# ── helpers ──────────────────────────────────────────────────────────────────

def deep_merge(base, over):
    r = copy.deepcopy(base)
    for k, v in over.items():
        if k in r and isinstance(r[k], dict) and isinstance(v, dict):
            r[k] = deep_merge(r[k], v)
        else:
            r[k] = copy.deepcopy(v)
    return r


def flatten(d, pfx=""):
    if not isinstance(d, dict):
        return {pfx: d} if pfx else {}
    out = {}
    for k, v in d.items():
        key = f"{pfx}.{k}" if pfx else k
        if isinstance(v, dict) and v:
            out.update(flatten(v, key))
        else:
            out[key] = v
    return out


def trunc(v, n=70):
    s = repr(v)
    return s[:n - 3] + "..." if len(s) > n else s


def ydump(d):
    return yaml.dump(d, default_flow_style=False, allow_unicode=True, sort_keys=False)


# ── parse AddonValue ─────────────────────────────────────────────────────────

def parse_avs(files_dir):
    avs = []
    for p in sorted(files_dir.rglob("*.yml")):
        try:
            txt = p.read_text()
        except Exception:
            continue
        for doc in yaml.safe_load_all(txt):
            if not doc or doc.get("kind") != "AddonValue":
                continue
            labels = doc.get("metadata", {}).get("labels", {})
            raw = doc.get("spec", {}).get("values", "")
            parsed = {}
            if raw and isinstance(raw, str) and raw.strip():
                try:
                    parsed = yaml.safe_load(raw) or {}
                except yaml.YAMLError:
                    parsed = {}
            avs.append(dict(
                name=doc.get("metadata", {}).get("name", ""),
                addon=labels.get("addons.in-cloud.io/addon", ""),
                vlabel=labels.get("addons.in-cloud.io/values", ""),
                values=parsed,
                file=str(p),
            ))
    return avs


# ── parse selectors from tpl ─────────────────────────────────────────────────

def clean_helm(txt):
    txt = re.sub(r'\{\{-?\s*define\s+[^}]+\}\}', '', txt)
    txt = re.sub(r'\{\{-?\s*end\s*-?\}\}', '', txt)
    txt = re.sub(r'\{\{-?\s*(?:if|else|range)[^}]*\}\}', '', txt)
    txt = txt.replace('\t', '  ')

    def fix(line):
        if not re.search(r'\{\{[^}]*\}\}', line):
            return line
        line = re.sub(r'\{\{[^}]*\}\}', 'TPL', line)
        s = line.lstrip()
        if ':' in line and not s.startswith('#'):
            k, v = line.split(':', 1)
            v = v.strip()
            if v and v[0] not in ('"', "'"):
                line = k + ': "' + v.replace('"', '\\"') + '"'
        elif s.startswith('- '):
            ind = len(line) - len(s)
            rest = s[2:]
            if rest and rest[0] not in ('"', "'"):
                line = ' ' * ind + '- "' + rest.replace('"', '\\"') + '"'
        return line

    return '\n'.join(fix(l) for l in txt.split('\n'))


def extract_sels(tpl):
    txt = clean_helm(tpl.read_text())
    sels = []
    try:
        for doc in yaml.safe_load_all(txt):
            if not doc or not isinstance(doc, dict):
                continue
            nm = doc.get("metadata", {}).get("name", "")
            if isinstance(nm, str):
                nm = re.sub(r'TPL-?|-?TPL', '', nm).strip().strip('-')

            chart_name = ""
            if doc.get("kind") == "Addon":
                chart_name = doc.get("spec", {}).get("chart", "")
                if isinstance(chart_name, str):
                    chart_name = chart_name.replace('"', '').replace("TPL", "").strip()
                for s in doc.get("spec", {}).get("valuesSelectors", []) or []:
                    sels.append(dict(src="addon", addon=nm, sel=s.get("name", ""),
                                     pri=s.get("priority", 0), ml=s.get("matchLabels", {}),
                                     chart=chart_name))

            if doc.get("kind") == "AddonPhase":
                for rule in doc.get("spec", {}).get("rules", []) or []:
                    s = rule.get("selector", {})
                    if s:
                        ml = s.get("matchLabels", {})
                        a = ml.get("addons.in-cloud.io/addon", nm)
                        sels.append(dict(src="phase", addon=a, sel=s.get("name", ""),
                                         pri=s.get("priority", 0), ml=ml, chart=""))
    except yaml.YAMLError:
        pass
    return sels


def match_av(sel, avs):
    ml = sel["ml"]
    return [a for a in avs
            if all({"addons.in-cloud.io/addon": a["addon"],
                    "addons.in-cloud.io/values": a["vlabel"]}.get(k) == v
                   for k, v in ml.items())]


# ── load chart values.yaml (with subchart deep merge) ────────────────────────

def load_yaml_from_tgz(tgz_path, filename="values.yaml"):
    """Extract a yaml file from a .tgz archive (top-level dir/filename)."""
    try:
        with tarfile.open(tgz_path, "r:gz") as tar:
            for m in tar.getmembers():
                parts = m.name.split("/")
                if len(parts) == 2 and parts[1] == filename:
                    fobj = tar.extractfile(m)
                    if fobj:
                        return yaml.safe_load(fobj.read()) or {}
    except Exception:
        pass
    return None


def load_subchart_defaults(chart_dir, dep_name):
    """Load subchart values.yaml from charts/<dep_name>/ or .tgz."""
    sc_dir = chart_dir / "charts" / dep_name
    if sc_dir.exists() and (sc_dir / "values.yaml").exists():
        with open(sc_dir / "values.yaml") as f:
            return yaml.safe_load(f) or {}

    charts_dir = chart_dir / "charts"
    if not charts_dir.exists():
        return None

    for tgz in sorted(charts_dir.glob("*.tgz")):
        chart_yaml = load_yaml_from_tgz(tgz, "Chart.yaml")
        if chart_yaml and chart_yaml.get("name") == dep_name:
            return load_yaml_from_tgz(tgz, "values.yaml")

    for tgz in sorted(charts_dir.glob("*.tgz")):
        if dep_name in tgz.stem:
            return load_yaml_from_tgz(tgz, "values.yaml")

    return None


def load_chart_values(charts_root, chart_name):
    """Load effective chart values: parent values.yaml merged with subchart defaults.
    Helm puts subchart defaults under parent_values[dep_alias_or_name] with subchart
    defaults as base, overridden by parent block."""
    chart_dir = charts_root / chart_name
    if not chart_dir.exists() or not (chart_dir / "values.yaml").exists():
        for p in sorted(charts_root.rglob(f"{chart_name}*.tgz")):
            vals = load_yaml_from_tgz(p, "values.yaml")
            if vals is not None:
                return vals
        return None

    with open(chart_dir / "values.yaml") as f:
        parent_vals = yaml.safe_load(f) or {}

    chart_yaml_path = chart_dir / "Chart.yaml"
    if not chart_yaml_path.exists():
        return parent_vals

    with open(chart_yaml_path) as f:
        chart_yaml = yaml.safe_load(f) or {}

    deps = chart_yaml.get("dependencies", [])
    if not deps:
        return parent_vals

    effective = copy.deepcopy(parent_vals)

    for dep in deps:
        dep_name = dep.get("name", "")
        dep_alias = dep.get("alias")
        key = dep_alias or dep_name

        sub_defaults = load_subchart_defaults(chart_dir, dep_name)
        if sub_defaults is None:
            continue

        parent_block = effective.get(key, {})
        if not isinstance(parent_block, dict):
            parent_block = {}

        effective[key] = deep_merge(sub_defaults, parent_block)

    return effective


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    root = Path(__file__).resolve().parent.parent
    tpl_dir = root / "helm-chart-sources" / "addonset" / "templates"
    files_dir = root / "helm-chart-sources" / "addonset" / "files"
    charts_root = root / "helm-chart-sources"

    avs = parse_avs(files_dir)

    all_sels = []
    for tpl in sorted(tpl_dir.rglob("*.tpl")):
        if tpl.name.startswith("_") or ("addon" not in tpl.name and "phase" not in tpl.name):
            continue
        all_sels.extend(extract_sels(tpl))

    addons = defaultdict(list)
    addon_chart = {}
    for s in all_sels:
        addons[s["addon"]].append(s)
        if s.get("chart"):
            addon_chart[s["addon"]] = s["chart"]

    out_dir = root / "reports" / "addonvalue-merge"
    out_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 95)
    print("  ADDONVALUE vs CHART DEFAULTS — DEDUP AUDIT")
    print("=" * 95)
    print()

    grand_total_dups = 0
    grand_total_overrides = 0
    summary = []

    for addon_name in sorted(addons.keys()):
        sels = sorted(addons[addon_name], key=lambda s: s["pri"])
        chart_name = addon_chart.get(addon_name, "")

        chart_vals = None
        if chart_name:
            chart_vals = load_chart_values(charts_root, chart_name)
        chart_flat = flatten(chart_vals) if chart_vals else {}

        env_data = {}
        for env in ENVS:
            includes = ENV_INCLUDES[env]
            merged = {}
            layers = []
            layer_details = []

            for s in sels:
                c = cat_of(s["sel"])
                if c not in includes:
                    continue
                for av in match_av(s, avs):
                    if av["values"]:
                        merged = deep_merge(merged, av["values"])
                        layers.append(f"  p={s['pri']:3d}  {s['sel']:28s} [{c:7s}] -> {av['name']}")
                        layer_details.append((s["pri"], s["sel"], c, av))
                    else:
                        layers.append(f"  p={s['pri']:3d}  {s['sel']:28s} [{c:7s}] -> {av['name']} (empty)")

            env_data[env] = dict(merged=merged, layers=layers, layer_details=layer_details)

        has_any = any(env_data[e]["merged"] for e in ENVS)
        if not has_any:
            continue

        # compare merged (infra as reference) with chart defaults
        ref_merged = env_data["infra"]["merged"]
        ref_flat = flatten(ref_merged)

        dups_vs_chart = []
        overrides_vs_chart = []
        addon_only = []
        chart_only_keys = []

        if chart_flat:
            for k, v in sorted(ref_flat.items()):
                if k in chart_flat:
                    if v == chart_flat[k]:
                        dups_vs_chart.append((k, v))
                    else:
                        overrides_vs_chart.append((k, v, chart_flat[k]))
                else:
                    addon_only.append((k, v))
            chart_only_keys = sorted(set(chart_flat) - set(ref_flat))

        # per-layer analysis: which layer introduced the dup
        layer_dups = defaultdict(list)
        if dups_vs_chart:
            dup_keys = {k for k, _ in dups_vs_chart}
            for env in ENVS:
                for pri, sel_name, cat, av in env_data[env]["layer_details"]:
                    av_flat = flatten(av["values"])
                    for k in sorted(dup_keys & set(av_flat)):
                        if av_flat[k] == chart_flat.get(k):
                            layer_dups[(av["name"], sel_name, pri)].append(k)

        # write per-addon file
        fname = out_dir / f"{addon_name}.txt"
        with open(fname, "w") as f:
            f.write(f"{'=' * 80}\n")
            f.write(f"  ADDON: {addon_name}   chart: {chart_name or '(no chart)'}\n")
            f.write(f"{'=' * 80}\n\n")

            for env in ENVS:
                d = env_data[env]
                f.write(f"── {env.upper()} {'─' * 40}\n")
                f.write(f"Layers ({len(d['layers'])}):\n")
                for l in d["layers"]:
                    f.write(l + "\n")
                f.write("\nMerged values:\n")
                if d["merged"]:
                    f.write(ydump(d["merged"]))
                else:
                    f.write("  (empty)\n")
                f.write("\n")

            if chart_flat:
                f.write(f"── vs CHART DEFAULTS ({chart_name}/values.yaml) {'─' * 20}\n")
                f.write(f"  Merged keys:   {len(ref_flat)}\n")
                f.write(f"  Chart keys:    {len(chart_flat)}\n")
                f.write(f"  DUPLICATE (=chart default, removable): {len(dups_vs_chart)}\n")
                f.write(f"  OVERRIDE  (≠chart default, keep):      {len(overrides_vs_chart)}\n")
                f.write(f"  ADDON_ONLY (not in chart defaults):     {len(addon_only)}\n\n")

                if dups_vs_chart:
                    f.write("  DUPLICATES (same as chart default → can remove from AddonValue):\n")
                    for k, v in dups_vs_chart:
                        f.write(f"    DUP  {k}: {trunc(v)}\n")
                    f.write("\n")

                if overrides_vs_chart:
                    f.write("  OVERRIDES (different from chart default → keep in AddonValue):\n")
                    for k, v, cv in overrides_vs_chart:
                        f.write(f"    OVR  {k}\n")
                        f.write(f"         addon:  {trunc(v)}\n")
                        f.write(f"         chart:  {trunc(cv)}\n")
                    f.write("\n")

                if addon_only:
                    f.write("  ADDON_ONLY (key exists only in AddonValue, not in chart defaults):\n")
                    for k, v in addon_only:
                        f.write(f"    NEW  {k}: {trunc(v)}\n")
                    f.write("\n")

                if layer_dups:
                    f.write("  Per-layer source of duplicates:\n")
                    for (av_name, sel_name, pri), keys in sorted(layer_dups.items()):
                        f.write(f"    {av_name} (p={pri}, {sel_name}): {len(keys)} dup key(s)\n")
                        for k in keys:
                            f.write(f"      - {k}\n")
                    f.write("\n")
            else:
                f.write(f"  (chart '{chart_name}' values.yaml not found)\n\n")

        n_dups = len(dups_vs_chart)
        n_ovr = len(overrides_vs_chart)
        grand_total_dups += n_dups
        grand_total_overrides += n_ovr

        status = "CLEAN" if n_dups == 0 else f"{n_dups} DUP"
        summary.append((addon_name, chart_name, len(ref_flat), n_dups, n_ovr, len(addon_only), status))

    # ── console output ───────────────────────────────────────────────────────

    hdr = f"  {'Addon':<35s} {'Chart':<30s} {'Keys':>5s} {'DUP':>5s} {'OVR':>5s} {'NEW':>5s}  Status"
    print(hdr)
    print(f"  {'-'*35} {'-'*30} {'-'*5} {'-'*5} {'-'*5} {'-'*5}  {'-'*10}")
    for addon, chart, keys, dups, ovr, new, status in summary:
        line = f"  {addon:<35s} {chart:<30s} {keys:5d} {dups:5d} {ovr:5d} {new:5d}  {status}"
        print(line)

    print()
    print(f"  Total removable (DUP vs chart defaults): {grand_total_dups}")
    print(f"  Total overrides (keep):                  {grand_total_overrides}")
    print()
    print(f"  Per-addon detail: {out_dir}/")

    # list addons with dups
    with_dups = [(a, d) for a, _, _, d, _, _, _ in summary if d > 0]
    if with_dups:
        print()
        print("  Addons with removable duplicates:")
        for a, d in with_dups:
            print(f"    {a}: {d} key(s)")

    print()
    print("=" * 95)


if __name__ == "__main__":
    main()
