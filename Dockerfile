# 阶段 1: 编译
FROM golang:alpine AS builder
WORKDIR /app
RUN apk add --no-cache curl git gcc musl-dev
COPY . .

# 1. 汉化处理
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 编译 Go 程序 (静态编译)
RUN go mod tidy && CGO_ENABLED=0 go build -o hub beszel.go

# 阶段 2: 运行
FROM alpine:latest
WORKDIR /app

# 从编译阶段拷贝成品
COPY --from=builder /app/hub /app/hub
COPY --from=builder /app/i18n.yml /app/i18n.yml

# 【关键修复】：赋予 hub 运行权限
RUN chmod +x /app/hub

# 下载全球地图数据库
RUN apk add --no-cache curl && \
    curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 启动命令
CMD ["/app/hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
