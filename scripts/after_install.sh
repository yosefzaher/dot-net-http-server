#!/bin/bash

cat >/etc/systemd/system/http_server.service <<EOL
[Unit]
Description=.NET HTTP Server Work on Port 8002

[Service]
ExecStart=/usr/bin/dotnet /home/ubuntu/http-srv/bin/Release/net8.0/linux-x64/server.dll
SyslogIdentifier=dot-net-server
Environment=DOTNET_CLI_HOME=/tmp


[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload