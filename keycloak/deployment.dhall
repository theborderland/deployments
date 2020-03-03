let version = "67006f9c3af0936ea9182bbc065c9c28f4464f71"

let name = "keycloak"

let image = "krav/borderland-account"

let kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall sha256:d9eac5668d5ed9cb3364c0a39721d4694e4247dad16d8a82827e4619ee1d6188

let Kubernetes =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/types.dhall sha256:8882248ebc120a6b891d7a353f7040f6a36ddd6bd99081e39e112f52f1eafd55

let SecretEnv = { name : Text, key : Text, secret_name : Optional Text }

let mkSecretEnv
    : SecretEnv → Kubernetes.EnvVar
    =   λ(secret : SecretEnv)
      → kubernetes.EnvVar::{
        , name = secret.name
        , valueFrom = Some kubernetes.EnvVarSource::{
          , secretKeyRef = Some kubernetes.SecretKeySelector::{
            , key = secret.key
            , name = secret.secret_name
            }
          }
        }

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
                [ kubernetes.ContainerPort::{ containerPort = 8080 } ]
              , resources = Some
                  { limits = Some (toMap { cpu = "500m", memory = "1G" })
                  , requests = Some (toMap { cpu = "64m", memory = "256Mi" })
                  }
              , env = Some
                [ kubernetes.EnvVar::{ name = "DB_ADDR", value = Some "borderland-psql-prod.postgres.database.azure.com" }
                , kubernetes.EnvVar::{ name = "DB_USER", value = Some "keycloak@borderland-psql-prod" }
                , kubernetes.EnvVar::{ name = "DB_VENDOR", value = Some "postgres" }
                , kubernetes.EnvVar::{ name = "PROXY_ADDRESS_FORWARDING", value = Some "true" }
                , kubernetes.EnvVar::{ name = "KEYCLOAK_USER", value = Some "krav" }
                , mkSecretEnv
                    { name = "DB_PASSWORD"
                    , key = "db_password"
                    , secret_name = Some "keycloak"
                    }
                , mkSecretEnv
                    { name = "KEYCLOAK_PASSWORD"
                    , key = "keycloak_password"
                    , secret_name = Some "keycloak"
                    }
                ]
              }
            ]
          }
        }
      }
    }
