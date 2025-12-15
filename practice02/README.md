# 高级数据库系统技术第 02 次自主实践

## 使用方法

开始运行：

1. 安装 Docker：

   ```shell
   curl -fsSL https://get.docker.com | bash -s -- --mirror Aliyun
   ```
2. 将 [LINUX.X64_213000_db_home.zip](https://www.oracle.com/database/technologies/oracle21c-linux-downloads.html#:~:text=LINUX.X64_213000_db_home.zip) 下载到 `./docker/data` 目录中，保持原有文件名不变，无需解压。
3. 复制 `student.env.template` 文件为 `student.env`，并填入你的学号后四位，设置一个数据库密码。
4. 运行 `run.sh`。
