FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 必要なパッケージのインストール
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    make \
    git \
    curl \
    jq \
    postgresql-client \
    direnv \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# direnv-dotenvのインストール
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
    curl -Lo /usr/local/bin/direnv-dotenv https://github.com/direnv/direnv-dotenv/releases/download/v2.0.0/direnv-dotenv-linux-arm64; \
    else \
    curl -Lo /usr/local/bin/direnv-dotenv https://github.com/direnv/direnv-dotenv/releases/download/v2.0.0/direnv-dotenv-linux-amd64; \
    fi && \
    chmod +x /usr/local/bin/direnv-dotenv && \
    ln -s /usr/local/bin/direnv-dotenv /usr/local/bin/dotenv

# SQLdefのインストール
ENV SQLDEF_VERSION=v0.16.15
RUN mkdir -p /tmp/sqldef && cd /tmp/sqldef && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
    curl -LO https://github.com/k0kubun/sqldef/releases/download/${SQLDEF_VERSION}/psqldef_linux_arm64.tar.gz && \
    tar xzvf psqldef_linux_arm64.tar.gz; \
    else \
    curl -LO https://github.com/k0kubun/sqldef/releases/download/${SQLDEF_VERSION}/psqldef_linux_amd64.tar.gz && \
    tar xzvf psqldef_linux_amd64.tar.gz; \
    fi && \
    chmod +x psqldef && \
    mv psqldef /usr/local/bin/ && \
    cd / && \
    rm -rf /tmp/sqldef

# タイムゾーンの設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# direnvの設定をbashrcに追加
RUN echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc 