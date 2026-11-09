# Ejemplo para el PR: un topic SNS para alertas.
# Le falta el cifrado a propósito para que el análisis del PR lo detecte
# (arreglo: agregar kms_master_key_id = "alias/aws/sns").
resource "aws_sns_topic" "alertas" {
  name = "equipo-${var.environment}-alertas"
}
