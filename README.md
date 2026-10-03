# spring-microservices-gitops

Configuração declarativa (GitOps) das aplicações de
[spring-microservices-docker-kubernetes](https://github.com/IKauedev/spring-microservices-docker-kubernetes),
sincronizada no cluster pelo [Argo CD](https://argo-cd.readthedocs.io/).

```
k8s/        # Kustomize: uma pasta por app + platform (namespaces, RBAC)
  platform/   mongodb/   employee/   department/   organization/   gateway/
argocd/
  root-app.yaml      # app of apps: cria todas as Applications abaixo
  applications/      # uma Application por pasta de k8s/
```

## Como ativar

Com o Argo CD instalado no cluster:

```bash
kubectl apply -n argocd -f argocd/root-app.yaml
```

O `root` cria as Applications (`platform`, `mongodb`, `department`, `employee`,
`organization`, `gateway`) e passa a sincronizar `k8s/<pasta>` da branch `master`
com `automated`, `prune` e `selfHeal`. Alterações no cluster feitas à mão são desfeitas:
mude os manifestos aqui, pelo Git.

## Notas

- As imagens `vmware/<app>:1.1` são construídas dentro do Docker do Minikube
  (`scripts/deploy/build-app.sh` no repositório das aplicações); o Argo não faz build.
- Os HPAs estão em 1 a 3 réplicas para ambiente local.
- Os Secrets contêm apenas credenciais de desenvolvimento (Mongo local). Para uso real,
  troque por Sealed Secrets, External Secrets ou SOPS.
