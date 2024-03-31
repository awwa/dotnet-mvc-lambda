# dotnet-mvc-lambda

このリポジトリは、.NET Core MVC アプリケーションを AWS Lambda 上で動作させるためのサンプルアプリケーションです。
AWS Lambda 上で動作させるために Lambda Web Adapter を利用しています。

## 前提条件

- AWS アカウント
- .NET Core 8 SDK
- AWS CLI

## アプリケーションのビルド

```bash
git clone https://github.com/awwa/dotnet-mvc-lambda.git
cd dotnet-mvc-lambda
dotnet build
```

## ECR リポジトリの作成

ECR にログイン後、リポジトリを作成します。

```bash
export ACCOUNT_ID=xxxxxxxxxxxxx
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr create-repository --repository-name mvcmovie --region ap-northeast-1 --image-scanning-configuration scanOnPush=true
```

## Docker イメージのビルド

Docker イメージをビルドします。

```bash
docker build -f ./Dockerfile -t mvcmovie:latest .
```

## ローカルでの動作確認

Docker イメージをローカルで実行して動作確認します。
以下のコマンド実行後、ブラウザで `http://localhost:8080` にアクセスします。
それっぽい画面が表示されれば成功です。
プロセスを停止するには `Ctrl + C` を押します。

```bash
docker run -p 8080:8080 mvcmovie:latest
```

## ECR へプッシュ

ローカル環境でビルドした Docker イメージを ECR にプッシュします。

```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com
docker tag mvcmovie:latest $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest
docker push $ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest
```

## Lambda 関数用の IAM ロールの作成

Lambda 関数用の IAM ロールを作成します。この IAM ロールには、Lambda 関数が他の AWS サービスを呼び出すための権限が付与されます。

```bash
aws iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
```

## Lambda 関数の作成

AWS Lambda に関数を作成します。

```bash
aws lambda create-function \
  --function-name mvcmovie \
  --package-type Image \
  --code ImageUri=$ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/mvcmovie:latest \
  --role arn:aws:iam::$ACCOUNT_ID:role/lambda-ex
```

## Lambda 関数 URL の追加

Lambda 関数 URL を使用して動作確認するため関数 URL を作成します。
今回は認証なしでアクセスできるように設定します。

```bash
aws lambda add-permission \
  --function-name mvcmovie \
  --action lambda:InvokeFunctionUrl \
  --principal "*" \
  --function-url-auth-type "NONE" \
  --statement-id url
aws lambda create-function-url-config \
  --function-name mvcmovie \
  --auth-type NONE
```

成功すると、以下のようなレスポンスが返されます。ブラウザを開いて`FunctionURL`の URL にアクセスしてください。
それっぽい画面が表示されたら成功です。

```json
{
  "FunctionUrl": "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/",
  "FunctionArn": "arn:aws:lambda:ap-northeast-1:xxxxxxxxxxx:function:mvcmovie",
  "AuthType": "NONE",
  "CreationTime": "2024-03-31T13:11:24.319546Z"
}
```

## 後片付け

AWS コンソールから作成したリソースを削除してください。

- Lambda 関数
- ECR リポジトリ
- IAM ロール
