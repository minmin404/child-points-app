# ☁️ 积分小当家 — Railway 免费云平台部署教程

> 目标：把你的"积分小当家"App 部署到 Railway 免费云平台，获得一个**永久公网地址**，手机随时随地能打开，做成 PWA 添加到主屏幕当 App 用。

**最终效果**：手机点开图标 → 全屏打开 App → 家长和孩子在不同手机上登录 → 数据实时同步。

> 📌 **已修复部署问题（v3）**：**彻底修复了 `COPY server/package-lock.json failed` 的报错**。新版 `Dockerfile` 改为 `COPY . .` 整体复制，不再依赖单独文件，无论仓库里有没有 `package-lock.json` 都能正常构建。

### 🔥 如果你遇到 `COPY server/package-lock.json failed` 报错（重要！）

这个错误的**根本原因**是：旧版 Dockerfile 里有一行 `COPY server/package-lock.json`，但你的 GitHub 仓库里**没有这个文件**，导致 Docker 复制时找不到文件而报错。

**解决办法**（只需更新一个文件）：
1. 用最新项目包里的**新版 `Dockerfile`** 替换你 GitHub 仓库里的旧版
2. 新版 Dockerfile 已**删除了对 `package-lock.json` 的依赖**，改为 `COPY . .` 整体复制
3. 保存后推到 GitHub，Railway 会自动重新构建（或手动点 Deploy → Redeploy）

> 新版 Dockerfile 核心内容：
> ```
> FROM node:22-alpine
> COPY . .
> RUN mkdir -p /app/data
> WORKDIR /app/server
> RUN npm install --omit=dev
> WORKDIR /app
> CMD ["node", "--experimental-sqlite", "server/index.js"]
> ```

---

## 一、总体流程（4大步）

```
① 注册GitHub → ② 把项目推送到GitHub仓库 → ③ 在Railway导入部署 → ④ 配置持久卷 → ⑤ 手机访问并添加主屏幕
```

需要准备：
- 一个 **GitHub 账号**（免费注册）
- 一个 **Railway 账号**（免费注册，部署时可能要求绑定信用卡验证，**不会扣费**）
- 你的电脑装了 **Git**（可选，后面有不用Git的办法）

---

## 二、第一步：注册账号（约5分钟）

### 1. 注册 GitHub
打开 https://github.com/ ，点击 **Sign up** 注册（免费）。
> 如果已有账号直接登录。记录下你的**用户名**。

### 2. 注册 Railway
打开 https://railway.com/ ，点击 **Sign up / Start**，推荐用 **GitHub 账号一键登录**（最省事）。

---

## 三、第二步：把项目上传到 GitHub

### 方式A：用 Git 命令（推荐）
在电脑上打开终端（Windows 用 PowerShell / Mac 用终端）：

```bash
# 1. 进入项目目录（改成你的路径）
cd D:\积分小当家        # Windows
cd ~/积分小当家          # Mac

# 2. 初始化 Git 仓库
git init

# 3. 添加所有文件
git add .

# 4. 提交
git commit -m "积分小当家"

# 5. 关联你的 GitHub 仓库（先到GitHub新建一个空仓库，复制它的地址）
git remote add origin https://github.com/你的用户名/child-points-app.git

# 6. 推送
git push -u origin main
```

> 如果没装 Git，到 https://git-scm.com/ 下载安装。

### 方式B：GitHub 网页直接上传（不用Git）
1. 打开 GitHub → 右上角 **+** → **New repository**
2. 仓库名填 `child-points-app`，点 **Create repository**
3. 在新页面点 **uploading an existing file**（上传现有文件）
4. 把解压后的 `child-points-app` 文件夹里的**所有文件**拖进去上传

> ⚠️ 注意：上传的是**文件夹里的内容**，不要把整个 `child-points-app` 文件夹本身拖进去。

---

## 四、第三步：在 Railway 部署（约5分钟）

1. 登录 Railway → 点 **New Project** → 选 **Deploy from GitHub repo**
2. 授权 Railway 访问你的 GitHub，选择刚才的 `child-points-app` 仓库
3. Railway 会自动检测到项目并开始构建部署
4. 等待部署完成（第一次构建约1-3分钟），看到 **Deploy 成功** / 状态变绿

### 设置启动端口
Railway 默认用 **3000** 端口，但我们项目用的是 **8080**。需要告诉 Railway：
1. 点你的 Service → **Variables**（变量）
2. 添加变量：`PORT` = `8080`
   （不放心的话也加一个 `JWT_SECRET`，随便填一串字母数字，如 `myfamilysecret2026`）

> 这一项很关键，不设置的话可能打不开。

---

## 五、第四步：配置持久卷（非常重要！防数据丢失）

> ⚠️ 不配置这一步，**每次 Railway 自动重启，你的任务和积分都会清空**！必须做。

1. 在你的 Service 页面 → 点 **Settings**
2. 找到 **Volumes**（持久卷）→ 点 **Add Volume**
3. **Mount Path（挂载路径）**填：`/app/data`
4. 保存

> 这样数据库文件会存到持久卷里，重启不丢。代码里已经写好了数据目录用环境变量 `DB_DIR=/app/data`（Dockerfile 已配置），无需再改。

---

## 六、第五步：手机访问 + 添加主屏幕（App体验）

### 1. 获取公网地址
Railway 部署成功后，点你的 Service → **Settings** → **Networking** → **Generate Domain**（生成域名）
会得到一个公网地址，类似：`https://child-points-app-production-xxxx.up.railway.app`

### 2. 手机访问
手机浏览器输入这个地址 → 就能打开 App 了！

### 3. 添加到主屏幕（变成App）
- **iPhone (Safari)**：点底部**分享按钮** → 选 **"添加到主屏幕"** → 添加
- **Android (Chrome)**：右上角**三个点菜单** → 选 **"安装应用"** 或 **"添加到主屏幕"**

添加后，手机桌面就会出现**"积分小当家"图标**，点开直接全屏使用，和原生App一样。

---

## 七、登录与首次设置

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 👨‍👩‍👧 家长 | `parent` | `123456` |

**首次使用**：
1. 家长用 `parent / 123456` 登录
2. 点底部 **"孩子"** → **添加孩子**，创建每个孩子的账号
3. 各人用自己的账号登录使用

---

## 八、常见问题

| 问题 | 解决办法 |
|------|----------|
| **部署后打不开** | 检查是否设置了 `PORT=8080` 变量（见第四步）|
| **重启后数据没了** | 没配持久卷，重做第五步（Volumes → /app/data）|
| **手机和电脑不同网也能用吗** | 能！部署到云端后，任何网络、任何地方都能访问 |
| **想换默认密码** | 家长登录后在应用里，或改 `server/db.js` 里的种子密码重新部署 |
| **国内访问慢** | Railway 服务器在国外，国内直连偶尔慢。想更快可用腾讯云 CloudBase（另需实名）|
| **构建失败** | 确认根目录有 `package.json`（已含 `postinstall` 自动装后端依赖）|

---

## 九、免费额度说明

- Railway 新用户有**免费试用额度**（约 $5 试用金，可持续用一段时间）
- 用量不大（家庭使用）可以跑挺久
- 如果试用额度用完，可考虑：升为付费（便宜）、或换 Render（免费750小时/月，无需绑卡）

> 家庭场景每天几十次访问，流量很小，用免费额度足够。

---

## 十、项目结构回顾

```
child-points-app/
├── package.json      ← 云端入口（postinstall自动装依赖 + start启动）
├── server/           ← 后端（Express + SQLite）
├── public/           ← 前端（PWA：manifest + sw）
├── Dockerfile        ← 容器部署（备用）
├── docker-compose.yml
└── data/             ← 数据库（持久卷挂载这里）
```

---

### 🎉 部署完成！

部署好后，全家就可以在各自的手机上，随时随地点开"积分小当家"App：
- **家长**：发布任务、审核、发积分、扣分
- **孩子**：认领任务、拍照打卡、赚积分

有任何一步卡住，把报错信息发给我，我帮你解决。

---

## 十一、部署失败排查指南（重点！）

如果你在 Railway 部署时遇到失败，**请先按下面排查**，90% 的问题都能自己解决。

### 🔍 第一步：查看具体错误信息
Railway 部署失败后：
1. 点你的 Service → **Deployments**（部署记录）
2. 点失败的那次部署 → **Build Logs**（构建日志）和 **Deploy Logs**（部署日志）
3. 找到红色报错行，对照下面的表格解决

### 常见错误对照表

| 错误信息关键词 | 原因 | 解决办法 |
|----------------|------|----------|
| **`Cannot find module 'node:sqlite'`** | Railway 用了 Node 20 或更低版本 | 确保项目根目录有 `railway.json`（强制 Dockerfile 构建），已用 Node 22 |
| **`SQLite is an experimental feature`** 导致崩溃 | node:sqlite 需要 flag | 启动命令加 `--experimental-sqlite`（已在新版 Dockerfile 和 package.json 中修复）|
| **`EADDRINUSE: address already in use`** | 端口冲突 | 设置环境变量 `PORT=8080`（Railway 会自动注入 PORT，但也手动设一下）|
| **`npm install` 失败 / 网络超时** | Railway 构建环境网络问题 | 重新触发部署（Retry），通常重试一次就好 |
| **构建成功但访问 502/超时** | 未生成公网域名 | Service → Settings → Networking → Generate Domain |
| **应用启动后立即退出** | 启动命令错误 | 检查 railway.json 的 startCommand 是 `node --experimental-sqlite server/index.js` |
| **数据重启后丢失** | 没配持久卷 | Service → Settings → Volumes → Add Volume → 路径填 `/app/data` |
| **`permission denied` 写 data 目录** | 权限问题 | Dockerfile 里已有 `RUN mkdir -p /app/data`，确认用的是最新 Dockerfile |

### 🔧 关键检查项（部署前确认）

确保你的 GitHub 仓库里有这些文件：
```
✅ railway.json          ← 强制 Dockerfile 构建（最关键！）
✅ Dockerfile            ← 指定 Node 22-alpine + experimental-sqlite
✅ package.json          ← 根目录，含 start 脚本
✅ server/package.json   ← 后端依赖
✅ server/index.js
✅ server/db.js
✅ public/               ← 前端
```

> 如果缺少 `railway.json`，Railway 会用默认的 Nixpacks 构建，可能选错 Node 版本导致 `node:sqlite` 报错。

### 🔄 如果还是失败：重新部署步骤

1. **删除 Railway 上的旧 Service**：Service → Settings → Delete
2. **用最新项目包更新 GitHub 仓库**（确保包含 `railway.json`）
3. **重新创建**：Railway → New Project → Deploy from GitHub repo
4. **部署成功后立即做**：
   - 添加环境变量 `JWT_SECRET`（随便填一串字符）
   - 添加持久卷：路径 `/app/data`
   - 生成域名

### 📸 把报错发给我

如果以上都试过还是失败，请把以下信息发给我：
1. **Build Logs** 的完整内容（或截图）
2. **Deploy Logs** 的完整内容（或截图）
3. 你的 GitHub 仓库地址（如果方便分享）

我看到具体错误就能精准帮你解决。
