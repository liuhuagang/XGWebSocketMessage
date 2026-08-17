XGMultiPlayer 开发时（本地联调）启动脚本说明
====================================================
本目录脚本仅用于【开发时】本地联调，exe 均通过相对路径
（%~dp0..\..\Package\）指向仓库 Package\ 下的已打包产物，
不依赖启动时的工作目录；脚本自带 exe 存在检查与错误提示。

exe 路径（相对本目录）：
   Manage: ..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe
   DS:     ..\..\Package\Server\WindowsServer\XGMultiPlayerServer.exe
           （独立 Server 包；当前缺失时自动复用 Manage 包同款 exe）
   Client: ..\..\Package\Client\Windows\XGMultiPlayer.exe

角色启动表

  角色         关卡            端口    脚本
  ───────────  ───────────    ──────  ──────────────────
  Manage       L_Manage       9033    Start_Manage.bat
  Manage #2    L_Manage       8033    Start_Manage_2.bat
  Manage #3    L_Manage       7033    Start_Manage_3.bat
  DS(Fire)     L_Game_Fire    7777    Start_DS_Fire.bat
  DS(Stone)    L_Game_Stone   7778    Start_DS_Stone.bat
  DS(Water)    L_Game_Water   7779    Start_DS_Water.bat
  客户端        L_Lobby        —      Start_Client.bat

启动顺序：先 Manage，再 DS，最后客户端。

注意事项

  ① Manage 必须带 -Manage 参数（已写入脚本），用于区分 DS 进程。
  ② Manage 监听 9033、DS 端口分配范围 7777-8000，可在项目设置
     (XGWebSocketMessage > Manage / Game) 中修改。
  ③ DS 手动指定 -Port 用于调试；正式部署时由 Manage 自动分配。
  ④ 客户端当前缺 Client 打包产物：需先执行 ..\Package_Client.bat
     打包 Client 目标到 Package\Client\Windows\，或用编辑器直接运行。
  ⑤ 本机联调默认 ManageIP/PublicIP=127.0.0.1（已写入脚本）。

打包（部署/联调前先执行）：
   ..\Package_Client.bat   打包客户端（XGMultiPlayer.exe）
   ..\Package_Manage.bat   打包服务端（XGMultiPlayerServer.exe，兼 DS）
