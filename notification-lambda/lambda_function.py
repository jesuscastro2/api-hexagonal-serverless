
import ast
import json
import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ses = boto3.client("ses", region_name="us-east-1")
FROM_EMAIL = os.environ.get("FROM_EMAIL")


def parse_notification(record):
    body = json.loads(record["body"])

    # SNS normalmente envuelve el mensaje en la propiedad Message.
    if isinstance(body, dict) and "Message" in body:
        payload = body["Message"]
    else:
        payload = body

    if isinstance(payload, str):
        try:
            notification = json.loads(payload)
        except json.JSONDecodeError:
            # Permite diagnosticar mensajes publicados con comillas simples.
            notification = ast.literal_eval(payload)
    else:
        notification = payload

    if not isinstance(notification, dict):
        raise ValueError("El mensaje debe ser un objeto.")

    for field in ("email", "subject", "message"):
        if not isinstance(notification.get(field), str):
            raise ValueError(f"Falta el campo válido: {field}")
        if not notification[field].strip():
            raise ValueError(f"El campo {field} está vacío.")

    return notification


def lambda_handler(event, context):
    logger.info(
        "Notification Lambda iniciada. Registros: %s",
        len(event.get("Records", [])),
    )

    failures = []

    for record in event.get("Records", []):
        message_id = record.get("messageId", "unknown")

        try:
            notification = parse_notification(record)

            if not FROM_EMAIL:
                raise ValueError("Falta configurar FROM_EMAIL.")

            response = ses.send_email(
                Source=FROM_EMAIL,
                Destination={
                    "ToAddresses": [notification["email"]]
                },
                Message={
                    "Subject": {
                        "Data": notification["subject"],
                        "Charset": "UTF-8",
                    },
                    "Body": {
                        "Text": {
                            "Data": notification["message"],
                            "Charset": "UTF-8",
                        }
                    },
                },
            )

            logger.info(
                "SES aceptó el correo. SQS messageId=%s, SES MessageId=%s",
                message_id,
                response.get("MessageId"),
            )

        except (ValueError, KeyError, TypeError, SyntaxError,
                json.JSONDecodeError) as exc:
            logger.exception("Mensaje inválido: %s", message_id)
            failures.append({"itemIdentifier": message_id})

        except ClientError:
            logger.exception(
                "Error de AWS al enviar correo: %s", message_id
            )
            failures.append({"itemIdentifier": message_id})

        except Exception:
            logger.exception(
                "Error inesperado al procesar: %s", message_id
            )
            failures.append({"itemIdentifier": message_id})

    return {"batchItemFailures": failures}
