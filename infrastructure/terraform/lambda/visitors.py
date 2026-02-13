import os
import json
import boto3
from botocore.exceptions import ClientError

TABLE_NAME = os.environ["TABLE_NAME"]
ALLOW_ORIGIN = os.environ.get("ALLOW_ORIGIN", "*")

def handler(event, context):
    region = os.environ.get("AWS_REGION")
    print("DEBUG_TABLE_NAME:", TABLE_NAME)
    print("DEBUG_AWS_REGION:", region)
    print("DEBUG_VERSION: VISITORS-PY-UPDATED-2026-02-13")

    ddb = boto3.resource("dynamodb", region_name=region)
    table = ddb.Table(TABLE_NAME)

    try:
        resp = table.update_item(
            Key={"id": "home"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW",
        )
    except ClientError as e:
        print("DEBUG_update_item_error:", str(e))
        raise

    count = int(resp["Attributes"]["count"])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOW_ORIGIN,
            "Access-Control-Allow-Methods": "GET,OPTIONS",
        },
        "body": json.dumps({"count": count}),
    }
