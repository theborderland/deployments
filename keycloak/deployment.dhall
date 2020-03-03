let version = "67006f9c3af0936ea9182bbc065c9c28f4464f71"

let name = "keycloak"

let image = "krav/borderland-account"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:d9eac5668d5ed9cb3364c0a39721d4694e4247dad16d8a82827e4619ee1d6188

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{ name = name }
    , spec = Some kubernetes.DeploymentSpec::{
      , replicas = Some 1
      , selector = kubernetes.LabelSelector::{
        , matchLabels = Some (toMap { app = name })
        }
      , strategy = Some kubernetes.DeploymentStrategy::{
        , type = Some "RollingUpdate"
        , rollingUpdate = Some
            { maxSurge = Some (kubernetes.IntOrString.Int 5)
            , maxUnavailable = Some (kubernetes.IntOrString.Int 0)
            }
        }
      , template = kubernetes.PodTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{
          , name = name
          , labels = Some (toMap { app = name })
          }
        , spec = Some kubernetes.PodSpec::{
          , containers =
            [ kubernetes.Container::{
              , name = name
              , image = Some "${image}:${version}"
              , ports = Some
                [ kubernetes.ContainerPort::{ containerPort = 8000 } ]
              , resources = Some
                  { limits = Some (toMap { cpu = "1", memory = "512Mi" })
                  , requests = Some (toMap { cpu = "1m", memory = "64Mi" })
                  }
              }
            ]
          }
        }
      }
    }
