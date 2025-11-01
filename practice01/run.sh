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

mkdir -p data

USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "start building docker image for mysql compile..."
sudo docker build -t mhmzx/database-practice:mysql-compile \
  --build-arg APT_MIRROR=$APT_MIRROR \
  --build-arg USER_ID=$USER_ID \
  --build-arg GROUP_ID=$GROUP_ID \
  $WORK_DIR/docker

if [ $? == 0 ]; then
  echo "start mysql compile..."
  sudo docker run --rm -it \
    --env-file $WORK_DIR/student.env \
    -u $USER_ID:$GROUP_ID \
    -v $WORK_DIR_HOST/data:/work \
    -e TZ=$TZ \
    mhmzx/database-practice:mysql-compile
fi
