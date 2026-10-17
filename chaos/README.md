# Chaos engineering (opcional)

Usa o [Chaos Mesh](https://chaos-mesh.org). Fica **fora** do GitOps (o ArgoCD so le `k8s/overlays/...`),
entao nada daqui e aplicado sozinho e os servicos nao sao alterados.

## Pre-requisitos
`minikube` rodando, `kubectl` e `helm`.

## Ligar
```powershell
.\chaos\chaos-on.ps1              # instala o Chaos Mesh
.\chaos\chaos-on.ps1 -Dashboard   # instala e abre o dashboard em http://localhost:2333
.\chaos\chaos-on.ps1 -Runtime containerd   # se o minikube usa containerd
```

## Rodar um experimento
```powershell
kubectl apply -f .\chaos\experiments\pod-kill-employee.yaml
kubectl get pods -n employee -w          # observe o pod ser recriado
kubectl delete -f .\chaos\experiments\pod-kill-employee.yaml   # para o experimento
```

| Arquivo | O que faz |
|---|---|
| `pod-kill-{employee,department,organization,gateway}.yaml` | mata um pod do servico |
| `network-delay-employee.yaml` | 500ms (+-100ms) de latencia por 2 min |
| `cpu-stress-employee.yaml` | 80% de CPU em 2 workers por 3 min |

Os selectors usam `namespace` + label `app: <servico>` dos Rollouts. Para testar outro servico,
copie um arquivo e troque o namespace e o label.

## Desligar
```powershell
.\chaos\chaos-off.ps1   # remove experimentos, Chaos Mesh, namespace e CRDs
```

## Observacoes
- `pod-kill` so mostra resiliencia real com mais de 1 replica (veja os HPAs no overlay `prod`).
- O MongoDB nao tem experimento pronto de proposito: derrubar o banco pode causar perda de dados.
