data "aws_caller_identity" "current" {}

locals {
  lambda_name = "cache-test-api-lambda"
}

data "template_file" "example" {
  template = file("../api-definitions/openapi.yaml")

  vars = {
    LAMBDA = "arn:aws:lambda:eu-west-1:${data.aws_caller_identity.current.account_id}:function:${local.lambda_name}"
  }
}

resource "aws_api_gateway_rest_api" "example" {
    body = data.template_file.example.rendered

    name = "cache-test-api"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.example.name}"
  retention_in_days = 7
}


resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "dev"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.example.arn
    format = jsonencode(
      {  
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      }
    )
  }

  cache_cluster_enabled = true
  cache_cluster_size    = 0.5
}

resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}


resource "aws_api_gateway_method_settings" "caching" {
  for_each = yamldecode(file("${path.module}/cache.yaml"))

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = each.key

  settings {
    caching_enabled                         = true
    cache_ttl_in_seconds                    = each.value
    require_authorization_for_cache_control = false
  }

}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/*/*"
}


output "endpoint" {
  value = aws_api_gateway_rest_api.example.execution_arn
}
