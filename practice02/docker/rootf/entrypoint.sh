#!/bin/bash

set -e
set -x

ORACLE_BASE=$ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/21c/dbhome_1
INSTANCE_ID=$INSTANCE_ID
ORACLE_HOSTNAME=$INSTANCE_ID
export ORACLE_SID=$INSTANCE_ID

if [ ! -f "$ORACLE_BASE/oradata/.install_done" ]; then
  echo "installing oracle database..."
  rm -rf $ORACLE_BASE/*
  cp -a /opt/oracledb_installer/* $ORACLE_BASE
  ORACLE_PWD=$ORACLE_PWD

  echo "HOSTNAME: $(hostname -f)"

  cat <<EOF > $ORACLE_BASE/oradata/inst_oracledb.rsp
oracle.install.responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v21.0.0
oracle.install.option=INSTALL_DB_AND_CONFIG
ORACLE_HOSTNAME=$ORACLE_HOSTNAME
UNIX_GROUP_NAME=dba
INVENTORY_LOCATION=$ORACLE_BASE/oraInventory
ORACLE_HOME=$ORACLE_HOME
ORACLE_BASE=$ORACLE_BASE
oracle.install.db.InstallEdition=EE
oracle.install.db.ConfigureAsContainerDB=true
oracle.install.db.config.starterdb.globalDBName=$INSTANCE_ID
oracle.install.db.config.starterdb.SID=$INSTANCE_ID
oracle.install.db.config.starterdb.memoryLimit=3072
oracle.install.db.config.starterdb.password.ALL=$ORACLE_PWD
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=$ORACLE_BASE/oradata/data
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=$ORACLE_BASE/oradata/fast_recovery_area
oracle.install.db.config.PDBName=orclpdb

oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=dba
oracle.install.db.OSBACKUPDBA_GROUP=dba
oracle.install.db.OSDGDBA_GROUP=dba
oracle.install.db.OSKMDBA_GROUP=dba
oracle.install.db.OSRACDBA_GROUP=dba
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
EOF

  mkdir -p $ORACLE_BASE/oraInventory $ORACLE_BASE/oradata/data $ORACLE_BASE/oradata/fast_recovery_area
  chown -R oracle:oinstall $ORACLE_BASE

  set +e
  gosu oracle $ORACLE_HOME/runInstaller \
      -silent \
      -force \
      -waitforcompletion \
      -responseFile $ORACLE_BASE/oradata/inst_oracledb.rsp \
      -ignorePrereqFailure
  echo "oracle database install process exit with code $?"
  set -e

  rm -rf $ORACLE_HOME/apex
  rm -rf $ORACLE_HOME/ords
  rm -rf $ORACLE_HOME/sqldeveloper
  rm -rf $ORACLE_HOME/ucp
  rm -rf $ORACLE_HOME/lib/*.zip
  rm -rf $ORACLE_HOME/inventory/backup/*
  rm -rf $ORACLE_HOME/network/tools/help
  rm -rf $ORACLE_HOME/assistants/dbua
  rm -rf $ORACLE_HOME/dmu
  rm -rf $ORACLE_HOME/install/pilot
  rm -rf $ORACLE_HOME/suptools

  chown -R oracle:dba $ORACLE_BASE

  $ORACLE_BASE/oraInventory/orainstRoot.sh
  $ORACLE_HOME/root.sh

  set +e
  gosu oracle $ORACLE_HOME/runInstaller \
      -silent \
      -waitforcompletion \
      -responseFile $ORACLE_BASE/oradata/inst_oracledb.rsp \
      -executeConfigTools
  echo "oracle database configure process exit with code $?"
  set -e

  touch $ORACLE_BASE/oradata/.install_done
fi

set +x

echo "> cat /proc/meminfo | grep MemTotal"
cat /proc/meminfo | grep MemTotal

echo "> cat /proc/meminfo | grep SwapTotal"
cat /proc/meminfo | grep SwapTotal

echo "> df -h /tmp"
df -h /tmp

echo "> cat /etc/redhat-release"
cat /etc/redhat-release

echo "> uname -r"
cat /etc/redhat-release

echo "> id oracle"
id oracle

export PATH=$ORACLE_HOME/bin:$PATH

gosu oracle sqlplus -s / as sysdba <<EOF
STARTUP;
exit;
EOF

gosu oracle bash
