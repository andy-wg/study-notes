---
author: "亢少军"
date: 2021-06-21
linktitle: ION-SFU架构与模块
title: ION-SFU架构与模块
featuredImage: "images/pionion.png"
description: "ION-SFU架构与模块"
---

## ION-SFU架构与模块

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210619141538290.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)
上面给一个简单架构图，很多细节表示不出来，需要看代码。

## 1、简介
得益于GO，ion-sfu整体代码精简，拥有极高的开发效率。

结合现有SDK使用，可以避免很多坑：ion-sdk-js等。

ion-sfu基于pion/webrtc，所以代码风格偏标准webrtc，比如：PeerConnection

因为是使用了标准API，熟悉了之后很容易看懂其他工程，比如：ion-sdk-go/js/flutter。

这样从前到后，整体门槛都降低了。

## 2、工程组织
这里给出主要模块列表
```
├── Makefile //用来编译二进制和grpc文件
├── bin //编译好的二进制目录
├── cmd
│   └── signal //包含三个主文件 grpc、jsonrpc、allrpc
├── config.toml //配置文件
├── examples //网页示例目录
├── pkg
    ├── buffer //buffer包，用于缓存包
    ├── logger //日志
    ├── middlewares //中间件，主要是支持自定义datachannel
    ├── relay //中继
    ├── sfu //sfu主模块，包含router、session、peer等
    ├── stats //状态统计
    └── twcc //transport-cc
```
ion-sfu使用方式有两种：

作为服务使用，比如编译带grpc或jsonrpc信令的ion-sfu，然后再做一个自己的信令服务（推荐ion分布式套装），远程调用即可。
作为包使用，import导入，然后做二次开发；此时抛弃了cmd下边的信令层，只需导入pkg/sfu下边的包即可，然后自行定制信令层，可以在sfu、session、peer层面，通过继承接口定制自己的业务；比较复杂。
```
import (
	sfu "github.com/pion/ion-sfu/pkg/sfu"
)
```
## 3、信令层
信令代码和主程序在一起，在cmd/signal/下边

支持jsonrpc，主要处理逻辑在：
```
func (p *JSONSignal) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) {
```
支持grpc，主要处理逻辑在：
```
func (s *SFUServer) Signal(stream pb.SFU_SignalServer) error {
```
而allrpc，是jsonrpc和grpc的合体封装，运行时会进入上面两个函数
信令很简单：
```
join：加入一个session。
description：发起offer或回复answer，用于协商和重协商。
trickle：发送trickle candidate。
```
另外，出于简单考虑，一些信令和事件，直接走datachannel了，比如：大小流切换、声音检测、自定义信令等

## 4、媒体层
媒体层的主要模块
```
├── audioobserver.go //声音检测
├── datachannel.go //dc中间件的封装
├── downtrack.go //下行track
├── helpers.go //工具函数集
├── mediaengine.go //SDP相关codec、rtp参数设置
├── peer.go //peer封装，一个peer包含一个publisher和一个subscriber，双pc设计
├── publisher.go //publisher，封装上行pc
├── receiver.go //subscriber，封装下行pc
├── router.go //router，包含pc、session、一组receivers
├── sequencer.go //记录包的信息：序列号sn、偏移、时间戳ts等
├── session.go //会话，包含多个peer、dc
├── sfu.go //分发单元，包含多个session、dc
├── simulcast.go //大小流配置
├── subscriber.go //subscriber，封装下行pc、DownTrack、dc
└── turn.go //内置turn server
```
相比以前版本，增加了一些interface，主要是为了作为包使用时，封装自己的类。

## WebRTC课程
WebRTC 一对一 多对多 P2P Mesh SFU 流媒体 视频会议课程等请关注
[https://www.kangshaojun.com](https://www.kangshaojun.com)

文章转载自：[https://zhuanlan.zhihu.com/p/376554019](https://zhuanlan.zhihu.com/p/376554019)