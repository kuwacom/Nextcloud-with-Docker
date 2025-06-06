# 🚀 Simple Nextcloud with Docker
NextcloudをDocker Compose + CFTunnelで簡単に構築

このリポジトリは、Docker Compose を使って簡単に Nextcloud をデプロイできるセットアップです  
Cloudflare Tunnel を利用した安全な外部公開にも対応しています

---

## 📦 セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/kuwacom/Nextcloud-with-Docker.git
cd Nextcloud-with-Docker
```

### 2. `.env` ファイルを作成して設定
以下の内容を `.env` ファイルとしてルートディレクトリに作成し、自分の環境に合わせて編集してください

```conf
# Nextcloudの設定
NEXTCLOUD_VERSION=30                                        # 使用したいNextcloudのバージョン 30が最新(2025/04/20現在)
HTTP_PORT=80                                                # Nextcloudを公開するポート
NEXTCLOUD_TRUSTED_DOMAINS=nextcloud localhost <your_domain> # 信頼するドメイン (スペース区切りで複数指定可能)
ADMIN_USERNAME=<admin_user_name>                            # Nextcloudの管理者ユーザー名
ADMIN_PASSWORD=<your_password>                              # Nextcloudの管理者パスワード
DEFAULT_LANGUAGE=ja                                         # デフォルトの言語 (例: ja, en)

# CloudFlareの設定
CLOUDFLARE_TUNNEL_TOKEN=<your_cloudflare_tunnel_token>      # CloudFlareのトンネルトークン
```

### 3. コンテナの起動
```
docker compose up -d
```

### 4. 動作確認
ブラウザで http://localhost:<HTTP_PORT> にアクセスし、Nextcloudの案内が表示されれば成功です

## 🌐 Cloudflare Tunnel で公開する
Cloudflare Tunnel を利用することで、外部ネットワークから安全にNextcloudへ接続できるようになります

> **⚠️注意⚠️**  
**Cloudflareにはアップロード及びダウンロードサイズ制限があるので、的確に設定しない場合、巨大ファイルのアップロードやダウンロード時にエラーが出る場合があります**  
**この手順は Cloudflare ダッシュボード側で設定を行うことを前提としています。**

### 1. Cloudflare Tunnel の作成
1. [Cloudflare Zero Trust ダッシュボード](https://one.dash.cloudflare.com/) にアクセス
2. **Network → Tunnels** から **Create a Tunnel** を選択
3. 任意の名前を入力し、トンネルを作成

### 2. 公開するサービスの設定
トンネル作成後、以下のようにエンドポイントを追加してください。

| サービス名      | エンドポイント（例）           | 宛先アドレス             |
| -------------- | -------------------------- | ---------------------- |
| **Nextcloud**  | `https://cloud.example.com` | `http://nextcloud:80`   |

設定完了後、Cloudflare Tunnel が正しく動作するか確認してください

次に、[NextCloud側に正しいリモートIPを認識させる設定](#リバースプロキシ下でリモートIPを正しく反映させる)を行う必要があります

## 🖧️ Nginxを使ってローカル経由でhttps接続する
NextCloudでは、通常の外部公開をする場合Nginx等を利用して、リバースプロキシを構成する必要があります  
本リポジトリでは、そちらの構成にも対応しています

### 1. Nginxの設定ファイルを構成する
`nginx/conf.d/default.conf`内の`server_name`に、アクセスするときに利用するドメイン名を記入してください

```conf
  server_name         localhost example.com; # アクセスするドメイン名を指定
```

リクエスト宛先として、NextCloudのサーバーを指定する必要があります  
ここには、`.env`で指定したNextCloudをホストに公開しているポートを設定してください  
デフォルトの場合ポート80なので、ポートを指定せず`http://localhost`で問題ありません

```conf
location / {
    proxy_pass         http://localhost; # .envで指定したNextCloudの公開ポートを指定
    ...
    }
```

### 2. 証明書を配置
`nginx/certs`フォルダを作成し、秘密鍵`privkey.pem`とサーバー証明書と中間証明書を統合した`fullchain.pem`を設置してください

> **📄 証明書について**  
証明書の作成方法の説明は省きます  
正しい証明書が必要な場合は let's encrypt 等で検索してください  
なお、オレオレ証明書で問題がない場合は、同梱している`create-certs.sh`をベースに簡単に作成することができます

次に、[NextCloud側に正しいリモートIPを認識させる設定](#-リバースプロキシ下でリモートipを正しく反映させる)を行う必要があります

## 👾 リバースプロキシ下でリモートIPを正しく反映させる
NginxやCloudFlare Tunnel下でNextCloudを利用する際、デフォルトの設定だと送信元IP(リモートIP)が取得できずに、リバースプロキシの立っているマシンやインスタンスのIPになってしまいます

この状態だとブルートフォースの制限やログ等が正常に行われずセキュリティ的にもよろしくないため、NextCloudのconfigを変更する必要があります

### 🔧 設定方法
まずは、事前に本docker composeを使ってNextCloudの構築を済ませてください

その後 `nextcloud/config/config.php` の `$CONFIG = array(` 内の一番下に以下の設定を追加しましょう

```php
  'trusted_proxies' =>
  array(
    0 => '127.0.0.1',
  ),
  'forwarded_for_headers' =>
  array(
    0 => 'HTTP_CF_CONNECTING_IP',
    1 => 'HTTP_X_FORWARDED_FOR',
  ),
```

この設定では、`127.0.0.1`(内部)からのアクセスをプロキシとして信頼し、リバースプロキシ前のリモートIPが記述してあるヘッダーを指定しています

> `docker-compose.yaml`内で、CloudFlareTunnelのサービスのネットワーク設定を`network_mode: service:nextcloud`として、NextCloudのサービス内と一体化させているため、CloudFlareのTunnel設定では宛先を`localhost`にして接続することが可能です


> [Nginxを使ってローカル経由でhttps接続する](#%EF%B8%8F-nginxを使ってローカル経由でhttps接続する)場合は、Nginxがリクエスト元リモートIPを正しく取得するために、ホスト側ネットワークを直接利用してリッスンする必要があります  
そのため、NginxからのNextCloudへ向けたリクエストは、内部からのリクエスト(`127.0.0.1`)となるため、例のままで問題ありません

`forwarded_for_headers`に関しては、利用するリバースプロキシによっては違うこともありますので、事前に確認をしてください

### ✅ 確認方法
ブラウザでNextCloudにログイン後、管理者設定 > セキュリティ の順にて確認可能です  
以下に自分の接続してるグローバルIPもしくはローカルIPが表示されていれば成功です！

![ipの表示](images/setting1.png)

---
以上！このドキュメントを参考にして、Docker Compose + Cloudflare Tunnel を活用した Nextcloud を楽しみましょう！

---
# ✅ 番外編

## NextCloudのバージョンアップ方法
NextCloudでは、定期的に最新バージョンへのアップグレードが推奨されています

本リポジトリでは、アップグレードも完結に行えるようにしてあります
### 1. コンテナの削除
まずは、一度コンテナ及びボリュームを削除します

以下のコマンドを実行してコンテナ及びボリュームを削除してください
```bash
sudo bash delete.sh
```
### 2. NextCloudイメージのバージョンを変更
次に、`.env`内にある`NEXTCLOUD_VERSION`で指定しているNextCloudのバージョンを新しいものにします

> **⚠️注意⚠️**  
**2個以上メジャーアップデートをまたいで更新はできないので、長い間アップデートしていない場合は一個一個更新していく必要があります**  
`nextcloud:27` -> `nextcloud:30` これは✖  
`nextcloud:27` -> `nextcloud:28`  -> `nextcloud:29` -> `nextcloud:30`

### 3. NextCloudの起動とアップグレード
次に、一度NextCloudを通常通り起動させます  
`docker compose up` もしくは `start.sh` 等をご利用ください

コンテナが完全に起動して、NextCloudのインストールが終了したことを確認出来たら、次にアップグレードスクリプトを実行します  
以下を実行することで自動でアップデートをすることができます  
こちらはホスト側で実行をしてください

```bash
sudo bash upgrade-nextcloud.sh
```

## バインドマウントしているNextCloudファイル類で権限エラーが出た時
docker の仕様上、バインドマウントしているフォルダやファイルは、基本的にホスト側の権限が利用されます

この場合、`www-data`等のNextCloudのシステムユーザー以外になった場合に`update-htaccess.sh`等が動作しなくなってしまいます

この場合は、ホスト側のファイルユーザーで実行してあげるとうまくいくことがあります  
プラスして、そのコマンドで書き換わるファイルもホスト側ユーザーにする必要があります

今回はhtaccessをアップデートする`maintenance:update:htaccess`コマンドを例にとってみます

まず、最初に変更されるファイルの所有者やグループをホスト側に合わせます
その後、コマンドを実行することで上手く反映されます
```bash
docker exec nextcloud_app chown 1000:1000 /var/www/html/.htaccess
docker exec -u 1000 nextcloud_app php /var/www/html/occ maintenance:update:htaccess
```

これはアップデート等でも同じです  
バインドマウントをする以上仕方ないことですので、どうにかしましょう

## ホスト側にバインドしているNextCloudのファイル類の権限が上書されてしまったとき
バックアップからファイルを復旧した時や、WindwosのWSL内でこのコンテナを起動してファイルをバインドすると、まれにNextCloudの設定ファイルや構成ファイル類の権限や所有者がリセットされてしまい、正常に動作しなくなる場合があります  
こういう時は、`reset-permissions.sh`を利用して権限を修正しましょう！

root権限で実行するだけで権限や所有者が所定の値に戻ります  
```bash
sudo bash ./reset-permissions.sh
```