#!/bin/bash

# إنشاء ملف الخدمة بالمسار الجديد الصحيح
cat >/etc/systemd/system/http_server.service <<EOL
[Unit]
Description=.NET HTTP Server Work on Port 8002

[Service]
WorkingDirectory=/home/ubuntu/http-srv/
ExecStart=/usr/bin/dotnet /home/ubuntu/http-srv/server.dll
SyslogIdentifier=dot-net-server
Environment=DOTNET_CLI_HOME=/tmp
User=ubuntu
Restart=always

[Install]
WantedBy=multi-user.target
EOL


systemctl daemon-reload
systemctl enable http_server.service