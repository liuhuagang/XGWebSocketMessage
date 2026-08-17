# XGWebSocketMessage — UE5 多人网络插件与配套工程

[English](README.md) · [简体中文](README_CN.md)

> 📌 **本仓库是 XGWebSocketMessage 插件的配套工程**（XGMultiPlayer），用于演示与上手插件的两条使用链路：
> ① **底层通讯**（Server ↔ Client 直连）；② **上层房间协议**（Manage 管理服 + 玩家客户端的完整房间系统）。
> **插件本体请从 FAB 商城获取**，本仓库不含插件源码。

## 这是什么

**XGWebSocketMessage** 是一款基于 UE5 内置 WebSocket 的多人网络插件（服务端 + 客户端），支持虚幻项目之间相互通信，自带连接握手与心跳保活（3 秒心跳 / 10 秒超时）。

**XGMultiPlayer** 是插件的配套工程：单一 UE 工程、三个运行时角色——**Manage**（管理服）、**Client**（玩家客户端）、**DS**（游戏副本），完整演示两条使用链路：

- **链路一 · 底层通讯**：`L_ConnectionTest` 关卡内置服务端/客户端面板，不依赖房间系统即可验证直连收发
- **链路二 · 上层房间协议**：大厅 → 建房/加房 → 开副本 → 进副本 → 聊天 → 房主权限 → 解散，开箱即用

## 版本配套（重要）

| 插件版本 | 底层通讯（链路一） | 房间协议（链路二） |
|----------|:---:|:---:|
| **2.1**（FAB 当前上架，3 模块） | ✅ | ❌ 不可用 |
| **新版本**（5 模块，含上层模块） | ✅ | ✅ |

> ⚠️ 本工程的大厅/房间/聊天 UI 依赖插件**上层模块**（`XGWebSocketGame` / `XGWebSocketManage`）的异步蓝图节点：
> - 安装 **2.1** 版插件时，仅 `L_ConnectionTest`（链路一）可用；
> - 房间系统（链路二）需**新版本插件**（含上层模块，发布后从 FAB 获取），并保持插件与工程版本配套。

## 功能特性

- **单一工程三角色**——Manage / Client / DS 同一工程不同启动参数运行
- **房间系统**——创建/加入/离开/踢出/解散；密码保护；人数上限
- **房主权限**——有损操作（踢人/关房/开关副本/换图）需房主身份，由 Manage 权威校验
- **副本动态开关**——副本由房主手动启动/关闭；端口自动分配（7777–8000）；副本关闭后房间保留
- **断线联动**——房主断线 → 自动解散房间 + 杀副本；成员断线 → 移出房间；DS 断线 → 复位副本状态
- **房间聊天**——`SendRoomMessage` 广播全员（发送者名由 Manage 权威补全）
- **房间换图**——`ChangeMyRoomLevel`，副本运行中拒绝
- **协议机制**——JSON → Base64 → 二进制 WebSocket 帧；协议版本协商（版本不匹配的旧客户端注册被拒）

## 系统架构

```
Manage（管理服）
 房间/DS/玩家集中维护 · 权威校验 · HTTP 状态服务
 WebSocket 9033 · HTTP 9034
      │
 ┌────┼────────────────┐
 ▼    ▼                ▼
Client Client N        DS（游戏副本进程）
大厅/房间/副本 UI      由 Manage 自动拉起
异步蓝图节点           端口自动分配 7777-8000
```

| 角色 | 进程 | 启动参数 | 职责 |
|------|------|----------|------|
| Manage | `XGMultiPlayerServer.exe` | `-Manage` | 房间/DS/玩家集中维护、权威校验、拉起 DS 进程、HTTP 状态服务 |
| Client | `XGMultiPlayer.exe` | — | 大厅、房间列表、房间/副本 UI、聊天 |
| DS | `XGMultiPlayerServer.exe` | `-server` | 游戏副本；注册到 Manage，为玩家提供游戏服务 |

## 环境要求

- **Unreal Engine 5.8**（Windows）
- **Visual Studio 2022**（C++ 游戏开发工作负载，编译工程需要）
- Windows 11

## 快速上手（从零跑通）

1. **安装插件**：从 FAB 商城获取 XGWebSocketMessage（版本要求见上「版本配套」）
2. **打开工程**：双击 `XGMultiPlayer.uproject`，编辑器提示重新编译时确认（首次编译需几分钟）
3. **打包服务端**：运行 `Bat\Package_Manage.bat`，产出 `XGMultiPlayerServer.exe`（同时兼作 DS 可执行文件）
4. **启动 Manage**：运行 `Bat\Dev\Start_Manage.bat`（监听 WS 9033 / HTTP 9034）
5. **启动客户端**：运行 `Bat\Dev\Start_Client.bat`（或编辑器直接运行 `L_Lobby` 地图）
6. **验证链路一**：编辑器运行 `L_ConnectionTest` 地图，服务端/客户端面板直连收发
7. **验证链路二**：大厅里建房 → 另一客户端加房 → 房主开副本 → 成员进副本 → 房间聊天 → 房主解散

> 所有 `Bat/` 脚本均使用相对路径定位 exe（`%~dp0`），双击即可运行，不依赖当前目录。
> 命令行编译（可选）：`<UE5.8安装路径>\Engine\Build\BatchFiles\Build.bat XGMultiPlayerEditor Win64 Development -Project="<本仓库路径>\XGMultiPlayer.uproject" -WaitMutex`

## 典型流程：节点操作手册

> 以下节点全部位于蓝图分类 `XGWebSocketMessage|Player|Room`（操作类）与 `XGWebSocketMessage|Player`（查询类）。
> 节点统一为异步节点：`Then` 激活表示请求已发出；`OnSuccess` 成功；`OnFail` 失败（携带 `AsyncID / Result / RoomError / Message`）。

### 前置要求

1. 插件版本配套（见「版本配套」）
2. Manage 进程已启动（`Bat\Dev\Start_Manage.bat`，监听 WS 9033）
3. 工程已编译，客户端能访问 Manage 所在机器（本地联调即本机）

### 1. 连接 Manage（登录）

| 节点/事件 | 说明 |
|-----------|------|
| `ConnectToManage(ManageServerInfo)` | 连接 Manage 并完成玩家角色初始化（`ManageServerInfo` 填 Manage 的 IP 与端口 9033） |
| `SetPlayerName(PlayerName)` | 成功后设置玩家名（房间内显示用，可随时改名） |
| 事件 `OnManageConnected` | 连接握手成功（登录流程完成后触发） |

前置：Manage 进程运行中、网络可达。失败：未连上 → `ConnectFailed` / 超时 → `Timeout`。

### 2. 查询房间列表

| 节点 | 说明 |
|------|------|
| `RequestRoomList()` | 拉取 Manage 当前全部房间（`OnSuccess(RoomList)` 含房间名/房主/人数/是否有密码/关卡） |

前置：已连接 Manage。房间密码不返回（仅 `bHasPassword` 标记）。

### 3. 创建房间（成为房主）

| 节点 | 说明 |
|------|------|
| `CreateMyRoom(RoomName, Password, MaxPlayers, LevelName)` | 建房；密码留空为公开房；`LevelName` 为初始关卡名 |

前置：已连接 + 不在任何房间。成功后：`OnMyRoomRoleChanged(Owner)`、`GetMyRoomID()` 有效、房间信息入缓存（`GetMyRoomInfo()`）。

### 4. 加入房间（成为成员）

| 节点 | 说明 |
|------|------|
| `PlayerJoinRoom(RoomID, Password)` | 加入指定房间；密码房必须匹配密码 |

前置：已连接 + 不在任何房间 + 房间未满员。失败：`RoomNotExist` / `WrongPassword` / `RoomFull` / `AlreadyInRoom`。

### 5. 创建副本（房主开 DS）

| 节点 | 说明 |
|------|------|
| `StartMyRoomDS()` | 房主拉起房间关联的 DS 副本进程（关卡取房间当前 `LevelName`，端口由 Manage 自动分配） |

前置：**房主** + 在房间内 + 副本未运行。副本状态观察：`GetMyRoomInfo().DSState` 变化 `None → Starting → Running`（推送自动维护，绑定 `OnMyRoomInfoChanged` 即可）。失败：成员调用 → `NotOwner`；副本已在运行 → `AlreadyRunning`。

### 6. 进入副本

| 节点 | 说明 |
|------|------|
| `JoinRoomDS()` | 跳转进入"我的房间"的关联副本（内部自动完成 `ClientTravel`） |

前置：在房间内 + 副本 `Running`。成功后：`GetMyDSPhase() == InDS`。副本被关闭/解散时自动退出副本态并收到推送。

### 7. 房间内操作（房主/成员权限见各节点）

| 节点 | 说明 | 权限 |
|------|------|------|
| `SendRoomMessage(Message)` | 房间聊天，全员（含自己）收到 `OnCustomMessageReceived`（`MessageType == "RoomChat"`，解析出 `SenderName`/`Content`） | 全员 |
| `ChangeMyRoomLevel(LevelName)` | 更换房间关卡；副本运行中拒绝（`AlreadyRunning`，须先停副本再换图） | 仅房主 |
| `KickPlayerFromMyRoom(TargetServerConnectionID)` | 踢出指定成员（ID 取自成员列表 `GetMyRoomInfo().Members[].ServerConnectionID`）；被踢者收到 `OnKickedFromRoom` 并断开副本 | 仅房主 |
| `StopMyRoomDS()` | 停止副本（房间保留，DSState 复位 `None`） | 仅房主 |
| `CloseMyRoom()` | 解散房间 + 杀副本；全员（除发起者）收到 `OnRoomClosed` | 仅房主 |

### 8. 状态查询与对账

| 节点/查询 | 说明 |
|-----------|------|
| `GetMyRoomID()` / `GetMyRoomRole()` / `GetMyDSPhase()` / `GetMyRoomInfo()` | 同步读取当前会话状态（空闲/房主/成员；副本阶段；房间详情缓存） |
| `RefreshMyRoomRole()` / `RefreshMyRoomInfo()` | 与 Manage 权威数据对账（断线期间变化兜底，如加入超时但实际成功） |
| 事件 `OnMyRoomRoleChanged` / `OnMyRoomInfoChanged` / `OnRoomUpdate` / `OnRoomClosed` / `OnKickedFromRoom` | 状态变化推送（内容变化才触发，绑定后自动维护 UI） |

### 失败处理约定

所有请求节点 `OnFail` 统一携带 `(AsyncID, Result, RoomError, Message)`：

- 未连接 Manage → `NotConnected`；请求超时 → `Timeout`；连接断开 → `ConnectionClosed`
- 本地前置校验未过（如成员调用房主操作）→ `Rejected` + `RoomError=NotOwner`
- 服务端拒绝（房间不存在/满员/密码错等）→ `Rejected` + 对应 `RoomError`

## 端口约定

| 端口 | 用途 |
|------|------|
| 9033 | Manage WebSocket 服务（登录后全部业务通信） |
| 9034 | Manage HTTP 状态服务（登录前探活，`GET /status`） |
| 7777–8000 | DS 端口分配范围（可在插件 `UXGWSMManageSettings` 配置） |

## 仓库内容

```
XGMultiPlayer/
├── XGMultiPlayer.uproject          ← UE 工程文件（打开即用）
├── Source/XGMultiPlayer/           ← 游戏模块源码（角色等）
├── Content/                        ← 地图（L_Lobby / L_Game_* / L_ConnectionTest）+ UI（Lobby / Room / ConnectionTest）
├── Config/                         ← 运行时配置
├── Docs/                           ← 设计文档（房间系统 / 状态机 / 测试验收 / 底层通讯说明）
├── Bat/                            ← 脚本（Dev 开发时 / Deploy 部署时 / Package 打包）
└── README.md / README_CN.md        ← 本说明
```

## 文档

插件/工程的协议设计与详细文档（房间系统设计方案、状态机设计、测试验收清单等）不随本仓库公开，如有需要请联系作者获取。

## 相关链接

- **FAB 商城**：[XGWebSocketMessage](https://www.fab.com/zh-cn/listings/17f3be65-ceb5-4da0-b546-161e7e75012d)（插件本体）
- **插件代码仓库**：[github.com/liuhuagang/XGWebSocketMessage](https://github.com/liuhuagang/XGWebSocketMessage)

## 联系方式

如果有任何插件或工程问题，请联系我。

- QQ：709777172
- 邮箱：709777172@qq.com
- Bilibili：[虚幻小刚](https://space.bilibili.com/8383085)
