<p align="center">
  <img src="https://img.shields.io/badge/AWS-CodeDeploy-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/.NET%208-Server-512BD4?style=for-the-badge&logo=dotnet&logoColor=white" alt=".NET 8"/>
  <img src="https://img.shields.io/badge/C%23-Application-239120?style=for-the-badge&logo=csharp&logoColor=white" alt="C#"/>
  <img src="https://img.shields.io/badge/CI%2FCD-CodePipeline-2088FF?style=for-the-badge&logo=amazonaws&logoColor=white" alt="CI/CD"/>
</p>

# 🌐 .NET 8 HTTP Microservice — AWS CodeDeploy Ready

> **A lightweight, production-ready .NET 8 HTTP server deployed to AWS EC2 Auto Scaling Groups via a fully automated CI/CD pipeline using AWS CodePipeline, CodeBuild, and CodeDeploy.**

This project implements a minimal HTTP listener service built with C# and .NET 8 that serves random **AWS S3 facts** on port `8002`. It is designed as the **application component** of a larger [Multi-Environment CI/CD Infrastructure](https://github.com/yosefzaher/CI-CD-Project) project. The application is compiled, packaged, and deployed automatically to EC2 instances using AWS CodeBuild and CodeDeploy, with zero-downtime rolling deployments managed through a `systemd` service unit.

---

## 📐 Architecture

![Architecture Diagram](./images/diagram.png)

### Deployment Flow

1. **Developer** pushes code to the GitHub repository (branch-specific: `main` for Production, `qc` for QC).
2. **AWS CodePipeline** detects the push and triggers the pipeline.
3. **AWS CodeBuild** compiles the .NET 8 application using `dotnet publish` (as defined in `buildspec.yml`), targeting `linux-x64`.
4. **Build Artifacts** (compiled binaries, `appspec.yml`, and deployment scripts) are packaged and stored in an **S3 bucket**.
5. **AWS CodeDeploy** picks up the artifact and performs a rolling deployment across the **EC2 Auto Scaling Group**, executing lifecycle hooks:
   - `ApplicationStop` → Stops the running service via `systemctl stop`.
   - `BeforeInstall` → Pre-installation placeholder (no-op).
   - `AfterInstall` → Creates/updates a `systemd` service unit and enables it.
   - `ApplicationStart` → Restarts the HTTP server via `systemctl restart`.
6. **Network Load Balancer** routes incoming traffic on port `80` to healthy instances on port `8002`.

---

## ✨ Key Features

- **🚀 Lightweight HTTP Server** — Minimal C# `HttpListener` serving responses on port `8002` with no external framework dependencies.
- **📦 Self-Contained Deployment** — Compiled as a framework-dependent binary for `linux-x64`, deployed with all necessary artifacts.
- **🔄 Zero-Downtime Deployments** — Rolling deployments via AWS CodeDeploy with `systemd` service lifecycle management.
- **⚙️ Systemd Integration** — Application runs as a managed `systemd` service (`http_server.service`) with auto-restart on failure.
- **🏗️ CI/CD Pipeline Ready** — Includes `buildspec.yml` for CodeBuild and `appspec.yml` for CodeDeploy out of the box.
- **🌍 Multi-Environment Support** — Works seamlessly with QC and Production environments provisioned by the companion infrastructure project.
- **📋 CodeDeploy Lifecycle Hooks** — Full suite of deployment hooks (BeforeInstall, AfterInstall, ApplicationStart, ApplicationStop) for controlled deployments.

---

## 🛠️ Tech Stack

| Category               | Technology                                                     |
|------------------------|----------------------------------------------------------------|
| **Language**           | C# (.NET 8)                                                    |
| **Runtime**            | ASP.NET Core Runtime 8.0                                       |
| **Server**             | `System.Net.HttpListener` (port 8002)                          |
| **OS (Target)**        | Ubuntu 24.04 LTS (linux-x64)                                  |
| **CI/CD - Build**      | AWS CodeBuild (dotnet 8.0 runtime)                             |
| **CI/CD - Deploy**     | AWS CodeDeploy (EC2/On-premises, rolling deployment)           |
| **CI/CD - Pipeline**   | AWS CodePipeline                                               |
| **Artifact Storage**   | Amazon S3                                                      |
| **Compute**            | EC2 Auto Scaling Group (t3.micro)                              |
| **Load Balancing**     | Network Load Balancer (TCP :80 → :8002)                        |
| **Process Manager**    | systemd (`http_server.service`)                                |
| **Source Control**     | GitHub                                                         |

---

## 📁 Project Structure

```
C#_HTTP_Server/
│
├── 📄 README.md              # Project documentation (this file)
├── 📄 main.cs                # 🌐 HTTP server source code (C# HttpListener)
├── 📄 server.csproj          # ⚙️ .NET 8 project configuration
├── 📄 buildspec.yml          # 🏗️ AWS CodeBuild build specification
├── 📄 appspec.yml            # 🚀 AWS CodeDeploy deployment specification
│
└── 📂 scripts/               # CodeDeploy lifecycle hook scripts
    ├── before_install.sh     # 🔹 Pre-installation step (no-op placeholder)
    ├── after_install.sh      # 🔹 Creates systemd service unit & enables it
    ├── start.sh              # ▶️ Starts/restarts the HTTP server service
    └── stop.sh               # ⏹️ Gracefully stops the HTTP server service
```

### File Descriptions

| File                         | Purpose                                                                                            |
|------------------------------|----------------------------------------------------------------------------------------------------|
| `main.cs`                    | HTTP listener on port 8002; returns the current time and a random AWS S3 fact on each request      |
| `server.csproj`              | .NET 8 project file targeting `net8.0` with `Program` as the startup object                        |
| `buildspec.yml`              | CodeBuild instructions: installs .NET 8, publishes the app for `linux-x64`, packages artifacts     |
| `appspec.yml`                | CodeDeploy specification: deploys files to `/home/ubuntu/http-srv` and runs lifecycle hook scripts  |
| `scripts/before_install.sh`  | Placeholder for pre-deployment tasks (currently a no-op)                                           |
| `scripts/after_install.sh`   | Creates a `systemd` service unit file at `/etc/systemd/system/http_server.service` and enables it  |
| `scripts/start.sh`           | Restarts the `http_server.service` to pick up the newly deployed binaries                          |
| `scripts/stop.sh`            | Gracefully stops the running `http_server.service` (tolerates failure if not running)               |

---

## 📋 Prerequisites

| Tool            | Version   | Purpose                                           |
|-----------------|-----------|---------------------------------------------------|
| **.NET SDK**    | 8.0       | Build and publish the application locally          |
| **AWS CLI**     | v2+       | Interact with AWS services                         |
| **Git**         | Latest    | Source control and CI/CD trigger                   |

### AWS Infrastructure (Required)

This application is designed to be deployed onto infrastructure provisioned by the companion [**CI/CD Infrastructure Project**](https://github.com/yosefzaher/CI-CD-Project). Ensure the following are in place:

- ✅ **EC2 Auto Scaling Group** — With instances running Ubuntu 24.04 and the CodeDeploy Agent installed.
- ✅ **ASP.NET Core Runtime 8.0** — Installed on EC2 instances (handled by the infrastructure's `build.sh` user-data script).
- ✅ **AWS CodeDeploy Agent** — Running on all target EC2 instances.
- ✅ **AWS CodePipeline** — Configured to pull from this GitHub repository.
- ✅ **IAM Instance Profile** — With permissions for CodeDeploy and S3 artifact access.
- ✅ **Network Load Balancer** — Forwarding TCP traffic from port `80` to port `8002`.

---

## ⚙️ Setup & Installation

### 1. Configure AWS Credentials

```bash
# Configure the AWS CLI with your credentials
aws configure

# You will be prompted for:
#   AWS Access Key ID:      <your-access-key>
#   AWS Secret Access Key:  <your-secret-key>
#   Default region name:    us-east-1
#   Default output format:  json
```

Verify your configuration:

```bash
aws sts get-caller-identity
```

### 2. Clone the Repository

```bash
git clone https://github.com/yosefzaher/dot-net-http-server.git
cd dot-net-http-server
```

### 3. Build & Run Locally

```bash
# Restore dependencies and build
dotnet build

# Run the HTTP server locally
dotnet run

# The server will start listening on http://localhost:8002/
# Test with:
curl http://localhost:8002/
```

**Expected Response:**
```
14:32:05.1234567 - V2 - Scale storage resources to meet fluctuating needs with 99.999999999% (11 9s) of data durability.
```

### 4. Publish for Linux Deployment

```bash
# Publish a Release build targeting linux-x64
dotnet publish -c Release --self-contained=false --runtime linux-x64
```

The published artifacts will be in `bin/Release/net8.0/linux-x64/`.

---

## 🔄 CI/CD Pipeline Workflow

### Pipeline Trigger

Pushing code to the GitHub repository triggers AWS CodePipeline automatically.

```
┌──────────────────────────────────────────────────────────────────┐
│                        CI/CD PIPELINE                            │
│                                                                  │
│  GitHub Push                                                     │
│       │                                                          │
│       ▼                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌────────────────────┐  │
│  │  CodeBuild   │───▶│  CodeDeploy  │───▶│ EC2 Auto Scaling   │  │
│  │ dotnet build │    │  appspec.yml │    │  (rolling deploy)  │  │
│  └──────────────┘    └──────────────┘    └────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Build Stage (`buildspec.yml`)

| Phase       | Action                                                                                    |
|-------------|-------------------------------------------------------------------------------------------|
| **Install** | Installs .NET 8.0 runtime in the CodeBuild environment                                    |
| **Build**   | Runs `dotnet publish -c Release --self-contained=false --runtime linux-x64`               |
| **Artifacts** | Packages `scripts/*`, `appspec.yml`, and compiled binaries from `bin/Release/net8.0/linux-x64/*` |

> **Note:** `discard-paths: yes` flattens the artifact structure so all files are at the root level for CodeDeploy.

### Deploy Stage (`appspec.yml`)

CodeDeploy copies all artifacts to `/home/ubuntu/http-srv/` and executes lifecycle hooks in order:

```
ApplicationStop       →  stop.sh           →  systemctl stop http_server.service
       │
       ▼
BeforeInstall         →  before_install.sh →  (no-op)
       │
       ▼
  [File Copy: / → /home/ubuntu/http-srv/]
       │
       ▼
AfterInstall          →  after_install.sh  →  Create systemd unit + daemon-reload + enable
       │
       ▼
ApplicationStart      →  start.sh          →  systemctl restart http_server.service
```

### Systemd Service Unit

The `after_install.sh` script creates the following service at `/etc/systemd/system/http_server.service`:

```ini
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
```

> The `Restart=always` directive ensures the service auto-recovers from crashes.

---

## 🔮 Future Enhancements

- **Health Check Endpoint** — Add a dedicated `/health` endpoint for more robust NLB health checks.
- **Structured Logging** — Integrate Serilog or NLog for structured, queryable logs shipped to CloudWatch.
- **HTTPS Support** — Add TLS termination at the load balancer level with ACM certificates.
- **Configuration Management** — Externalize config (port, facts data) using environment variables or AWS Parameter Store.
- **Containerization** — Dockerize the application for deployment to ECS/Fargate.
- **API Expansion** — Extend the service with additional endpoints and REST API patterns.
- **Automated Testing** — Add unit and integration tests to the CodeBuild pipeline.
- **Blue/Green Deployments** — Upgrade from rolling to blue/green deployment strategy for zero-risk releases.

---

## 📎 Related Projects

| Project | Description |
|---------|-------------|
| [**AWS Multi-Environment CI/CD Infrastructure**](https://github.com/yosefzaher/CI-CD-Project) | Bash-based IaC scripts that provision the entire AWS infrastructure (VPC, ASG, NLB, DNS) this application runs on. |

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

<p align="center">
  <b>Built with ❤️ by <a href="https://github.com/yosefzaher">Yosef Zaher</a></b>
</p>
