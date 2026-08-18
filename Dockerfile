# 积分小当家 - Docker 镜像
# Node 22 (内置 sqlite，无需原生编译)
FROM node:22-alpine

WORKDIR /app

# 一次性复制整个项目（避免依赖单个 package-lock.json 导致文件缺失报错）
COPY . .

# 数据目录
RUN mkdir -p /app/data

# 安装后端依赖
WORKDIR /app/server
RUN npm install --omit=dev

WORKDIR /app

# 环境变量
ENV PORT=8080
ENV NODE_ENV=production
ENV DB_DIR=/app/data

EXPOSE 8080

# 启动（加 --experimental-sqlite 确保 node:sqlite 在所有 Node 22 环境可用）
CMD ["node", "--experimental-sqlite", "server/index.js"]
