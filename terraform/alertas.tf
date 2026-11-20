# Ejemplo para el PR: un topic SNS para alertas.
# Le falta el cifrado a propósito para que el análisis del PR lo detecte (CKV_AWS_26).
# ARREGLO EN VIVO: descomentar la línea kms_master_key_id, commit y push.
resource "aws_sns_topic" "alertas" {
  name = "equipo-${var.environment}-alertas"
  #kms_master_key_id = "alias/aws/sns"
}
