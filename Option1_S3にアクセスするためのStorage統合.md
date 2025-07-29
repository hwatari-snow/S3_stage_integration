# 記事の概要


**内容**
ストレージ統合を使用して、**Snowflakeが外部（S3）** ステージで参照されるAmazon S3バケットに対してデータの読み取りと書き込みを行う方法について説明します。

**ポイント**
- ストレージ統合は名前付きのファーストクラスSnowflakeオブジェクト
- これによりシークレットキーやアクセストークンの認証情報を渡す必要なし
- ストレージ統合オブジェクトには、AWS Identity and Access Management（IAM）ユーザーIDが格納

>参考にした[リンク](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration)

**統合のフロー**
![サンプル](storage-integration-s3.png "サンプル")
1. 外部ステージは認証のためにStorage統合オブジェクトを参照する
2. SnowflakeはS3バケットに参照するためのIAMユーザの作成を行う
3. AWSの管理者は、IAMユーザーにステージで定義されるバケットへのアクセス権を付与する

---

## Cloud Storageへの安全なアクセスを構成する

このセクションでは実際に私の画面を通じて上の流れの実装を行なってみる

---

### ステップ1: S3バケットのアクセス権限の設定

#### AWSアクセス制御要件
Snowflake では、フォルダー (およびサブフォルダー) 内のファイルにアクセスできるようにするために、S3 バケットとフォルダーに対する次の権限が必要です。

- `s3:GetBucketLocation`
- `s3:GetObject`
- `s3:GetObjectVersion`
- `s3:ListBucket`
`
※追加の SQL アクションを実行するには、次の追加の権限が必要です。

| 許可                | SQLアクション                                                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `s3:PutObject`    | バケットにファイルをアンロードします。                                                                                                       |
| `s3:DeleteObject` | ロードが成功した後、ステージからファイルを自動的に削除するか、[REMOVE](https://docs.snowflake.com/en/sql-reference/sql/remove)ステートメントを実行してファイルを手動で削除します。 |


#### IAMポリシー作成
SnowflakeからS3 バケットを使用してデータをロードおよびアンロードできるように、AWSのIAMポリシーの作成において、以下のIAMポリシーを作成。

- ポリシー名： `Snowflake_access_Capstone-hwatari-policy`
- Jsonファイル：↓
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ],
            "Resource": ["arn:aws:s3:::<capstone-hwatari>/<kapa-0001>/*",
            "arn:aws:s3:::<capstone-hwatari>/<kbfi-0001>/*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::<capstone-hwatari>",
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "<capstone-hwatari>/*"
                    ]
                }
            }
        }
    ]
}
```


### ステップ２：AWSでIAMロールの作成

作成したポリシーをアタッチするためのAWSのロールの作成を行う。
作成方法に関しては[ドキュメント](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration)を参照、作成結果は下記の通り。
- ロール名：`snowflakerole_capstone_hwatari`
- 概要：↓

![](role.png)


### ステップ3：Snowflakeでクラウドストレージ統合を作成

[CREATE STORAGE INTEGRATION](https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration)コマンドを使用してストレージ統合を作成する。ストレージ統合とは、S3クラウドストレージ用に生成されたIdentity and Access Management (IAM) ユーザーと、オプションで許可またはブロックされたストレージ場所（バケット）のセットを格納するSnowflakeオブジェクトである。**ユーザーはステージの作成時やデータのロード時に認証情報を入力する必要がなくなる。**

単一のストレージ統合で複数の外部ステージ（つまりS3ステージ）をサポートできます。ステージ定義のURLは、STORAGE_ALLOWED_LOCATIONSパラメータに指定されたS3バケット（およびオプションのパス）と一致している必要があります。

deddeswssws

swdw


dede








