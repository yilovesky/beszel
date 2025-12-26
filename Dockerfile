FROM golang:1.25.5-alpine
WORKDIR /app

# 安装基础工具
RUN apk add --no-cache curl git gcc musl-dev

COPY . .

# 1. 汉化处理
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 自动编译 (去掉所有手动架构锁定，让系统自动匹配)
RUN go mod tidy && go build -o /app/beszel-hub beszel.go

# 3. 赋权
RUN chmod +x /app/beszel-hub

# 4. 下载地图
RUN curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 5. 启动
CMD ["/app/beszel-hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
