
#!/bin/bash
aws eks update-kubeconfig --name brain-tasks-cluster --region us-east-1
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
