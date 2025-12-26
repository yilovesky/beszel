# --- 阶段一：云端手术室 ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache nodejs npm curl git
WORKDIR /app
COPY . .

# 1. 深度汉化与 iOS 26 皮肤注入
RUN find ./web/src -type f -name "*.svelte" -exec sed -i 's/Dashboard/仪表盘/g' {} + && \
    find ./web/src -type f -name "*.svelte" -exec sed -i 's/Systems/集群节点/g' {} + && \
    echo "body { background: #000 !important; color: white !important; font-family: -apple-system, sans-serif; } \
    .card, [class*='rounded'] { background: rgba(255, 255, 255, 0.05) !important; backdrop-filter: blur(30px) !important; border: 0.5px solid rgba(255, 255, 255, 0.1) !important; border-radius: 24px !important; }" >> web/src/ios26.css && \
    echo "import './ios26.css';" >> web/src/routes/+layout.svelte

# 2. 地图资源引入
RUN sed -i '/<head>/a <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" /><script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>' web/src/app.html

# 3. 开始编译
RUN cd web && npm install && npm run build && \
    cd .. && go mod tidy && go build -o hub .

# --- 阶段二：打包上线 ---
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hub /app/hub
COPY --from=builder /app/web/dist /app/web/dist
RUN apk add --no-cache curl && \
    curl -L https://github.com/P3TERX/GeoLite2.mmdb/raw/download/GeoLite2-City.mmdb -o /app/GeoLite2-City.mmdb
EXPOSE 8090
CMD ["/app/hub"]
