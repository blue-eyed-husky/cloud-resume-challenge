# Create DynamoDB Table #
resource "aws_dynamodb_table" "resume_visitors" {
  name         = var.visitor_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "ResumeWebsite"
  }
}

# Lambda, IAM role and permissions #
data "aws_iam_policy_document" "visitors_lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "visitors_lambda_role" {
  name               = "resume-visitors-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.visitors_lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.visitors_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy_document" "lambda_ddb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.resume_visitors.arn]
  }
}

resource "aws_iam_role_policy" "lambda_ddb_inline" {
  name   = "resume-visitor-ddb"
  role   = aws_iam_role.visitors_lambda_role.id
  policy = data.aws_iam_policy_document.lambda_ddb.json
}

# Lambda function (python) #
data "archive_file" "visitors_lambda_zip" {
  type = "zip"
  source_file = "${path.module}/lambda/visitors.py"
  output_path = "${path.module}/lambda/visitors.zip"

}

# Deploying lambda to use built zip #

resource "aws_lambda_function" "resume_visitors" {
  function_name = "resume-visitors"
  role          = aws_iam_role.visitors_lambda_role.arn

  runtime = "python3.12"
  handler = "visitors.handler"

  filename         = data.archive_file.visitors_lambda_zip.output_path
  source_code_hash = data.archive_file.visitors_lambda_zip.output_base64sha256

  publish = true

  environment {
    variables = {
      TABLE_NAME   = aws_dynamodb_table.resume_visitors.name
      ALLOW_ORIGIN = "https://${var.domain_name}"
    }
  }

  tags = {
    Project = "ResumeWebsite"
  }
}

# API Gateway API and Route #
resource "aws_apigatewayv2_api" "visitors_api" {
  name          = "resume-visitors-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${var.domain_name}"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["content-type"]
  }

  tags = {
    Project = "ResumeWebsite"
  }
}

resource "aws_apigatewayv2_integration" "visitors_integration" {
  api_id                 = aws_apigatewayv2_api.visitors_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.resume_visitors.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_visitors" {
  api_id    = aws_apigatewayv2_api.visitors_api.id
  route_key = "GET /visitors"
  target    = "integrations/${aws_apigatewayv2_integration.visitors_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.visitors_api.id
  name        = "$default"
  auto_deploy = true
}


resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_visitors.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitors_api.execution_arn}/*/*"
}