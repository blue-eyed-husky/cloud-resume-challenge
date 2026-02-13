import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async () => {
  const tableName = process.env.TABLE_NAME;
  const origin = process.env.ALLOW_ORIGIN || "*";

  const result = await ddb.send(new UpdateCommand({
    TableName: tableName,
    Key: { id: "home" },
    UpdateExpression: "ADD #count :inc",
    ExpressionAttributeNames: { "#count": "count" },
    ExpressionAttributeValues: { ":inc": 1 },
    ReturnValues: "UPDATED_NEW"
  }));

  const count = result?.Attributes?.count ?? 0;

  return {
    statusCode: 200,
    headers: {
      "content-type": "application/json",
      "access-control-allow-origin": origin,
      "access-control-allow-methods": "GET,OPTIONS"
    },
    body: JSON.stringify({ count })
  };
};
