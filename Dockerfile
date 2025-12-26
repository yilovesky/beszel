FROM golang:alpine

# 1. 安装基础工具
RUN apk add --no-cache curl git gcc musl-dev

WORKDIR /app
COPY . .

# 2. 汉化处理
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 3. 现场编译（不手动指定架构，让它自适应 Zeabur）
RUN go mod tidy && go build -o beszel-hub beszel.go

# 4. 显式赋予权限
RUN chmod +x /app/beszel-hub

# 5. 下载地图数据库
RUN curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 6. 最终启动指令
CMD ["/app/beszel-hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
