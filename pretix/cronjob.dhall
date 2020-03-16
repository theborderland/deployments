let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:d9eac5668d5ed9cb3364c0a39721d4694e4247dad16d8a82827e4619ee1d6188

let name = "pretix-cron"

let pod = ./pod.dhall
let image = "krav/pretix"

let version = "52c6e1edc7cd5f5aecf85a0b4afdfd0057296fc6"

let name = "pretix"


in  kubernetes.CronJob::{
    , metadata = kubernetes.ObjectMeta::{ name = name }
    , spec = Some kubernetes.CronJobSpec::{
      , jobTemplate = kubernetes.JobTemplateSpec::{
        , metadata = kubernetes.ObjectMeta::{ name = name }
        , spec = Some kubernetes.JobSpec::{
          , template = kubernetes.PodTemplateSpec::{
            , metadata = kubernetes.ObjectMeta::{
              , name = name
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
