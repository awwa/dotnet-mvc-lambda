aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com
docker tag mvcmovie:latest $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest
docker push $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest