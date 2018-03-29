DEFAULT: build

PROGVER = $(shell grep 'const progversion = ' main.go | awk '{print $$4}' | sed -e 's/\"//g')

build:
	go build -o ${GOPATH}/bin/trickster -v github.com/comcast/trickster
	
helm-local:
	kubectl config use-context minikube --namespace=trickster
	kubectl scale --replicas=0 deployment/dev-trickster -n trickster
	eval $$(minikube docker-env) \
		&& docker build -f deploy/Dockerfile -t trickster:dev .
	kubectl set image deployment/dev-trickster trickster=trickster:dev -n trickster
	kubectl scale --replicas=1 deployment/dev-trickster -n trickster

kube-local:
	kubectl config use-context minikube
	kubectl scale --replicas=0 deployment/trickster
	eval $$(minikube docker-env) \
		&& docker build -f deploy/Dockerfile -t trickster:dev .
	kubectl set image deployment/trickster trickster=trickster:dev
    kubectl scale --replicas=1 deployment/trickster

docker:
	docker build -f ./deploy/Dockerfile -t trickster:$(PROGVER) .
	
docker-release:
	docker tag trickster:$(PROGVER) hub.docker.com/tricksterio/trickster:$(PROGVER)
	docker push hub.docker.com/tricksterio/trickster:$(PROGVER)

clean:
	rm ${GOPATH}/bin/trickster

.PHONY: build helm-local kube-local docker docker-release clean
