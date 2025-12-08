# 高级数据库系统技术第 02 次自主实践

## 使用方法

开始运行：

1. 安装 Docker：

   ```shell
   curl -fsSL https://get.docker.com | bash -s -- --mirror Aliyun
   ```
2. 前往 [Oracle Container Registry](https://container-registry.oracle.com/)，点击右上角“Sign In”登录账号。
3. 点击右上角个人信息处，在展开的选项中点击“Auth Token”。
4. 点击新页面中的“Generate Secret Key”按钮。这将创建一个“Secret Key”，点击“Copy Secret Key”复制，请妥善保存此密钥。
5. 在终端中运行以下命令：

   ```shell
   docker login container-registry-sydney.oracle.com
   ```
   
   Username 输入登录使用的邮箱，Password 输入第 4 步中生成的 Secret Key。 
6. 复制 `student.env.template` 文件为 `student.env`，并填入你的学号后四位。
7. 运行 `run.sh`。
