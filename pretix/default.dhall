let k8s =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/typesUnion.dhall sha256:61d9d79f8de701e9442a796f35cf1761a33c9d60e0dadb09f882c9eb60978323

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ k8s.Deployment ./deployment.dhall
      , k8s.Service ./service.dhall
      , k8s.CronJob ./cronjob.dhall
      ]
    }
