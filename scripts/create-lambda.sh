aws lambda create-function \
  --function-name mvcmovie \
  --package-type Image \
  --code ImageUri=$ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest \
  --role arn:aws:iam::$ACCOUNT_ID:role/lambda-ex