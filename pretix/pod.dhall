let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:532e110f424ea8a9f960a13b2ca54779ddcac5d5aa531f86d82f41f8f18d7ef1

let image = "pretix/standalone"

let version = "stable"

let name = "pretix"

in kubernetes.PodSpec::{
      , containers =
        [ kubernetes.Container::{
          , name = name
          , image = Some "${image}:${version}"
          , imagePullPolicy = Some "Always"
          , ports = Some [ kubernetes.ContainerPort::{ containerPort = +80 } ]
          , resources = Some
              { limits = Some (toMap { cpu = "2", memory = "6Gi" })
              , requests = Some (toMap { cpu = "10m", memory = "2Gi" })
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
