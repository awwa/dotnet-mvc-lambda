aws lambda update-function-code \
  --function-name mvcmovie \
  --image-uri $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest \