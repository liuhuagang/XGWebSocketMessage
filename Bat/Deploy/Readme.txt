XGMultiPlayer 实际部署（生产环境）启动脚本说明
====================================================
本目录脚本用于【实际部署时】在生产服务器上启动各角色。
与 Dev 目录的区别：
  ① 带公网 IP 参数（ManageIP/PublicIP），默认 47.108.203.10，
     可通过命令行参数覆盖：Deploy_XXX.bat [ManageIP] [PublicIP]；
  ② exe 同样使用相对路径（%~dp0..\..\Package\）定位，部署时
     将整个 Package\ 产物目录与本脚本一起拷贝到服务器，
     保持相对结构即可运行，无需修改任何绝对路径。

exe 路径（相对本目录，与 Dev 一致）：
   Manage: ..\..\Package\Manage\WindowsServer\XGMultiPlayerServer.exe
   DS:     ..\..\Package\Server\WindowsServer\XGMultiPlayerServer.exe
           （独立 Server 包；当前缺失时自动复用 Manage 包同款 exe）
   Client: ..\..\Package\Client\Windows\XGMultiPlayer.exe

角色启动表

  角色         关卡            端口    脚本                      参数
  ───────────  ───────────    ──────  ────────────────────────  ───────────────────
  Manage       L_Manage       9033    Deploy_Manage.bat         [PublicIP]
  DS(Fire)     L_Game_Fire    7777    Deploy_DS_Fire.bat        [ManageIP] [PublicIP]
  客户端        L_Lobby        —      Deploy_Client.bat         [PublicIP]

启动顺序：先 Manage，再 DS，最后客户端。

注意事项

  ① Manage 必须带 -Manage 参数（已写入脚本），用于区分 DS 进程。
  ② 正式部署时 DS 通常由 Manage 自动拉起（端口自动分配 7777-8000），
     Deploy_DS_Fire.bat 仅用于手动/独立启动调试。
  ③ 服务器需开放端口：9033(WS) / 9034(HTTP) / 7777-8000(DS)，
     并配置公网防火墙放行；Manage 需公网 IP（-PublicIP）。
  ④ Manage 的 -ManageName 与端口如需调整，直接修改对应脚本。
  ⑤ 打包命令在 Bat\ 根目录：Package_Client.bat / Package_Manage.bat。
