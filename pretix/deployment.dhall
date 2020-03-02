-- TODO fix weird ass storage
-- TODO test email with SES, or define new SMTP provider

let name = "pretix"

let image = "krav/pretix"

let version = "a14c373315932e8113c2d08a593f25976862ab6c"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:d9eac5668d5ed9cb3364c0a39721d4694e4247dad16d8a82827e4619ee1d6188

in  kubernetes.Deployment::{
    , metadata = kubernetes.ObjectMeta::{ name = name }
    , spec = Some kubernetes.DeploymentSpec::{
      , replicas = Some 0
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
                [ kubernetes.ContainerPort::{ containerPort = 80 } ]
              , resources = Some
                  { limits = Some (toMap { cpu = "2", memory = "4Gi" })
                  , requests = Some (toMap { cpu = "10m", memory = "1Gi" })
                  }
              , volumeMounts = Some
                [ kubernetes.VolumeMount::{
                  , name = "etc-pretix"
                  , mountPath = "/etc/pretix"
                  , readOnly = Some True
                  }
                , kubernetes.VolumeMount::{ name = "data", mountPath = "/data" }
                ]
              }
            ]
          , volumes = Some
            [ kubernetes.Volume::{
              , name = "etc-pretix"
              , secret = Some kubernetes.SecretVolumeSource::{
                , secretName = Some "pretix"
                }
              }
            , kubernetes.Volume::{
              , name = "data"
              , persistentVolumeClaim = Some kubernetes.PersistentVolumeClaimVolumeSource::{
                , claimName = "pretix-data"
                }
              }
            ]
          }
        }
      }
    }
