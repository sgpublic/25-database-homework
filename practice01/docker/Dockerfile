FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --reinstall ca-certificates

ARG APT_MIRROR=deb.debian.org
RUN sed -i "s#http://deb.debian.org#${APT_MIRROR}#g" /etc/apt/sources.list.d/debian.sources

# 安装基础依赖
RUN apt-get update && apt-get install -y git sudo build-essential cmake pkg-config sed bison

# 安装编译 mysql 所需的额外依赖
RUN apt-get update && apt-get install -y libssl-dev libncurses5-dev libtirpc-dev icu-devtools

ARG USER_ID
ARG GROUP_ID
RUN groupadd -g ${GROUP_ID} mysql-builder && \
    useradd -u "${USER_ID}" -g "${GROUP_ID}" -m -s /bin/bash mysql-builder && \
    echo "mysql-builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY rootf /

VOLUME /work

ENTRYPOINT ["/entrypoint.sh"]
