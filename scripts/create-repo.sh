aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr create-repository --repository-name mvcmovie --region ap-northeast-1 --image-scanning-configuration scanOnPush=true --image-tag-mutability IMMUTABLE
