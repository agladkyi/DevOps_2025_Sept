
.PHONY: start stack build deploy traffic logs grafana prometheus password cleanup

start:
	minikube start --cpus=4 --memory=8192

stack:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	kubectl create namespace monitoring 2>/dev/null || true
	helm upgrade --install mon prometheus-community/kube-prometheus-stack -n monitoring

build:
	@eval $$(minikube -p minikube docker-env) && docker build -t demo-metrics-logs:1.0 ./app

deploy:
	kubectl apply -f k8s/

traffic:
	kubectl -n demo run -it --rm curl --image=curlimages/curl -- sh

logs:
	kubectl logs -n demo deploy/demo-metrics-logs -f

grafana:
	kubectl -n monitoring port-forward svc/mon-grafana 3000:80

prometheus:
	kubectl -n monitoring port-forward svc/mon-kube-prometheus-stack-prometheus 9090:9090

password:
	kubectl get secret -n monitoring mon-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

cleanup:
	helm uninstall mon -n monitoring || true
	kubectl delete ns monitoring demo || true
	minikube delete || true
