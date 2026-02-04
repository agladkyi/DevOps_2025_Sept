# Install Prometheus + Grafana
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install mon prometheus-community/kube-prometheus-stack -n monitoring

kubectl get pods -n monitoring
```

# Open Prometheus + Grafana UIs

```
kubectl -n monitoring port-forward svc/mon-kube-prometheus-stack-prometheus 9090:9090
```
http://localhost:9090

```
kubectl -n monitoring port-forward svc/mon-grafana 3001:80
```
Open: http://localhost:3001

Get Grafana password (username is admin).  
```
kubectl get secret -n monitoring mon-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```

# Build the app

eval $(minikube -p minikube docker-env)
docker build -t demo-metrics-logs:1.0 ./app
docker images | head

# Generate traffic

```
kubectl -n demo run -it --rm curl --image=curlimages/curl -- sh

# inside the pod:
while true; do
  curl -s http://demo-metrics-logs:8080/ > /dev/null
  curl -s "http://demo-metrics-logs:8080/work?ms=200" > /dev/null
  curl -s http://demo-metrics-logs:8080/fail > /dev/null
  sleep 1
done
```

view logs: `kubectl logs -n demo deploy/demo-metrics-logs -f`

Expose the app:
```
kubectl -n demo port-forward svc/demo-metrics-logs 8080:8080
```

In another terminal:
```
curl -s http://localhost:8080/ >/dev/null
curl -s http://localhost:8080/work?ms=200 >/dev/null
curl -s http://localhost:8080/fail >/dev/null

curl -s http://localhost:8080/metrics | grep -E '^http_requests_total'
```

# Run queries in Prometheus
Prometheus queries to try (Prometheus UI → Graph)

Request rate (per path):

sum(rate(http_requests_total[1m])) by (path)


500 rate:

sum(rate(http_requests_total{status=~"5.."}[1m])) by (path)


Latency p95 for /work:

histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{path="/work"}[5m])) by (le))