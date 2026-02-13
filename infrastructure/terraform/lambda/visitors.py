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


    # Use an explicit region to eliminate any possibility of mismatch
    ddb_client = boto3.client("dynamodb", region_name=region)
    ddb_resource = boto3.resource("dynamodb", region_name=region)

    # Print table schema as DynamoDB sees it right now
    try:
        desc = ddb_client.describe_table(TableName=TABLE_NAME)["Table"]
        print("DEBUG_KeySchema:", desc.get("KeySchema"))
        print("DEBUG_AttrDefs:", desc.get("AttributeDefinitions"))
    except ClientError as e:
        print("DEBUG_describe_table_error:", str(e))
        raise

    table = ddb_resource.Table(TABLE_NAME)

    # Atomic increment
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
