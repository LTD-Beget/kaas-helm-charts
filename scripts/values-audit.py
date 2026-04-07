#!/usr/bin/env python3
"""
Audit parent values.yaml vs subchart default values.yaml.
Finds duplicate keys that can be removed from the parent chart.
"""

import os
import sys
import tarfile
import io
import yaml
from pathlib import Path


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f) or {}


def load_yaml_from_tgz(tgz_path):
    """Extract values.yaml from a .tgz subchart archive."""
    with tarfile.open(tgz_path, "r:gz") as tar:
        for member in tar.getmembers():
            parts = member.name.split("/")
            if len(parts) == 2 and parts[1] == "values.yaml":
                f = tar.extractfile(member)
                if f:
                    return yaml.safe_load(f.read()) or {}
    return None


def flatten(d, prefix="", sep="."):
    """Flatten a nested dict into {dotted.path: value} for leaf nodes."""
    items = {}
    if not isinstance(d, dict):
        return {prefix: d}
    for k, v in d.items():
        key = f"{prefix}{sep}{k}" if prefix else k
        if isinstance(v, dict) and v:
            items.update(flatten(v, key, sep))
        else:
            items[key] = v
    return items


def get_condition_keys(chart_yaml):
    """Extract condition key paths from Chart.yaml dependencies."""
    keys = set()
    for dep in chart_yaml.get("dependencies", []):
        cond = dep.get("condition", "")
        if cond:
            dep_key = dep.get("alias") or dep.get("name", "")
            if cond.startswith(dep_key + "."):
                relative = cond[len(dep_key) + 1:]
                keys.add(relative)
    return keys


def find_subchart_values(chart_dir, dep_name):
    """Find and load subchart values.yaml from charts/ directory."""
    charts_dir = chart_dir / "charts"
    if not charts_dir.exists():
        return None

    unpacked = charts_dir / dep_name
    if unpacked.exists() and (unpacked / "values.yaml").exists():
        return load_yaml(unpacked / "values.yaml")

    for tgz in sorted(charts_dir.glob("*.tgz")):
        vals = load_yaml_from_tgz(tgz)
        if vals is not None:
            try:
                with tarfile.open(tgz, "r:gz") as tar:
                    for m in tar.getmembers():
                        parts = m.name.split("/")
                        if len(parts) == 2 and parts[1] == "Chart.yaml":
                            f = tar.extractfile(m)
                            if f:
                                sub_chart = yaml.safe_load(f.read()) or {}
                                if sub_chart.get("name") == dep_name:
                                    return vals
            except Exception:
                pass

    for tgz in sorted(charts_dir.glob("*.tgz")):
        if dep_name in tgz.stem:
            vals = load_yaml_from_tgz(tgz)
            if vals is not None:
                return vals

    return None


def audit_chart(chart_dir):
    """Audit a single chart. Returns dict with results or None if no deps."""
    chart_yaml_path = chart_dir / "Chart.yaml"
    values_yaml_path = chart_dir / "values.yaml"

    if not chart_yaml_path.exists() or not values_yaml_path.exists():
        return None

    chart_yaml = load_yaml(chart_yaml_path)
    deps = chart_yaml.get("dependencies", [])
    if not deps:
        return None

    parent_values = load_yaml(values_yaml_path)
    condition_keys = get_condition_keys(chart_yaml)
    results = []

    for dep in deps:
        dep_name = dep.get("name", "")
        dep_alias = dep.get("alias")
        values_key = dep_alias or dep_name

        parent_block = parent_values.get(values_key)
        if parent_block is None:
            results.append({
                "dep": dep_name,
                "alias": dep_alias,
                "values_key": values_key,
                "parent_keys": 0,
                "duplicates": [],
                "overrides": [],
                "parent_only": [],
                "no_parent_block": True,
            })
            continue
        if not isinstance(parent_block, dict):
            results.append({
                "dep": dep_name,
                "alias": dep_alias,
                "values_key": values_key,
                "error": f"parent block is not a dict: {type(parent_block).__name__}",
            })
            continue

        sub_values = find_subchart_values(chart_dir, dep_name)
        if sub_values is None:
            results.append({
                "dep": dep_name,
                "alias": dep_alias,
                "values_key": values_key,
                "error": "subchart values.yaml not found",
            })
            continue

        parent_flat = flatten(parent_block)
        sub_flat = flatten(sub_values)

        duplicates = []
        overrides = []
        parent_only = []

        for key, pval in sorted(parent_flat.items()):
            if key in condition_keys:
                continue

            if key in sub_flat:
                if pval == sub_flat[key]:
                    duplicates.append((key, pval))
                else:
                    overrides.append((key, pval, sub_flat[key]))
            else:
                parent_only.append((key, pval))

        results.append({
            "dep": dep_name,
            "alias": dep_alias,
            "values_key": values_key,
            "parent_keys": len(parent_flat),
            "duplicates": duplicates,
            "overrides": overrides,
            "parent_only": parent_only,
        })

    return results


def truncate(val, maxlen=60):
    s = repr(val)
    if len(s) > maxlen:
        return s[:maxlen - 3] + "..."
    return s


def main():
    repo_root = Path(__file__).resolve().parent.parent
    charts_root = repo_root / "helm-chart-sources"

    if not charts_root.exists():
        print(f"Error: {charts_root} not found", file=sys.stderr)
        sys.exit(1)

    chart_dirs = sorted(
        d for d in charts_root.iterdir()
        if d.is_dir() and (d / "Chart.yaml").exists()
    )

    total_dups = 0
    charts_with_dups = 0
    total_charts = len(chart_dirs)
    charts_with_deps = 0
    charts_no_deps = []
    all_results = []

    for chart_dir in chart_dirs:
        chart_name = chart_dir.name
        results = audit_chart(chart_dir)
        if results is None:
            charts_no_deps.append(chart_name)
            continue

        charts_with_deps += 1
        for r in results:
            if "error" in r:
                all_results.append((chart_name, r))
                continue

            dups = r["duplicates"]
            if dups:
                total_dups += len(dups)
                charts_with_dups += 1

            all_results.append((chart_name, r))

    print("=" * 80)
    print("  VALUES.YAML DEDUP AUDIT REPORT")
    print("=" * 80)
    print()
    print(f"  Total charts: {total_charts}")
    print(f"  With dependencies: {charts_with_deps}")
    print(f"  Without dependencies: {len(charts_no_deps)}")
    print()

    if charts_no_deps:
        print("  Charts without dependencies (nothing to dedup):")
        for name in charts_no_deps:
            print(f"    - {name}")
        print()

    print("-" * 80)
    print("  Charts with dependencies:")
    print("-" * 80)
    print()

    for chart_name, r in all_results:
        if "error" in r:
            print(f"  {chart_name} -> {r['dep']}: ERROR {r['error']}")
            print()
            continue

        dups = r["duplicates"]
        ovr = r["overrides"]
        po = r["parent_only"]
        total = r["parent_keys"]
        no_block = r.get("no_parent_block", False)

        if no_block:
            print(f"  {chart_name} -> {r['values_key']}: NO PARENT BLOCK (nothing to dedup)")
            print()
            continue

        if not dups:
            status = "CLEAN"
        else:
            status = f"{len(dups)} DUPLICATE(S)"

        print(f"  {chart_name} -> {r['values_key']}  [{status}]")
        print(f"    Keys in parent block: {total}")
        print(f"    Duplicates (removable): {len(dups)}")
        print(f"    Overrides (keep):       {len(ovr)}")
        print(f"    Parent-only (keep):     {len(po)}")

        if dups:
            print()
            print("    DUPLICATES (can be removed):")
            for key, val in dups:
                print(f"      - {key}: {truncate(val)}")

        if ovr:
            print()
            print("    OVERRIDES (different from subchart default):")
            for key, pval, sval in ovr:
                print(f"      - {key}: {truncate(pval)}  (subchart: {truncate(sval)})")

        print()

    print("=" * 80)
    print(f"  Total duplicates found: {total_dups}")
    print(f"  Charts with duplicates: {charts_with_dups}")
    print("=" * 80)


if __name__ == "__main__":
    main()
