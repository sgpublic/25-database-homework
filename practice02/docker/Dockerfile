FROM oraclelinux:8.10 AS base

# 安装基础依赖
# https://docs.oracle.com/en/database/oracle/oracle-database/21/ladbi/supported-oracle-linux-8-distributions-for-x86-64.html
RUN yum update && \
    yum install -y bc binutils compat-openssl10 elfutils-libelf glibc glibc-devel ksh libaio libXrender libX11 libXau \
    libXi libXtst libgcc libnsl libstdc++ libxcb libibverbs make policycoreutils policycoreutils-python-utils  \
    smartmontools sysstat hostname && \
    yum clean all

# 手动设置限制用户资源
RUN cat <<'EOF' >> /etc/security/limits.conf
oracle soft nofile 10240 # 软限制：最大打开文件描述符数
oracle hard nofile 65536 # 硬限制：最大打开文件描述符数
oracle soft nproc 16384 # 软限制：最大进程数
oracle hard nproc 32768 # 硬限制：最大进程数
oracle soft stack 10240 # 软限制：栈大小
oracle hard stack 32768 # 硬限制：栈大小
oracle soft memlock unlimited # 软限制：可锁定内存
oracle hard memlock unlimited # 硬限制：可锁定内存
oracle soft core unlimited # 软限制：核心转储文件大小
oracle hard core unlimited # 硬限制：核心转储文件大小
EOF

# 添加新的组和用户
RUN groupadd -g 54321 oinstall && \
    groupadd -g 54327 asmdba && \
    groupadd -g 54322 dba && \
    groupadd -g 54323 oper && \
    groupadd -g 54324 backupdba && \
    groupadd -g 54325 dgdba && \
    groupadd -g 54326 kmdba && \
    groupadd -g 54330 racdba && \
    useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle

RUN curl -fsSL https://github.com/tianon/gosu/releases/download/1.19/gosu-amd64 -o /usr/bin/gosu && \
    chmod +x /usr/bin/gosu

ARG ORACLE_BASE=/opt/oracledb

ENV ORACLE_BASE=${ORACLE_BASE}
ENV ORACLE_HOME=${ORACLE_BASE}/product/21c/dbhome_1

FROM base AS builder

RUN yum update && \
    yum install -y unzip && \
    yum clean all

COPY data /var/cache
RUN mkdir -p $ORACLE_HOME $ORACLE_BASE/oradata/data $ORACLE_BASE/oradata/fast_recovery_area && \
    cd $ORACLE_HOME && \
    unzip /var/cache/LINUX.X64_213000_db_home.zip && \
    rm /var/cache/LINUX.X64_213000_db_home.zip && \
    chown -R oracle:oinstall $ORACLE_BASE

FROM base AS output

ARG INSTANCE_ID
ENV INSTANCE_ID=${INSTANCE_ID}

COPY --from=builder --chown=oracle:oinstall ${ORACLE_BASE} /opt/oracledb_installer

COPY rootf /

VOLUME ${ORACLE_BASE}

USER root
ENTRYPOINT ["/entrypoint.sh"]
