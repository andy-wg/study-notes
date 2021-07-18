---
title: ION的来由和发展
description:
toc: true
authors: 
  - kangshaojun
date: '2021-06-16'
lastmod: '2021-06-16'
---
ION的来由和发展
<!--more-->

## ION的来由和发展
项目地址：https://github.com/pion/ion

star 数量：2.5K

## 一、行业发展
作为ION的发起人之一，同时也是PION的核心开发者。作者一直从事互联网直播和在线教育行业的研发，一直在关注流媒体开源项目的发展，也一直关注LVS等行业论坛。

行业内有个趋势：

传统RTMP+FLV+FLASH的技术栈在逐渐向RTMP+FLV+RTC，甚至纯RTC发展。

## 二、语言发展
开发语言是底子，底子好才能发展好；语言决定项目的整体发展和方方面面的成本和效率；

比如，CNCF里毕业/孵化中项目，GO的项目比例占到了80%+

这里有个趋势 ：

**服务端方面：**

Golang发展的非常火 ：不管是API服务，IM服务，甚至流媒体服务，都在向Golang转化；很多Coder在向Golang转化。

**客户端方面：**

Flutter发展的非常火 ：很多新项目开始使用Flutter，很多Coder都在往Flutter转化。

## 三、ION的发展
**背景：**

想基于GO做RTC项目的想法一直都有。前几年的一天，我关注到pion/webrtc这个开源项目，当时加密部分还是使用的openssl，项目发起人是aws的大佬Sean等。后来过了一段时间，pion替换掉了openssl，项目发展为纯GO的项目。这个时候，我觉得项目很有潜力！决定使用pion来开发一个纯GO的RTC项目。

**人员发展：**

ION的初期，需要开发demo来测试，我是做后端出身，碰到了很多前端的问题。这时候我碰到了有同样想法的全栈大佬，同时也是flutter-webrtc的作者，资深WebRTC/SIP专家-鱼大神。作为ION的联合发起人，我们一拍即合，一起做，使用pion/webrtc做后端，flutter/js做前端和SDK。期间还加入了《Flutter技术入门与实战》等多本书的作者，资深视频会议专家-亢大神。到后期，又加入了国外的大神，比如：tarrencev、jason、leeward等，他们技术很牛，同时思想也很超前，时间也很多 ‍♂️。再后来，有些用到ION的组织和个人纷纷加入进来，希望一起完善，这就是优质开源的魅力 。

**项目发展：**

ION的初期，只是一个单机的带信令版SFU。后来成分布式的，期间也是多数RTC项目的必经阶段：

信令和媒体服务拆分（拆分为biz、sfu、islb、nats、redis等）
MQ来传输消息和解耦合（使用nats封装了rpc框架，状态存在redis）
Docker化开发和部署（每个服务都有容器）
前端多种SDK和app（ts、flutter）
媒体服务优化（JB等）
在疫情期间，❤️我们的项目做到了【2.4K+ 】 ，感谢sean的宣传和大神们的努力。

## 四、ION的特点
底子好，前景好：基于谷歌三剑客（WebRTC标准+GO+Flutter）
效率高：纯GO+Flutter/JS开发，高开发效率+运行效率+维护效率（初期的ION在1VN的场景下，已经做到0.5核=1000路；pion/webrtc在不带JB的rtsp-bench里已经压到了0.3核=10000路）
云原生亲和：支持容器，服务端组件也优先选GO系（CNCF）
分布式架构：信令和媒体解耦，易于扩展
覆盖全：多样的SDK+APP（Flutter、JS）
社区活跃：（最活跃的RTC社区，好像GO/Flutter的社区都很火）
五、展望未来
未来目标，主要有三个方面：

完善媒体服务；完善弹性分布式调度；完善客户端/SDK覆盖。

开源是一种热情，个中收获，个中辛苦，只有开源人能够体会，希望能继续一起把ION做好。在这里特别感谢ION的维护者们以及PION社区的开发者们。

欢迎有兴趣的人一起来完善ION～

## 相关资源连接
亢少军站点：[http://www.kangshaojun.com](http://www.kangshaojun.com)<br>
亢少军 github: [https://github.com/kangshaojun/](https://github.com/kangshaojun/)<br>
文章转载自：[https://zhuanlan.zhihu.com/p/206492402](https://zhuanlan.zhihu.com/p/206492402)

## WebRTC课程
WebRTC 一对一 多对多 P2P Mesh SFU 流媒体 视频会议课程等请关注
[https://www.kangshaojun.com](https://www.kangshaojun.com)
