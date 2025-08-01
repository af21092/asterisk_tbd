#ベースイメージ設定
FROM ubuntu:latest

ENV  DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# OSのアップデートを更新、必要なツールとAsterisk,Python3,pipのインストール
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    wget \
    gnupg2 \
    software-properties-common \
    python3 \
    python3-pip \
    asterisk \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Asteriskのバージョンが古い場合は、公式リポジトリを追加して最新版をインストール
# 必要に応じてコメントアウトを解除し、apt install asterisk の前に実行
# RUN add-apt-repository ppa:asterisk/asterisk-addons && \
#     apt update && \
#     apt install -y asterisk

# Pythonの仮想環境を作成し、必要なライブラリをインストール
WORKDIR /app
RUN python3 -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# Pythonライブラリのインストール
# PyPIからインストールできる一般的なもの
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Asteriskの設定ファイルをコンテナ内にコピー
# ホスト側の `asterisk_conf` ディレクトリに、編集済みの設定ファイルを置いておくことを想定
COPY asterisk_conf/ /etc/asterisk/

# Pythonアプリケーションのコードをコンテナ内にコピー
# ホスト側の `src` ディレクトリに、Pythonスクリプトを置いておくことを想定
COPY src/ /app/src/

# コンテナが起動したときにAsteriskをフォアグラウンドで実行
# これにより、コンテナのログでAsteriskの動作を確認できます。
# 実際の運用では、systemdなどでバックグラウンド実行を管理することも多いですが、開発・デバッグ用にはフォアグラウンドが便利です。
CMD ["asterisk", "-f"]

# 必要に応じてポートを開放
# SIP (UDP/TCP) と RTP (UDP) のデフォルトポート
EXPOSE 5060/udp
EXPOSE 5060/tcp
EXPOSE 10000-20000/udp 
# RTPの一般的なポート範囲。範囲は調整してください。
# AMI (Asterisk Manager Interface) のデフォルトポート
EXPOSE 5038/tcp