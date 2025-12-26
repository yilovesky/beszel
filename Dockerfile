# 阶段 1: 编译
FROM golang:1.21-alpine AS builder
WORKDIR /app
# 安装编译工具
RUN apk add --no-cache curl git
COPY . .

# 1. 汉化处理：直接修改根目录下的 i18n.yml 或 Go 代码（如果需要深度汉化）
# 现在的版本支持 i18n.yml，我们可以直接利用它
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 编译 Go 程序
RUN go mod tidy && go build -o hub beszel.go

# 阶段 2: 运行
FROM alpine:latest
WORKDIR /app

# 拷贝编译好的二进制文件
COPY --from=builder /app/hub /app/hub
# 拷贝必要的资源文件
COPY --from=builder /app/i18n.yml /app/i18n.yml

# 下载全球地图数据库
RUN apk add --no-cache curl && \
    curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090
# 启动，指定数据目录为我们挂载的 /app/data
CMD ["/app/hub", "-data", "/app/data"]
