# 阶段 1: 编译（使用最新版 Go 以满足 1.25+ 的要求）
FROM golang:alpine AS builder
WORKDIR /app

# 安装必要工具
RUN apk add --no-cache curl git gcc musl-dev

COPY . .

# 1. 汉化处理
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 编译 Go 程序
# 添加 CGO_ENABLED=0 以确保生成的二进制文件在 alpine 运行阶段兼容
RUN go mod tidy && CGO_ENABLED=0 go build -o hub beszel.go

# 阶段 2: 运行
FROM alpine:latest
WORKDIR /app

# 拷贝编译好的二进制文件
COPY --from=builder /app/hub /app/hub
COPY --from=builder /app/i18n.yml /app/i18n.yml

# 下载全球地图数据库
RUN apk add --no-cache curl && \
    curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 启动，确保使用我们挂载的 /app/data 目录
CMD ["/app/hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
