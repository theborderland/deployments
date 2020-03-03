# Kubernetes deployments for the Borderland community

## Requirements

  * `azure-cli` for setting up AKS kubectl credentials
  * `kubectl` for accessing Kubernetes
  * `dhall-json` for compiling the templates

## Accessing our cluster

```bash
# az login
# az aks get-credentials --resource-group rg-kubernetes-prod --name k8s-main-prod
```

## Example usage

### Updating the Limesurvey version

The directory `limesurvey/` contains `default.dhall` which is a convenience for creating a multi-document yaml-file containing both deployment and service. 

Check Docker Hub for the latest version, and update the `version` variable in `deployment.dhall` to point to the latest one. Make sure not to select builds tagged `fpm`, as they do not contain a web server.

Compile and deploy the template by running `make`.

## Ingress

Ingress is managed by `ingress-nginx`, with `cert-manager` getting Let's Encrypt certificates.

To add a new service update `ingress-nginx/ingress.dhall` and add your service name and DNS endpoint to the `services` list, e.g.:

```dhall
...
let services = [ { name = "survey", host = "survey.theborderland.se" } 
               , { name = "my_service", host = "my_service.theborderland.se" }
               , ...
               ]
...
```

and then update the Ingress object by running `make`.

Make essentially does `dhall-to-yaml < ingress.dhall | kubectl apply -f -`.

