-- TODO uploads directory
-- TODO test email with SES, or define new SMTP provider

let version = "4.1.6_200220-apache"

let name = "survey"

let image = "martialblog/limesurvey"

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

let mkEnv
    : Text → Text → Kubernetes.EnvVar
    =   λ(name : Text)
      → λ(value : Text)
      → kubernetes.EnvVar::{ name = name, value = Some value }

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
                [ kubernetes.ContainerPort::{ containerPort = 80 } ]
              , resources = Some
                  { limits = Some (toMap { cpu = "500m" })
                  , requests = Some (toMap { cpu = "10m" })
                  }
              , env = Some
                [ mkEnv "ADMIN_EMAIL" "kris@microdisko.no"
                , mkEnv "ADMIN_NAME" "kris"
                , mkEnv "ADMIN_USER" "kris"
                , mkEnv
                    "DB_HOST"
                    "borderland-psql-prod.postgres.database.azure.com"
                , mkEnv "DB_NAME" "limesurvey"
                , mkEnv "DB_PORT" "5432"
                , mkEnv "DB_TYPE" "pgsql"
                , mkEnv "DB_USERNAME" "limesurvey@borderland-psql-prod"
                , mkSecretEnv
                    { name = "DB_PASSWORD"
                    , key = "db_password"
                    , secret_name = Some "limesurvey"
                    }
                , mkSecretEnv
                    { name = "ADMIN_PASSWORD"
                    , key = "admin_password"
                    , secret_name = Some "limesurvey"
                    }
                ]
              }
            ]
          }
        }
      }
    }
