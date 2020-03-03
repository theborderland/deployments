deploy:
	kubectl apply -f pvc.yml
	dhall-to-yaml < default.dhall | kubectl apply -f -

secret:
  [ -f pretix.cfg ]
	kubectl delete secret pretix
	kubectl create secret generic pretix --from-file=pretix.cfg
