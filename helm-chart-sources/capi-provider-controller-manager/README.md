# HOWTO

## Prerequisit

### Add helm repository from dependencies

In codeBlock below:
1. Replace `YYY` in `USERNAME` by your gitlab account name with at least `guest` role in repository `cloud/k8s/appspec`.
2. Replace `XXX` in `TOKEN` by your gitlab token with at least `apiRead` scope in repository `cloud/k8s/appspec`.

Then copy and past text from codeBlock into your terminal.

``` bash
export USERNAME="YYY"
export TOKEN="XXX"
export REPO="cloud%2Fk8s%2Fappspec"
export REPO_NAME=appSpec
export CHANNEL="dev"
```

Execute command below in your terminal. It will add repo name appSpec into your helm.

``` bash
helm repo add \
  --username ${USERNAME} \
  --password ${TOKEN} \
  ${REPO_NAME} \
  https://gitlab.example.ru/api/v4/projects/${REPO}/packages/helm/${CHANNEL}
```

Update helm repos:

``` bash
helm repo update
```

## Using chart

1. Modify `example.values.yaml` or create your own values file with your arguments.
2. Set environment variables `$RELEASE_NAME` and `$RELEASE_NAMESPACE`. Example:

```bash
export RELEASE_NAME=cluster1-ccm
export RELEASE_NAMESPACE=wrapper-system
```

## make template with example

```bash
helm template \
  ${RELEASE_NAME} \
  -n ${RELEASE_NAMESPACE} \
  -f example.values.yaml \
  ./chart \
  > app_new.yaml
```

## make deploy

```bash
helm upgrade \
  --install \
  ${RELEASE_NAME} \
  -n ${RELEASE_NAMESPACE} \
  -f example.values.yaml \
  ./chart
```
