# Exercise 7.2 — Multi-Env Layout and GitHub Environment Promotion

Pipeline de Terraform CD que reporta cada paso de validación de forma individual en
los pull requests, sube el plan como artefacto y promueve de `dev` a `staging`
detrás de una aprobación de reviewer requerido.

## Estructura

```
.github/
└── workflows/
    └── terraform-cd.yml   ← 5 jobs (fmt, validate, plan, apply-dev, apply-staging)
infra/
├── provider.tf
├── main.tf
├── variables.tf
└── envs/
    ├── dev/
    │   ├── dev.tfvars
    │   └── backend-dev.hcl       ← editar bucket
    └── staging/
        ├── staging.tfvars
        └── backend-staging.hcl   ← editar bucket
evidence/
└── pr-url.txt
```

## Jobs del workflow

| Job                  | Trigger        | Descripción                                                        |
| -------------------- | -------------- | ------------------------------------------------------------------ |
| `terraform-fmt`      | push + PR      | `terraform fmt -check` (sin init)                                  |
| `terraform-validate` | push + PR      | `terraform init -backend=false` + `terraform validate`            |
| `terraform-plan`     | push + PR      | init con backend, `plan -out=tfplan`, artefacto `tfplan-dev`, comentario en el PR |
| `apply-dev`          | push a `main`  | descarga `tfplan-dev` y `terraform apply tfplan` (env `dev`)       |
| `apply-staging`      | push a `main`  | `needs: apply-dev`, env `staging` (requiere aprobación manual)     |

## Configuración requerida en GitHub (manual)

1. **Settings → Secrets and variables → Actions** — añadir:
   `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`.
2. **Settings → Environments**:
   - `dev` — sin reglas de protección.
   - `staging` — habilitar *Required reviewers* y añadirte como reviewer.
3. Crear un bucket de S3 para el estado y reemplazar `YOUR_BUCKET_NAME` en los dos
   archivos `backend-*.hcl`.

## Verificación

1. Crea una rama, haz un cambio trivial (ej. un comentario en `main.tf`) y abre un PR a `main`.
2. Confirma los tres status checks individuales: `terraform-fmt`, `terraform-validate`, `terraform-plan`.
3. Confirma el comentario del plan en el PR.
4. Haz merge → `apply-dev` corre automáticamente; `apply-staging` se pausa esperando aprobación.
5. Aprueba el deploy de staging y confirma que termina.
6. Guarda la URL del PR en `evidence/pr-url.txt`.
