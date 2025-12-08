#!/bin/bash

WORK_DIR=$(dirname "$(realpath "$0")")

if [ ! -f "$WORK_DIR/student.env" ]; then
  echo "please follow README.md to create student.env file"
  exit 1
fi

source $WORK_DIR/student.env

WORK_DIR_HOST=$WORK_DIR_HOST
if [ -z "$WORK_DIR_HOST" ]; then
  WORK_DIR_HOST=$WORK_DIR
fi

STUDENT_ID_SUFFIX=$STUDENT_ID_SUFFIX
INSTANCE_ID=orcl$STUDENT_ID_SUFFIX

if [ -z "$ORACLE_PWD" ]; then
  ORACLE_PWD=$INSTANCE_ID
fi

echo "oracle database password: $ORACLE_PWD"

mkdir -p data

USER_ID=54321
GROUP_ID=54321
mkdir -p $WORK_DIR/data
sudo chown $USER_ID:$GROUP_ID $WORK_DIR/data

ORACLE_DATABASE_CONTAINER_NAME=25-database-homework-practice02

echo "stopping existing instance of oracle database..."
sudo docker stop $ORACLE_DATABASE_CONTAINER_NAME

echo "starting oracle database..."
sudo docker run --rm -d \
  --name $ORACLE_DATABASE_CONTAINER_NAME \
  --network host \
  -v $WORK_DIR_HOST/data:/opt/oracle/oradata \
  -e TZ=$TZ \
  -e ORACLE_PWD=$INSTANCE_ID \
  -e ORACLE_SID=$INSTANCE_ID \
  -e ORACLE_UNQNAME=$ORACLE_UNQNAME \
  container-registry.oracle.com/database/enterprise:21.3.0.0

until [ "$(docker inspect -f {{.State.Health.Status}} $ORACLE_DATABASE_CONTAINER_NAME)" = "healthy" ]; do
  echo "waiting for oracle database..."
  sleep 5
done

echo "oracle database started, connecting..."
sleep 5
sudo docker run --rm -it \
  --network host \
  --entrypoint sqlplus \
  -e TZ=$TZ \
  -e ORACLE_SID=$INSTANCE_ID \
  -e ORACLE_PDB=$INSTANCE_ID \
  container-registry.oracle.com/database/enterprise:21.3.0.0 \
  sys@//127.0.0.1:1521/$INSTANCE_ID as sysdba

echo "stopping oracle database..."
sudo docker stop $ORACLE_DATABASE_CONTAINER_NAME
