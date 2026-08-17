# XGWebSocketMessage — UE5 Multiplayer Plugin & Companion Project

[English](README.md) · [简体中文](README_CN.md)

> 📌 **This repository is the companion project of the XGWebSocketMessage plugin** (XGMultiPlayer), used to demo and get started with the plugin's two usage paths:
> ① **Low-level communication** (Server ↔ Client direct); ② **Upper-layer room protocol** (complete room system with Manage server + player client).
> **Get the plugin itself from the FAB store**; this repository does not contain the plugin source.

## What is this

**XGWebSocketMessage** is an Unreal Engine 5 multiplayer networking plugin (server + client) built on UE5's built-in WebSocket, allowing communication between Unreal projects, with connection handshake and heartbeat keep-alive (3 s heartbeat / 10 s timeout).

**XGMultiPlayer** is the plugin's companion project: a single UE project with **three runtime roles** — **Manage** (management server), **Client** (player) and **DS** (game replica) — fully demonstrating both usage paths:

- **Path 1 · Low-level communication**: the `L_ConnectionTest` map ships with server/client panels to verify direct message passing without the room system
- **Path 2 · Upper-layer room protocol**: lobby → create/join room → start replica → enter replica → chat → owner permissions → dissolve, out of the box

## Version Compatibility (Important)

| Plugin version | Low-level (Path 1) | Room protocol (Path 2) |
|----------------|:---:|:---:|
| **2.1** (current FAB release, 3 modules) | ✅ | ❌ unavailable |
| **New version** (5 modules, incl. upper-layer modules) | ✅ | ✅ |

> ⚠️ The lobby/room/chat UI of this project depends on the plugin's **upper-layer modules** (`XGWebSocketGame` / `XGWebSocketManage`) async blueprint nodes:
> - With the **2.1** plugin installed, only `L_ConnectionTest` (Path 1) works;
> - The room system (Path 2) requires the **new plugin version** (with upper-layer modules, available on FAB once released); keep the plugin and project versions matched.

## Features

- **Single project, three roles** — Manage / Client / DS run from the same project with different launch parameters
- **Room system** — create / join / leave / kick / dissolve; password protection; capacity limits
- **Owner permissions** — destructive operations (kick / close room / start-stop replica / change level) require the room owner, authoritatively validated by Manage
- **Dynamic DS lifecycle** — replicas start/stop on demand; ports auto-allocated (7777–8000); closing a replica keeps the room
- **Disconnect linkage** — owner disconnect → room auto-dissolves + replica killed; member disconnect → removed; DS disconnect → replica state reset
- **Room chat** — `SendRoomMessage` broadcasts to all members (sender name filled by Manage)
- **Room level switching** — `ChangeMyRoomLevel`, rejected while the replica is running
- **Protocol** — JSON → Base64 → binary WebSocket frames; protocol version negotiation (mismatched old clients rejected at registration)

## Architecture

```
Manage (management server)
 Rooms / DS / players centralized · authoritative validation · HTTP status service
 WebSocket 9033 · HTTP 9034
      |
 ┌────┼────────────────┐
 v    v                v
Client Client N        DS (game replica process)
lobby/room/replica UI  auto-launched by Manage
async blueprint nodes  ports auto-allocated 7777-8000
```

| Role | Process | Launch flag | Responsibility |
|------|---------|-------------|----------------|
| Manage | `XGMultiPlayerServer.exe` | `-Manage` | Rooms/DS/players centralized, authoritative checks, DS launch, HTTP status |
| Client | `XGMultiPlayer.exe` | — | Lobby, room list, room/replica UI, chat |
| DS | `XGMultiPlayerServer.exe` | `-server` | Game replica; registers to Manage, serves players |

## Requirements

- **Unreal Engine 5.8** (Windows)
- **Visual Studio 2022** (C++ game development workload, needed to compile the project)
- Windows 11

## Quick Start (from zero to running)

1. **Install the plugin**: get XGWebSocketMessage from the FAB store (see "Version Compatibility" above)
2. **Open the project**: double-click `XGMultiPlayer.uproject`; confirm recompilation when the editor prompts (first compile takes a few minutes)
3. **Package the server**: run `Bat\Package_Manage.bat` to produce `XGMultiPlayerServer.exe` (also used as the DS executable)
4. **Start Manage**: run `Bat\Dev\Start_Manage.bat` (listens on WS 9033 / HTTP 9034)
5. **Start a client**: run `Bat\Dev\Start_Client.bat` (or run the `L_Lobby` map from the editor)
6. **Verify Path 1**: run the `L_ConnectionTest` map from the editor; connect server/client panels and exchange messages
7. **Verify Path 2**: create a room in the lobby → join with another client → owner starts the replica → member enters it → room chat → owner dissolves

> All `Bat/` scripts locate the executables via relative paths (`%~dp0`) — just double-click them, no working-directory requirements.
> Command-line build (optional): `<UE5.8Install>\Engine\Build\BatchFiles\Build.bat XGMultiPlayerEditor Win64 Development -Project="<repo path>\XGMultiPlayer.uproject" -WaitMutex`

## Typical Flow: Node Operation Guide

> All nodes below live under the blueprint categories `XGWebSocketMessage|Player|Room` (actions) and `XGWebSocketMessage|Player` (queries).
> They are async nodes: `Then` fires when the request is sent; `OnSuccess` on success; `OnFail` on failure (carries `AsyncID / Result / RoomError / Message`).

### Prerequisites

1. Plugin version matched (see "Version Compatibility")
2. Manage process running (`Bat\Dev\Start_Manage.bat`, listening on WS 9033)
3. Project compiled; the client can reach the Manage machine (localhost for local testing)

### 1. Connect to Manage (login)

| Node / Event | Description |
|--------------|-------------|
| `ConnectToManage(ManageServerInfo)` | Connects to Manage and completes player role initialization (`ManageServerInfo` = Manage IP + port 9033) |
| `SetPlayerName(PlayerName)` | Sets the player name after connecting (shown in rooms; can be changed anytime) |
| Event `OnManageConnected` | Connection handshake succeeded (fires after the login flow completes) |

Prerequisite: Manage running and reachable. Failure: `ConnectFailed` / `Timeout`.

### 2. Query the room list

| Node | Description |
|------|-------------|
| `RequestRoomList()` | Fetches all rooms from Manage (`OnSuccess(RoomList)` with name/owner/capacity/has-password/level) |

Prerequisite: connected. Room passwords are never returned (only the `bHasPassword` flag).

### 3. Create a room (become the owner)

| Node | Description |
|------|-------------|
| `CreateMyRoom(RoomName, Password, MaxPlayers, LevelName)` | Creates a room; empty password = public room; `LevelName` is the initial level |

Prerequisite: connected + not in any room. On success: `OnMyRoomRoleChanged(Owner)`, `GetMyRoomID()` valid, room info cached (`GetMyRoomInfo()`).

### 4. Join a room (become a member)

| Node | Description |
|------|-------------|
| `PlayerJoinRoom(RoomID, Password)` | Joins the given room; password required for protected rooms |

Prerequisite: connected + not in any room + room not full. Failure: `RoomNotExist` / `WrongPassword` / `RoomFull` / `AlreadyInRoom`.

### 5. Start the replica (owner launches the DS)

| Node | Description |
|------|-------------|
| `StartMyRoomDS()` | Owner launches the room's linked DS process (level = room's current `LevelName`, port auto-allocated by Manage) |

Prerequisite: **owner** + in room + replica not running. Observe state: `GetMyRoomInfo().DSState` goes `None → Starting → Running` (push-maintained; bind `OnMyRoomInfoChanged`). Failure: member call → `NotOwner`; already running → `AlreadyRunning`.

### 6. Enter the replica

| Node | Description |
|------|-------------|
| `JoinRoomDS()` | Travels into my room's linked replica (does the `ClientTravel` internally) |

Prerequisite: in room + replica `Running`. On success: `GetMyDSPhase() == InDS`. Leaving the replica state is automatic when the replica is stopped/dissolved (via push).

### 7. In-room operations (permission per node)

| Node | Description | Permission |
|------|-------------|------------|
| `SendRoomMessage(Message)` | Room chat, broadcast to all members (including the sender via `OnCustomMessageReceived`, `MessageType == "RoomChat"`, parse `SenderName`/`Content`) | Everyone |
| `ChangeMyRoomLevel(LevelName)` | Changes the room level; rejected while the replica is running (`AlreadyRunning` — stop the replica first) | Owner only |
| `KickPlayerFromMyRoom(TargetServerConnectionID)` | Kicks the given member (ID from `GetMyRoomInfo().Members[].ServerConnectionID`); the kicked player gets `OnKickedFromRoom` and disconnects from the replica | Owner only |
| `StopMyRoomDS()` | Stops the replica (room is kept, DSState resets to `None`) | Owner only |
| `CloseMyRoom()` | Dissolves the room + kills the replica; all members (except the initiator) get `OnRoomClosed` | Owner only |

### 8. State queries & reconciliation

| Node / Query | Description |
|--------------|-------------|
| `GetMyRoomID()` / `GetMyRoomRole()` / `GetMyDSPhase()` / `GetMyRoomInfo()` | Synchronous reads of the current session state (idle/owner/member; DS phase; cached room info) |
| `RefreshMyRoomRole()` / `RefreshMyRoomInfo()` | Reconciles with Manage's authoritative data (fallback for changes missed while disconnected) |
| Events `OnMyRoomRoleChanged` / `OnMyRoomInfoChanged` / `OnRoomUpdate` / `OnRoomClosed` / `OnKickedFromRoom` | Push updates on state changes (fire only on actual changes; bind once and let the UI update itself) |

### Failure handling conventions

Every request node's `OnFail` carries `(AsyncID, Result, RoomError, Message)`:

- Not connected → `NotConnected`; request timeout → `Timeout`; connection closed → `ConnectionClosed`
- Local pre-check failed (e.g. member calling an owner operation) → `Rejected` + `RoomError=NotOwner`
- Server-side rejection (room missing/full/wrong password etc.) → `Rejected` + matching `RoomError`

## Port Conventions

| Port | Purpose |
|------|---------|
| 9033 | Manage WebSocket service (all business communication after login) |
| 9034 | Manage HTTP status service (pre-login probe, `GET /status`) |
| 7777–8000 | DS port allocation range (configurable in the plugin's `UXGWSMManageSettings`) |

## Repository Contents

```
XGMultiPlayer/
├── XGMultiPlayer.uproject          ← UE project file (open and go)
├── Source/XGMultiPlayer/           ← game module source (character etc.)
├── Content/                        ← maps (L_Lobby / L_Game_* / L_ConnectionTest) + UI (Lobby / Room / ConnectionTest)
├── Config/                         ← runtime configuration
├── Docs/                           ← design docs (room system / state machine / test checklist / low-level guide)
├── Bat/                            ← scripts (Dev / Deploy / Package)
└── README.md / README_CN.md        ← this guide
```

## Documentation

The protocol/design documents (room system design, state machine design, test acceptance checklist, etc.) are not published with this repository; contact the author if needed.

## Links

- **FAB store**: [XGWebSocketMessage](https://www.fab.com/zh-cn/listings/17f3be65-ceb5-4da0-b546-161e7e75012d) (the plugin itself)
- **Plugin code repository**: [github.com/liuhuagang/XGWebSocketMessage](https://github.com/liuhuagang/XGWebSocketMessage)

## Contact

If you have any questions about the plugin or the project, please contact me.

- QQ: 709777172
- Email: 709777172@qq.com
- Bilibili: [虚幻小刚](https://space.bilibili.com/8383085)
