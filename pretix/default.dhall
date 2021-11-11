let k8s =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/typesUnion.dhall 

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ k8s.Deployment ./deployment.dhall
      , k8s.Service ./service.dhall
      , k8s.CronJob ./cronjob.dhall
      ]
    }
