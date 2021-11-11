let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:532e110f424ea8a9f960a13b2ca54779ddcac5d5aa531f86d82f41f8f18d7ef1

let name = "pretix-cron"

let pod = ./pod.dhall
let image = "pretix/standalone"

let version = "stable"

let name = "pretix"


in  kubernetes.CronJob::{
    , metadata = kubernetes.ObjectMeta::{ name = Some name }
    , spec = Some kubernetes.CronJobSpec::{
      , jobTemplate = kubernetes.JobTemplateSpec::{
        , metadata = Some kubernetes.ObjectMeta::{ name = Some name }
        , spec = Some kubernetes.JobSpec::{
          , template = kubernetes.PodTemplateSpec::{
            , metadata = Some kubernetes.ObjectMeta::{
              , name = Some name
              , labels = Some (toMap { app = name })
              }
            , spec = Some
kubernetes.PodSpec::{
restartPolicy = Some "Never"
      , containers =
        [ kubernetes.Container::{
          , name = name
          , image = Some "${image}:${version}"
, command = Some ["pretix"]
, args = Some ["cron"]
          , resources = Some
              { limits = Some (toMap { cpu = "2", memory = "4Gi" })
              , requests = Some (toMap { cpu = "1m", memory = "128Mi" })
              }
          , volumeMounts = Some
            [ kubernetes.VolumeMount::{
              , name = "etc-pretix"
              , mountPath = "/etc/pretix"
              , readOnly = Some True
              }
            , kubernetes.VolumeMount::{
              , name = "data"
              , mountPath = "/data"
              , subPath = Some "pretix"
              }
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
      , schedule = "15,45 * * * *"
      }
    }
