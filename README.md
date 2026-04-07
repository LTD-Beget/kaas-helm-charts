### Lint the chart
```bash
helm lint helm-chart-sources/*
```


### Create the Helm chart package
```bash
for d in helm-chart-sources/*; do
  [ -f "$d/Chart.yaml" ] || continue

  NAME=$(yq -r '.name' "$d/Chart.yaml")
  VERSION=$(yq -r '.version' "$d/Chart.yaml")
  PKG="helm-chart-revisions/${NAME}-${VERSION}.tgz"

  [ -f "$PKG" ] && continue

  helm package "$d" --destination helm-chart-revisions
done

```

### Create the Helm chart repository index
```bash
helm repo index --url https://blog.beget.com/kaas-helm-charts/ .

```

### Push the git repository on GitHub
```bash
git add . && git commit -m "Initial commit" && git push origin main

```

### Helm repo  add/update
```bash
helm repo add wrapper https://blog.beget.com/kaas-helm-charts/
helm repo update wrapper
```

### Helm search  add/update
```bash
helm search repo wrapper
```