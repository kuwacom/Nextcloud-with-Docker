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

---
以上！このドキュメントを参考にして、Docker Compose + Cloudflare Tunnel を活用した Nextcloud を楽しみましょう！