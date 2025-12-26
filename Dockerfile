# 阶段 1: 编译
# 使用自动适配当前构建环境的 Go 镜像
FROM --platform=$BUILDPLATFORM golang:alpine AS builder
WORKDIR /app

# 安装必要工具
RUN apk add --no-cache curl git gcc musl-dev

COPY . .

# 1. 汉化处理
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 【核心修改】：不指定 GOOS 和 GOARCH，让 Go 编译器自动探测当前环境
RUN go mod tidy && \
    CGO_ENABLED=0 go build -o hub beszel.go

# 阶段 2: 运行
# 使用自动适配当前运行环境的 Alpine 镜像
FROM alpine:latest
WORKDIR /app

# 从 builder 拷贝
COPY --from=builder /app/hub /app/hub
COPY --from=builder /app/i18n.yml /app/i18n.yml

# 赋予权限
RUN chmod +x /app/hub

# 下载地图数据库
RUN apk add --no-cache curl && \
    curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 启动命令
CMD ["/app/hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
