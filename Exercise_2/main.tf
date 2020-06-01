provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/akinnurunoluwafemi/.aws/credentials"
}

# A Lambda function may access to other AWS resources such as S3 bucket. So an
# IAM role needs to be defined. This hello world example does not access to
# any resource, so the role is empty.
#
# The date 2012-10-17 is just the version of the policy language used here [1].
#
# [1]: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_version.html
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = file("iam/lambda-assume-role-policy.json")
}


data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/greet_lambda.py"
    output_path = "script_zip"

}


# Define a Lambda function.
#
# The handler is the name of the executable for python 3.8 runtime.
resource "aws_lambda_function" "greeting_lambda" {
    role             = aws_iam_role.iam_for_lambda.arn
    filename         = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    function_name    = var.lambda_function_name
    handler          = "${var.lambda_function_name}.lambda_handler"
    runtime          = "python3.8"

  environment {
    variables = {
      greeting = "Hello !!! "
    }
  }

  tags = {
        Name = "Greeting Lambda"
  }

    depends_on = [aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.lambda_log_group]

}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days
}


resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = file("iam/lambda-logging-policy.json")

}



resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}