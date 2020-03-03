let Prelude = https://prelude.dhall-lang.org/package.dhall

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall

let map = Prelude.List.map

let Service = { name : Text, host : Text }

let services =
      [ { name = "survey",   host = "survey.theborderland.se" }
      , { name = "pretix",   host = "pretix-new.theborderland.se" }
      , { name = "keycloak", host = "account.theborderland.se" }
      , { name = "pretix",   host = "memberships.theborderland.se" }
      ]

let makeTLS
    : Service → kubernetes.IngressTLS.Type
    =   λ(service : Service)
      → { hosts = Some [ service.host ]
        , secretName = Some "${service.name}-certificate"
        }

let makeRule
    : Service → kubernetes.IngressRule.Type
    =   λ(service : Service)
      → { host = Some service.host
        , http = Some
            { paths =
              [ { backend =
                    { serviceName = service.name
                    , servicePort = kubernetes.IntOrString.Int 80
                    }
                , path = None Text
                }
              ]
            }
        }

let mkIngress
    : List Service → kubernetes.Ingress.Type
    =   λ(inputServices : List Service)
      → let annotations =
              toMap
                { `kubernetes.io/ingress.class` = "nginx"
                , `kubernetes.io/ingress.allow-http` = "false"
                , `cert-manager.io/cluster-issuer` = "letsencrypt"
                }

        let defaultService = { name = "default", host = "aks.theborderland.se" }

        let ingressServices = inputServices # [ defaultService ]

        let spec =
              kubernetes.IngressSpec::{
              , tls = Some
                  ( map
                      Service
                      kubernetes.IngressTLS.Type
                      makeTLS
                      ingressServices
                  )
              , rules = Some
                  ( map
                      Service
                      kubernetes.IngressRule.Type
                      makeRule
                      ingressServices
                  )
              }

        in  kubernetes.Ingress::{
            , metadata = kubernetes.ObjectMeta::{
              , name = "nginx"
              , annotations = Some annotations
              }
            , spec = Some spec
            }

in  mkIngress services
