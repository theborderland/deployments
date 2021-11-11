let name = "pretix"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:532e110f424ea8a9f960a13b2ca54779ddcac5d5aa531f86d82f41f8f18d7ef1

let targetPort = Some (kubernetes.IntOrString.Int +80)

let spec =
      { selector = Some (toMap { app = name })
      , type = Some "NodePort"
      , ports = Some
        [ kubernetes.ServicePort::{ targetPort = targetPort, port = +80 } ]
      }

let service
    : kubernetes.Service.Type
    = kubernetes.Service::{
      , metadata = kubernetes.ObjectMeta::{
        , name = Some name
        , labels = Some (toMap { app = name })
        }
      , spec = Some kubernetes.ServiceSpec::spec
      }

in  service
