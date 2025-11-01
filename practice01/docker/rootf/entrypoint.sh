#!/bin/bash

check_git_repo() {
  local target_path="$1"
  local repo_url="$2"
  local expected_tag="$3"

  if ! git -C $target_path rev-parse --is-inside-work-tree &>/dev/null; then
    return 2
  fi

  local current_url=$(git -C $target_path remote get-url origin)
  if ! [[ "$current_url" == "$repo_url" ]]; then
    return 1
  fi

  local current_ref=$(git -C $target_path symbolic-ref --short HEAD 2>/dev/null)
  if [[ -z "$current_ref" ]]; then
    current_ref=$(git -C $target_path describe --tags --exact-match 2>/dev/null)
  fi
  if ! [[ "$current_ref" == "$expected_tag" ]]; then
    return 3
  fi

  return 0
}

clone_code() {
  echo "checking repo..."
  if check_git_repo /work/git "$MYSQL_REPO_URL" "$MYSQL_REPO_REF"; then
    git -C /work/git reset --hard HEAD
    echo "repo valid."
    return 0
  fi

  echo "repo not valid, delete it."
  sudo rm -r /work/git

  echo "clone '$MYSQL_REPO_REF' of '$MYSQL_REPO_URL'"
  git clone $MYSQL_REPO_URL -b $MYSQL_REPO_REF --depth=1 ./git
  if ! check_git_repo /work/git "$MYSQL_REPO_URL" "$MYSQL_REPO_REF"; then
    echo "repo clone failed, exit."
    return 1
  fi
  return 0
}

modify_code() {
  local date_str=$(date "+%Y-%m-%d %H:%M")
  sed -i "s#Welcome to the MySQL monitor.#Welcome to the MySQL monitor. $STUDENT_NAME $STUDENT_ID $date_str#g" ./git/client/mysql.cc
}

setup_cmake() {
  sudo rm -r ./build
  mkdir -p ./build/cmake
  cmake -S ./git -B ./build/cmake -DCMAKE_INSTALL_PREFIX=/work/build/output
}

start_make() {
  sudo rm -r /work/build/output
  mkdir -p /work/build/output
  make -C /work/build/cmake -j$(nproc) && make install -C /work/build/cmake
  if [ $? == 0 ]; then
    touch /work/build/output/.compile_done
  else
    return $?
  fi
}

main() {
  clone_code || return $?
  modify_code || return $?
  setup_cmake || return $?
  start_make || return $?
}

open_mysql() {
  export PATH=$PATH:/work/build/output/bin
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/build/output/lib

  if [ ! -f /work/build/output/data/.init_done ]; then
    echo "mysqld --initialize-insecure"
    mysqld --initialize-insecure
    touch /work/build/output/data/.init_done
  fi

  echo "mysqld_safe > /dev/null 2>&1 &"
  mysqld_safe > /dev/null 2>&1 &

  sleep 3
  echo "mysql -u root"
  mysql -u root
}

cd /work

if [ ! -f /work/build/output/.compile_done ]; then
  if main; then
    echo "compile success."
  else
    echo "compile process stopped with error!"
    bash
  fi
fi

if [ -f /work/build/output/.compile_done ]; then
  open_mysql
fi
