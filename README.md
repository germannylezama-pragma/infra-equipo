# infra-equipo

Repo de infraestructura de **otro equipo** (serverless: Lambda + DynamoDB + SQS).

No tiene pipeline propio: **reutiliza** el pipeline central de
[github-actions-benefits](https://github.com/germannylezama-pragma/github-actions-benefits)
con una sola línea en [`.github/workflows/infra.yml`](.github/workflows/infra.yml):

```yaml
uses: germannylezama-pragma/github-actions-benefits/.github/workflows/reusable-infra-scan.yml@main
```

Con eso obtiene Checkov + Trivy + Infracost en paralelo, el Job Summary y el gate, para `dev` y `prod`, cada uno con su presupuesto.

| Referencia | Qué versión del pipeline usa |
|---|---|
| `@main` | la estable |
| `@feature/<rama>` | una versión en prueba, desde otra rama del repo central |
| `@v1` / `@<sha>` | una versión fija |

La infra de [`terraform/`](terraform) tiene errores **a propósito** (IAM con `*`, SQS sin cifrar, DynamoDB sin PITR…) para que el gate se vea bloqueando.

## Configuración (opcional)

| Tipo | Nombre | Para qué |
|---|---|---|
| Secret | `INFRACOST_API_KEY` | Estimar costos (llega al pipeline con `secrets: inherit`) |
| Variable | `ENFORCE_GATE` | `false` para solo reportar sin bloquear |
