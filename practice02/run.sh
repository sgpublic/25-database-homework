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
INSTANCE_ID=ORCL$STUDENT_ID_SUFFIX

if [ -z "$ORACLE_PWD" ]; then
  ORACLE_PWD=$INSTANCE_ID
fi

echo "oracle database password: $ORACLE_PWD"

mkdir -p data

USER_ID=54321
GROUP_ID=54321
mkdir -p $WORK_DIR/data
sudo chown $USER_ID:$GROUP_ID $WORK_DIR/data

echo "start building docker image for oracle database..."
sudo docker build -t mhmzx/database-practice:oracle-database-$INSTANCE_ID \
  --build-arg INSTANCE_ID=$INSTANCE_ID \
  $WORK_DIR/docker

if [ $? == 0 ]; then
  echo "starting oracle database..."
  sudo docker run --rm -it \
    --network host \
    --hostname $INSTANCE_ID \
    -v $WORK_DIR_HOST/data:/opt/oracledb \
    -e TZ=$TZ \
    -e ORACLE_PWD=$INSTANCE_ID \
    mhmzx/database-practice:oracle-database-$INSTANCE_ID
fi
