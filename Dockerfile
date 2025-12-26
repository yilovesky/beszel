# 使用 Go 环境进行现场编译
FROM golang:1.24-alpine
WORKDIR /app

# 安装编译所需的依赖工具
RUN apk add --no-cache curl git gcc musl-dev

# 拷贝所有文件
COPY . .

# 1. 物理汉化（在这里处理，确保汉化生效）
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 现场编译：直接在运行环境里编译成名为 beszel-hub 的文件
RUN go mod tidy && go build -o /app/beszel-hub beszel.go

# 3. 显式赋权，防止出现 Permission denied
RUN chmod +x /app/beszel-hub

# 4. 下载地图数据库（Beszel 展示访客位置需要它）
RUN curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 5. 启动命令：运行我们刚刚生成的绝对路径文件
CMD ["/app/beszel-hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
