# HOWTO

## How to publish chart:

### Prerequisit

In codeBlock below:
1. Replace `YYY` in `USERNAME` by your gitlab account name with at least `maintainer` role in repository `appspec`.
2. Replace `XXX` in `TOKEN` by your gitlab token with `api` scope in repository `appspec`.

Then copy and past text from codeBlock into your terminal.

``` bash
export USERNAME="YYY"
export TOKEN="XXX"
export REPO=""
export PACKAGE_FILE="$(helm package . | awk -F/ '{print $NF}')"
export CHANNEL="dev"
```

### Publish

Execute command below in your terminal. After that the current version of chart will be published into gitlab package-registry `{{ .Values.companyInternalChartRegistry }}appspec/-/packages/`.

``` bash
curl --fail-with-body --request POST \
  --form "chart=@${PACKAGE_FILE}" \
  --user ${USERNAME}:${TOKEN} \
  https://${REGISTRY_URL}
```

## How to use chart

### Prerequisit

In codeBlock below:
1. Replace `YYY` in `USERNAME` by your gitlab account name with at least `guest` role in repository `appspec`.
2. Replace `XXX` in `TOKEN` by your gitlab token with at least `apiRead` scope in repository `appspec`.

Then copy and past text from codeBlock into your terminal.

``` bash
export USERNAME="YYY"
export TOKEN="XXX"
export REPO=""
export REPO_NAME=appSpec
export CHANNEL="dev"
```

### Add helm repository

Execute command below in your terminal. It will add repo name appSpec into your helm.

``` bash
helm repo add \
  --username ${USERNAME} \
  --password ${TOKEN} \
  ${REPO_NAME} \
  https://${REGISTRY_URL}
```

### Pull

Update helm repo:

``` bash
helm repo update
```

Search added repo:

``` bash
helm search repo appSpec versions
```

Output example:

``` text
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                
appSpec/appSpec                 0.1.2           1.16.0          A Helm chart for Kubernetes
appSpec/appSpec                 0.1.1           1.16.0          A Helm chart for Kubernetes
```

Pull repo:

``` bash
helm pull appSpec/appSpec --untar
```
