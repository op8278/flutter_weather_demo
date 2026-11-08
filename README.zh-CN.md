# 天气应用（Flutter）

一个小型的 Flutter 天气 Demo（优先 iOS）：搜索地点、收藏城市、查看预报。由 Next.js 项目 [next-weather-demo](https://github.com/op8278/next-weather-demo) 迁移而来；移动端直接调用该项目线上 API，无需 API Key。

English version: [README.md](./README.md)

## 相关演示

- Web / API 仓库：[https://github.com/op8278/next-weather-demo](https://github.com/op8278/next-weather-demo)
- React Native 仓库：[https://github.com/op8278/rn-weather-demo](https://github.com/op8278/rn-weather-demo)
- 在线演示 / API：[https://next-weather-demo.vercel.app/](https://next-weather-demo.vercel.app/)

## 功能

- iOS 天气风格的收藏城市列表
- 天气详情页：逐时预报 + 7 日预报
- 按 WMO `weatherCode` 展示天气图标（当前天气、逐时、七日、城市卡片）
- 逐时预报支持「列表 / 温度曲线」切换，曲线展示当天温度
- 7 日预报可点击某一天，底部弹出当天温度曲线
- 中英文城市名按 Open-Meteo **地点 id** 精确解析（不用模糊搜索，避免同名误匹配）
- 列表页与详情页提供全局刷新按钮（在语言切换左侧），刷新时有卡片 / 详情 loading
- 收藏增删，数据持久化到 SharedPreferences
- 搜索下拉为 Overlay（不撑开列表布局）
- 加载 / 错误 / 重试状态
- 简体中文与英文（本地文案字典）

## 页面

| 路由 | 用途 |
| --- | --- |
| `/` | 收藏城市列表 + 搜索 |
| `/weather/:id?lat=&lon=&name=` | 某城市的天气详情 |

流程：

1. 打开 `/` 查看收藏（初始为空）。
2. 搜索城市 → 进入详情（**不会**自动收藏）。
3. 在详情页点 ★ 加入 / 移出列表。
4. 列表左滑卡片可删除。
5. 点刷新重新拉取天气；列表卡片与详情页会有 loading。

## 技术栈

| 层级 | 选择 | 原因 |
| --- | --- | --- |
| 框架 | Flutter + Material 3 | 单代码库；优先 iOS 模拟器 |
| 导航 | `go_router` | 路径 + query 与 Web / RN 对齐 |
| 状态 | `flutter_riverpod` + SharedPreferences | 收藏 / 语言 / 最近；天气与地理编码 Provider |
| HTTP | `http` | 薄封装 Vercel `{ code, data, msg }` 信封 |
| 上游天气 | Open-Meteo（经 Next.js API） | 免费、无 Key；与 Web 同一契约 |
| 远程 API | `https://next-weather-demo.vercel.app/api/*` | 复用已部署 Route Handler，本地不做 BFF |

### 设计取舍

- **Riverpod vs 本地 store**：远程天气 / 地理编码由 Provider 缓存（约 5 分钟 keepAlive）；`AppController` 管收藏与语言。详情由路由驱动，没有全局「当前城市」。
- **消费 Vercel API，不重做 Open-Meteo**：Zod / IPv4 / 响应整形留在服务端；App 只需 `ApiClient` + `--dart-define=API_BASE`。
- **无 API Key**：与 Web Demo 一致。
- **本地 i18n**：`zh` / `en` 文案在仓库内；星期几需 `initializeDateFormatting`。
- **按 id 解析地名**：切换语言走 `/api/geocode?id=`，避免模糊搜索错配。
- **模拟器与代理**：iOS 模拟器不走 macOS 系统代理。若模拟器访问不了 Vercel，使用 RN 项目的本地 `api-proxy`（见下）。

## API 契约

默认 Base：`https://next-weather-demo.vercel.app`

统一响应：

```json
{
  "code": 0,
  "data": {},
  "msg": "ok"
}
```

| `code` | 含义 |
| --- | --- |
| `0` | 成功 |
| `40001` | 参数无效 |
| `40401` | 地点未找到 |
| `50201` | 上游 Open-Meteo 失败 |
| `50000` | 未知 / 网络 / 解析错误 |

接口：

- `GET /api/geocode?q=taipei&lang=en|zh` — 按名称搜索
- `GET /api/geocode?id=1796236&lang=zh` — 按地点 id 精确查询
- `GET /api/weather?lat=25.05&lon=121.53&name=Taipei`

客户端在 `code !== 0` 时抛 `ApiError`（不依赖 HTTP 状态码）。UI 按 code 映射本地化错误文案。

### 覆盖 Base URL

```bash
flutter run --dart-define=API_BASE=https://next-weather-demo.vercel.app
```

### iOS 模拟器 + 代理

模拟器不使用 macOS 系统代理。若直连 Vercel 超时，复用 RN 项目的反代：

```bash
# 终端 1 — 在 rn-weather-demo
HTTPS_PROXY=http://127.0.0.1:7890 npm run api-proxy

# 终端 2 — 使用打印出的局域网地址
flutter run -d ios --dart-define=API_BASE=http://192.168.x.x:8787
```

`Info.plist` 已开启 `NSAllowsLocalNetworking`，允许访问局域网 HTTP 反代。

## 项目结构

```text
lib/
  app/router.dart         go_router 路由
  core/api/               ApiClient + 错误码
  core/config.dart        API_BASE（--dart-define）
  data/                   模型 + geocode/weather API
  domain/                 WMO、逐时窗口、地点标签
  l10n/                   中英文案
  state/                  Riverpod store + providers
  features/cities/        收藏列表
  features/search/        搜索 Overlay
  features/weather/       详情、曲线、sheet、图标
  features/common/        语言切换、刷新、加载/错误
```

持久化（SharedPreferences key `weather-app-store`）：`locale`、`favorites`、`recent`。

## 开始使用

```bash
flutter pub get
flutter run -d ios
```

## 校验

```bash
flutter analyze
flutter test
```
