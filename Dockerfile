# 升级到 1.25.5 版本以满足项目要求
FROM golang:1.25.5-alpine
WORKDIR /app

# 安装编译所需的依赖工具
RUN apk add --no-cache curl git gcc musl-dev

# 拷贝所有文件
COPY . .

# 1. 物理汉化
RUN if [ -f "i18n.yml" ]; then sed -i 's/Dashboard/仪表盘/g' i18n.yml; fi

# 2. 现场编译
# 增加 GOTOOLCHAIN=auto 允许 Go 自动切换到所需的次要版本
RUN GOTOOLCHAIN=auto go mod tidy && go build -o /app/beszel-hub beszel.go

# 3. 显式赋权
RUN chmod +x /app/beszel-hub

# 4. 下载地图数据库
RUN curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb

EXPOSE 8090

# 5. 启动命令
CMD ["/app/beszel-hub", "serve", "--http", "0.0.0.0:8090", "--dir", "/app/data"]
