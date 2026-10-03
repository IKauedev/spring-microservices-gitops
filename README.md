# spring-microservices-gitops

Configuração declarativa (GitOps) das aplicações de
[spring-microservices-docker-kubernetes](https://github.com/IKauedev/spring-microservices-docker-kubernetes),
sincronizada no cluster pelo [Argo CD](https://argo-cd.readthedocs.io/).

```
k8s/
  base/                     # manifestos comuns (kustomize), uma pasta por app
    platform/ mongodb/ employee/ department/ organization/ gateway/
  overlays/
    dev/<app>/              # referencia a base (HPA 1 a 3)
    prod/<app>/             # base + patches (HPA 2 a 5)
argocd/
  root-app.yaml             # app of apps: sincroniza argocd/appsets
  appsets/applications.yaml # ApplicationSet: uma Application por ambiente x app
```

## Fonte única

Este repositório é a **única fonte da configuração do cluster** (manifestos Kubernetes e
Applications do Argo CD). O repositório das aplicações contém só o código e os scripts; ele
clona este repositório quando precisa dos manifestos. Mudou um manifesto? Edite e dê push
aqui: o Argo CD sincroniza a `master` sozinho.

## Como ativar

Com o Argo CD instalado no cluster:

```bash
kubectl apply -n argocd -f argocd/root-app.yaml
```

O `root` aplica o `ApplicationSet`, que gera as Applications `<app>-<env>`
(`platform-dev`, `mongodb-dev`, `department-dev`, ...). Cada uma sincroniza
`k8s/overlays/<env>/<app>` da `master` com `automated`, `prune` e `selfHeal`.
Alterações feitas à mão no cluster são desfeitas: mude os manifestos aqui, pelo Git.
Apagar o ApplicationSet ou uma Application **não** apaga os recursos do cluster
(`preserveResourcesOnDeletion`).

## Vários clusters / ambientes

1. Registre o cluster no Argo: `argocd cluster add <contexto-kubectl>` (anote a URL do API server).
2. Em `argocd/appsets/applications.yaml`, descomente/adicione o ambiente na lista, por exemplo
   `{env: prod, server: https://<api-do-cluster>}`.
3. Garanta que `k8s/overlays/<env>/<app>` exista. O `prod` já existe (HPA 2 a 5);
   para um ambiente novo, copie uma pasta de `overlays/` e ajuste os patches.
4. Commit e push: o Argo cria as Applications do novo ambiente.

Para validar localmente: `kubectl kustomize k8s/overlays/<env>/<app>`.

## Notas

- As imagens `vmware/<app>:1.1` são construídas dentro do Docker do Minikube
  (`scripts/deploy/build-app.sh` no repositório das aplicações); o Argo não faz build.
- Os HPAs estão em 1 a 3 réplicas no `dev` (local) e 2 a 5 no `prod`.
- Os Secrets contêm apenas credenciais de desenvolvimento (Mongo local). Para uso real,
  troque por Sealed Secrets, External Secrets ou SOPS.
