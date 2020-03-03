let name = "keycloak"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:d9eac5668d5ed9cb3364c0a39721d4694e4247dad16d8a82827e4619ee1d6188

let targetPort = Some (kubernetes.IntOrString.Int 8080)

let spec =
      { selector = Some (toMap { app = name })
      , type = Some "NodePort"
      , ports = Some
        [ kubernetes.ServicePort::{ targetPort = targetPort, port = 80 } ]
      }

let service
    : kubernetes.Service.Type
    = kubernetes.Service::{
      , metadata = kubernetes.ObjectMeta::{
        , name = name
        , labels = Some (toMap { app = name })
        }
      , spec = Some kubernetes.ServiceSpec::spec
      }

in  service
