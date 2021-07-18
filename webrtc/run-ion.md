---
title: 如何运行PION/ION(分布式流媒体系统)
description:
toc: true
authors: 
  - kangshaojun
date: '2021-04-24T13:11:22+08:00'
lastmod: '2021-04-24T13:11:22+08:00'
---

如何运行PION/ION(分布式流媒体系统).

<!--more-->


相信很多小伙伴不知道如何将PION/ION项目跑起来，这里整理了一些具体步骤，希望能帮助到大家。

### 依赖基础环境
1. nats.io
2. redis
3. Golang (latest version)

#### 1. 安装 Nats.io
MacOS
```
> brew update
> brew install nats-server
```
Windows
```
> choco install nats-server
```
Linux
```
> curl -L https://github.com/nats-io/nats-server/releases/download/v2.0.0/nats-server-v2.0.0-linux-amd64.zip -o nats-server.zip

> unzip nats-server.zip -d nats-server
Archive:  nats-server.zip
   creating: nats-server-v2.0.0-linux-amd64/
  inflating: nats-server-v2.0.0-linux-amd64/README.md
  inflating: nats-server-v2.0.0-linux-amd64/LICENSE
  inflating: nats-server-v2.0.0-linux-amd64/nats-server

> sudo cp nats-server/nats-server-v2.0.0-linux-amd64/nats-server /usr/bin
```

#### 2. 安装 Redis
MacOS
```
> brew update
> brew install redis
```
Windows
```
> choco install redis-64
```
Ubuntu
```
> sudo apt install redis-server
```
#### 3. 安装 golang
MacOS
```
> brew update
> brew install go
```
Windows
```
> choco install golang
```
Linux
```
> cd ~
> wget -c https://dl.google.com/go/go1.16.3.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
> export PATH=$PATH:/usr/local/go/bin
> source ~/.profile
```
检查 go 版本
```
> go version
```
```
output
go version go1.16.3 linux/amd64
```


### 开始构建
环境准备好后我们可以开始使用源码来构建, 从github上克隆源码下来.
#### 三个项目分别是
1. ion
2. ion-app-web
3. ion-app-flutter

创建一个目录用来存放这三个项目
```
mkdir ionapp
cd ionapp
```
#### 1. 下载 ion 源码
```
> git clone https://github.com/pion/ion.git
```
#### 2. 下载 ion-app-web  源码
```
> git clone https://github.com/pion/ion-app-web.git
```
#### 3. 下载 ion-app-flutter  源码
```
> git clone https://github.com/pion/ion-app-flutter.git
```

#### 现在我们把三个项目下载下来了，然后我们开始构建项目.

### 从源码构建项目
```
> cd ion
> make build
```
这里会下载所有依赖文件，然后开始构建，生成的文件放入bin目录。
```
> cd bin
```
你将会看到4个文件, avp, biz, islb 和 sfu. \
确定有这几个文件后启动它。
**启动所有服务**
```
//make sure you back into the ion root folder before you run this
> ./scripts/all start
```
**停止所有服务**
```
> ./scripts/all stop
```
现在服务端的所有服务已经启动, 然后我们再运行一下前端的项目。
### 启动 webapp
```
> cd ion-app-web
> npm i
```
等待它安装完成
```
> npm start
```
它会把它前端web页面，填写房间号与用户名即可以进入房间。
### 启动 flutter app
首先
```
> ./scripts/project_tools.sh create
```
```
> cd ion-app-flutter
```
Android/IOS
```
> flutter run
```
MacOS
```
> flutter run -d macos
```
Web
```
> flutter run -d chrome
```
flutter 2.0的web 和 desktop 目前已经是stable版本了, 你可以将此应用运行在桌面移动端以及Web上了.

### 后记
希望这篇文章能帮到你如何运行PION/ION项目。

## WebRTC课程
WebRTC 一对一 多对多 P2P Mesh SFU 流媒体 视频会议课程等请关注
[https://www.kangshaojun.com](https://www.kangshaojun.com)
