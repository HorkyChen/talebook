
# ----------------------------------------
# 第一阶段，拉取 node 基础镜像并安装依赖，执行构建
FROM node:16-alpine AS builder
ARG BUILD_COUNTRY=""

WORKDIR /build
RUN if [ "x${BUILD_COUNTRY}" = "xCN" ]; then \
    echo "using repo mirrors for ${BUILD_COUNTRY}"; \
    npm config set registry http://mirrors.tencent.com/npm/; \
    fi

COPY app/package.json app/package-lock.json* ./
RUN npm install

# spa build mode will clear ssr build data, run it first
COPY app/ /build/
RUN mkdir -p /app-ssr/ /app-static/ && \
    npm run build && \
    ls -al && \
    cp -r .nuxt node_modules package* /app-ssr/ && \
    npm run build-spa && \
    cp -r dist nuxt.config.js package* /app-static/


# ----------------------------------------
# 第二阶段，构建环境
# FROM linuxserver/calibre AS server
FROM ubuntu:24.04 AS server
ARG BUILD_COUNTRY="CN"

# Set mirrors in china
RUN if [ "x${BUILD_COUNTRY}" = "xCN" ]; then \
    echo "using repo mirrors for ${BUILD_COUNTRY}"; \
    sed 's@archive.ubuntu.com/ubuntu@mirrors.huaweicloud.com/repository/ubuntu@g' -i /etc/apt/sources.list.d/ubuntu.sources; \
    sed 's@security.ubuntu.com/ubuntu@mirrors.huaweicloud.com/repository/ubuntu@g' -i /etc/apt/sources.list.d/ubuntu.sources; \
    fi

# install envsubst gosu procps
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apt update -y && \
    apt install -y gettext gosu procps vim nginx calibre calibre-bin supervisor fonts-lato && \
    apt clean && \
    apt install -y python3-pip && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -u 990 -U -d /var/www/talebook -s /bin/false talebook && \
    usermod -G users talebook && \
    groupmod -g 990 talebook && \
    sed -i "s/user www-data;/user talebook;/g" /etc/nginx/nginx.conf

# RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin

# Create a talebook user and change the Nginx startup user

# install python packages (--break-system-packages)
# Apply calibre patches
COPY calibre/7.6/calibre/db/cache.py /usr/lib/calibre/calibre/db/
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt --break-system-packages && \
    rm -rf /root/.cache


# ----------------------------------------
# 测试阶段 (--break-system-packages)
RUN echo "Testing..."
FROM server AS test
RUN pip install flake8 pytest --break-system-packages
COPY webserver/ /var/www/talebook/webserver/
COPY tests/ /var/www/talebook/tests/
CMD ["pytest", "/var/www/talebook/tests"]
RUN echo "Testing... [DONE]"

# ----------------------------------------
# 生产环境
FROM server AS production
ARG GIT_VERSION=""

LABEL Author="horky <horky.chen@gmail.com>"
LABEL Thanks="Rex <talebook@foxmail.com>, oldiy <oldiy2018@gmail.com>"

# set default language
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8
ENV PUID=1000
ENV PGID=1000


# prepare dirs
RUN mkdir -p /data/log/nginx/ && \
    mkdir -p /data/books/library  && \
    mkdir -p /data/books/extract  && \
    mkdir -p /data/books/upload  && \
    mkdir -p /data/books/imports  && \
    mkdir -p /data/books/convert  && \
    mkdir -p /data/books/progress  && \
    mkdir -p /data/books/settings && \
    mkdir -p /data/books/logo && \
    mkdir -p /data/books/avatar && \
    mkdir -p /data/books/ssl && \
    mkdir -p /var/www/talebook/ && \
    chmod a+w -R /data/log /data/books /var/www

COPY server.py /var/www/talebook/
COPY docker/ /var/www/talebook/docker/
COPY webserver/ /var/www/talebook/webserver/
COPY webserver/settings.py /var/www/talebook/webserver/
COPY conf/nginx/ssl.* /data/books/ssl/
COPY conf/nginx/talebook.conf /etc/nginx/conf.d/
COPY conf/supervisor/talebook.conf /etc/supervisor/conf.d/
COPY --from=builder /app-static/ /var/www/talebook/app/
COPY --from=builder /app-static/dist/logo/ /data/books/logo/
COPY --from=builder /app-static/dist/avatar/ /data/books/avatar/

RUN rm -f /etc/nginx/sites-enabled/default /var/www/html -rf && \
    cd /var/www/talebook/ && \
    echo "VERSION = \"$GIT_VERSION\"" > webserver/version.py && \
    echo 'settings = {}' > /data/books/settings/auto.py && \
    chmod a+w /data/books/settings/auto.py && \
    calibredb add --library-path=/data/books/library/ -r docker/book/ && \
    python3 server.py --syncdb  && \
    python3 server.py --update-config  && \
    rm -f webserver/*.pyc && \
    rm -rf app/src && \
    rm -rf app/dist/logo && \
    ln -s /data/books/logo app/dist/logo && \
    rm -rf app/dist/avatar && \
    ln -s /data/books/avatar app/dist/avatar && \
    mkdir -p /prebuilt/ && \
    mv /data/* /prebuilt/ && \
    chmod +x /var/www/talebook/docker/start.sh

EXPOSE 80 443

VOLUME ["/data"]

CMD ["/var/www/talebook/docker/start.sh"]

# ----------------------------------------
# 生产环境（server side render版)
FROM production AS production-ssr

# intall nodejs for nuxtjs server side render
RUN apt update -y && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt install -y nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# copy ssr config
COPY conf/nginx/server-side-render.conf /etc/nginx/conf.d/talebook.conf
COPY conf/supervisor/server-side-render.conf /etc/supervisor/conf.d/talebook.conf
COPY --from=builder /app-ssr/ /var/www/talebook/app/
