XGMultiPlayer 脚本目录总说明
====================================================
本目录按使用场景划分，全部脚本用相对路径（%~dp0）定位，
不依赖启动时的工作目录。

目录结构

  Bat\
  ├── Dev\                  【开发时】本地联调启动脚本
  │   ├── Start_Manage.bat / Start_Manage_2.bat / Start_Manage_3.bat
  │   ├── Start_DS_Fire.bat / Start_DS_Stone.bat / Start_DS_Water.bat
  │   ├── Start_Client.bat
  │   └── Readme.txt        开发时使用说明
  ├── Deploy\               【实际部署时】生产环境启动脚本
  │   ├── Deploy_Manage.bat
  │   ├── Deploy_DS_Fire.bat
  │   ├── Deploy_Client.bat
  │   └── Readme.txt        部署时使用说明（含 IP/端口/防火墙）
  ├── Package_Client.bat    打包客户端 -> Package\Client
  ├── Package_Manage.bat    打包服务端 -> Package\Manage（兼 DS exe）
  └── Readme.txt            本说明

使用流程

  1. 打包（首次或代码变更后）：运行 Package_Client.bat / Package_Manage.bat
  2. 开发时：进入 Dev\ 目录，按 Readme.txt 启动 Manage → DS → 客户端
  3. 部署时：将 Package\ 产物与 Deploy\ 脚本一并拷贝到服务器，
     按 Deploy\Readme.txt 启动；公网 IP 用命令行参数覆盖

exe 路径约定（统一以仓库根 Package\ 为基准，脚本内用相对路径自动定位）

  Manage: Package\Manage\WindowsServer\XGMultiPlayerServer.exe
  DS:     Package\Server\WindowsServer\XGMultiPlayerServer.exe
          （独立 Server 包；当前缺失时自动复用 Manage 包同款 exe）
  Client: Package\Client\Windows\XGMultiPlayer.exe

端口约定

  9033  Manage WebSocket 服务
  9034  Manage HTTP 状态服务（登录前探活）
  7777-8000  DS 端口分配范围（正式部署由 Manage 自动分配）

注意事项

  ① 打包脚本的 ENGINE 路径（D:\UES\UES_5.8.0）按本机安装位置修改。
  ② 所有脚本仅英文注释，避免 cmd 编码问题；说明文档用中文。
  ③ Manage 必须带 -Manage 参数（已写入脚本），用于区分 DS 进程。
