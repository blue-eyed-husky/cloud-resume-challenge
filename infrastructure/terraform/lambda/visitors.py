import os 
import json
import boto3

ddb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
ALLOW_ORIGIN = os.environ.get("ALLOW_ORIGIN", "*")

def handler(event, context):
    table = ddb.Table(TABLE_NAME)

    resp = table.update_item(
        Key={"ID": "HOME"},
        UpdateExpression="ADD #c :inc",
        ExpressionAttributeNames={"#c": "count"},
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )
    
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