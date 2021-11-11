-- TODO test email with SES, or define new SMTP provider

let name = "pretix"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:532e110f424ea8a9f960a13b2ca54779ddcac5d5aa531f86d82f41f8f18d7ef1

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{ name = Some name }
    , spec = Some kubernetes.DeploymentSpec::{
      , replicas = Some +1
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some (toMap { app = name })
        }
      , strategy = Some kubernetes.DeploymentStrategy::{
        , type = Some "RollingUpdate"
        , rollingUpdate = Some
            { maxSurge = Some (kubernetes.IntOrString.Int +5)
            , maxUnavailable = Some (kubernetes.IntOrString.Int +0)
            }
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = Some kubernetes.ObjectMeta::{
          , name = Some name
          , labels = Some (toMap { app = name })
          }
        , spec = Some ./pod.dhall
        }
      }
    }
