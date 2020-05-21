# Manual steps

## Setup the Flux GitOps SSH key

```bash
ssh-keygen -f flux -t rsa -b 4096 -C 'Flux SSH Key'
KVNAME="$(tf output -json keyvault | jq -r .name)"
az keyvault secret set --name 'flux-git-deploy' --vault-name "${KVNAME}" --description 'Flux GitOps SSH Key' --encoding ascii --file flux --tags k8s_secret_name=flux-git-deploy k8s_secret_key=identity k8s_namespaces=kube-system
```

