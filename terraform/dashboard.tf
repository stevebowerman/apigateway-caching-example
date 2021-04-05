resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = aws_api_gateway_rest_api.example.name

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Count",
        "metrics": [
            ["AWS/ApiGateway","Count","ApiName","cache-test-api","Stage","dev","Resource","/test","Method","GET"],
            [".",".",".",".",".",".",".","/test/{id}",".","GET"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-west-1"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "CacheHitCount",
        "metrics": [
            ["AWS/ApiGateway","CacheHitCount","ApiName","cache-test-api","Stage","dev","Resource","/test","Method","GET"],
            [".",".",".",".",".",".",".","/test/{id}",".","GET"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-west-1"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "CacheMissCount",
        "metrics": [
            ["AWS/ApiGateway","CacheMissCount","ApiName","cache-test-api","Stage","dev","Resource","/test","Method","GET"],
            [".",".",".",".",".",".",".","/test/{id}",".","GET"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-west-1"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "Latency",
        "metrics": [
            ["AWS/ApiGateway","Latency","ApiName","cache-test-api","Stage","dev","Resource","/test","Method","GET"],
            [".",".",".",".",".",".",".","/test/{id}",".","GET"]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-west-1"
      }
    }
  ]
}
EOF
}