all:
	make -C redis
	make -C limesurvey
	make -C pretix
	make -C ingress-nginx
