---
title: WebRTC通话原理
description: WebRTC通话原理
toc: true
authors:
  - kangshaojun
categories:
date: '2021-04-24'
lastmod: '2021-04-27'
---

WebRTC通话原理-基本流程 
<!--more-->

## 基本流程

WebRTC通话最典型的应用场景就是一对一音视频通话，如微信或QQ音视频聊天。通话的过程是比较复杂的，这里我们简化这个流程，把最主要的步骤提取出来，如图所示。
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021032009255789.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


假定通话的双方为Peer-A和Peer-B。双方要建立起通话，主要的步骤如下所示。
1	PeerA与PeerB通过信令服务器进行媒体协商，如双方使用的音视频编码格式。双方交换的媒体数据由SDP协议描述。

2	PeerA与PeerB通过STUN服务器获取到各自自己的网络信息，如IP和端口。然后通过信令服务器转发互相交换各种的网络信息。这样双方就知道对方的IP和端口了，即P2P打洞成功建立直连。这个过程涉及到NAT及ICE协议，具体后面会详细描述。

3	PeerA与PeerB如果没有建立起直连，则通过TURN中转服务器转发音视频数据，最终完成音视频通话。


## 媒体协商

首先两个客户端（Peer-A和Peer-B）想要创建连接，一般来说需要有一个双方都能访问的服务器来帮助它们交换连接所需要的信息。有了交换数据的中间人之后，它们首先要交换的数据是Session Description Protocol（SDP），这里面描述了连接双方想要建立怎样的连接。
彼此要了解对方支持的媒体格式。比如，Peer­A端可支持VP8、H264多种编码格式，而Peer­B端支持VP9、H264，要保证二端都正确的编解码，最简单的办法就是取它们的交集H264。如下图所示。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210322110813840.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


有一个专门的协议称为SDP（Session Description Protoco），可用于描述上述这类信息，在WebRTC中，参与视频通讯的双方必须先交换SDP信息，这样双方才能知根知底，而交换SDP的过程，也称为“媒体协商”。 
SDP从哪来，一般来说，在建立连接之前连接双方需要先通过API来指定自己要传输什么数据（Audio，Video，DataChannel），以及自己希望接受什么数据，然后Peer-A调用CreateOffer()方法，获取offer类型的SessionDescription，通过公共服务器传递给Peer-B，同样，Peer-B通过调用CreateAnswer()，获取answer类型的SessionDescription，通过公共服务器传递给Peer-A。 在这个过程中无论是哪一方创建Offer（Answer）都无所谓，但是要保证连接双方创建的SessionDescription类型是相互对应的。Peer-A=Answer Peer-B=Offer | Peer-A=Offer Peer-B=Answer。如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210322110835270.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)
图中信令服务器可以用来交换双方SDP信息，一般是通过创建Socket连接进行交互处理。你可以使用Node.js技术也可以使用Golang或其他技术，只要能交换双方的SDP数据即可。




## SDP协议

会话描述协议Session Description Protocol (SDP) 是一个描述多媒体连接内容的协议，例如分辨率，格式，编码，加密算法等。所以在数据传输时两端都能够理解彼此的数据。本质上，这些描述内容的元数据并不是媒体流本身。
从技术上讲，SDP并不是一个真正的协议，而是一种数据格式，用于描述在设备之间共享媒体的连接。SDP包含内容非常多，如下面内容所示为一个SDP信息。

```c
//版本
v=0
//<username> <sess-id> <sess-version> <nettype> <addrtype> <unicast-address>
o=- 3089712662142082488 2 IN IP4 127.0.0.1
//会话名
s=-
//会话的起始时间和结束时间，0代表没有限制
t=0 0
//表示音频传输和data channel传输共用一个传输通道传输的媒体，通过id进行区分不同的流
a=group:BUNDLE audio data
//WebRTC Media Stream
a=msid-semantic: WMS
//m=audio说明本会话包含音频，9代表音频使用端口9来传输，但是在webrtc中现在一般不使用，如果设置为0，代表不传输音频
//使用UDP来传输RTP包，并使用TLS加密, SAVPF代表使用srtcp的反馈机制来控制通信过程
//111 103 104 9 0 8 106 105 13 110 112 113 126表示支持的编码，和后面的a=rtpmap对应
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
//表示你要用来接收或者发送音频使用的IP地址, webrtc使用ICE传输，不使用这个地址, 关于ICE是什么后面2.5节会讲到
c=IN IP4 0.0.0.0
//用来传输rtcp的地址和端口，webrtc中不使用
a=rtcp:9 IN IP4 0.0.0.0
//ICE协商过程中的安全验证信息
a=ice-ufrag:ubhd
a=ice-pwd:l82NnsGm5i7pucQRchNdjA6B
//支持trickle，即sdp里面只描述媒体信息, ICE候选项的信息另行通知
a=ice-options:trickle
//dtls协商过程中需要的认证信息
a=fingerprint:sha-256 CA:83:D0:0F:3B:27:4C:8F:F4:DB:34:58:AC:A6:5D:36:01:07:9F:2B:1D:95:29:AD:0C:F8:08:68:34:D8:62:A7
a=setup:active
//前面BUNDLE行中用到的媒体标识
a=mid:audio
//指出要在rtp头部中加入音量信息
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
//当前客户端只接受数据，不发送数据，recvonly,sendonly,inactive,sendrecv
a=recvonly
//rtp,rtcp包使用同一个端口来传输
a=rtcp-mux
//下面都是对m=audio这一行的媒体编码补充说明，指出了编码采用的编号、采样率、声道等
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
//对opus编码可选的补充说明，minptime代表最小打包时长是10ms，useinbandfec=1代表使用opus编码内置fec特性
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
//下面就是对Data Channel的描述，基本和上面的audio描述类似，使用DTLS加密，使用SCTP传输
m=application 9 DTLS/SCTP 5000
c=IN IP4 0.0.0.0
//可以是CT或AS，CT方式是设置整个会议的带宽，AS是设置单个会话的带宽。默认带宽是kbps 
b=AS:30
a=ice-ufrag:ubhd
a=ice-pwd:l82NnsGm5i7pucQRchNdjA6B
a=ice-options:trickle
a=fingerprint:sha-256 CA:83:D0:0F:3B:27:4C:8F:F4:DB:34:58:AC:A6:5D:36:01:07:9F:2B:1D:95:29:AD:0C:F8:08:68:34:D8:62:A7
a=setup:active
//前面BUNDLE行中用到的媒体标识
a=mid:data
//使用端口5000，一个消息的大小是1024比特
a=sctpmap:5000 webrtc-datachannel 1024
```

以上就是一个SessionDescription的例子，虽然没有video的描述，但是video和audio的描述是十分类似的。 SDP中有关于IP和端口的描述，但是WebRTC技术并没有使用这些内容，那么双方是怎么建立“直接”连接的呢？建立起连接最关键的IP和端口是从哪里来的呢？这就需要ICE框架来完成这部分工作（参见后面的2.5节）。

注意：SDP由一行或多行UTF-8文本组成，每行以一个字符的类型开头，后跟等号（“ =”），然后是包含值或描述的结构化文本，其格式取决于类型。以给定字母开头的文本行通常称为“字母行”。例如，提供媒体描述的行的类型为“ m”，因此这些行称为“ m行”。




## 网络协商

彼此要了解对方的网络情况，这样才有可能找到一条相互通讯的链路。需要做以下两个处理。

 1. 获取外网IP地址映射。 
 2. 通过信令服务器(signal server)交换“网络信息”。

理想的网络情况是每个浏览器的电脑都是公网IP，可以直接进行点对点连接。如图所示。 
 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324133324379.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


实际情况是我们的电脑和电脑之间都是在某个局域网中并且有防火墙，需要NAT(Network Address Translation，网络地址转换)，如图所示。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324133341811.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


在解决WebRTC使用过程中的上述问题的时候，我们需要用到STUN和TURN。 

### NAT
NAT（Network Address Translation，网络地址转换）简单来说就是为了解决IPV4下的IP地址匮乏而出现的一种技术。
举例就是通常我们处在一个路由器之下，而路由器分配给我们的地址通常为192.168.1.1 、192.168.1.2如果有n个设备，可能分配到192.168.1.n，而这个IP地址显然只是一个内网的IP地址，这样一个路由器的公网地址对应了n个内网的地址，通过这种使用少量的公有IP 地址代表较多的私有IP 地址的方式，将有助于减缓可用的IP地址空间的枯竭。如图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324133402761.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


NAT技术会保护内网地址的安全性，所以这就会引发个问题，就是当我采用P2P之中连接方式的时候，NAT会阻止外网地址的访问，这时我们就得采用NAT穿透了。
于是我们就有了如下的思路：我们借助一个公网IP服务器，Peer-A与Peer-B都往公网IP/PORT发包,公网服务器就可以获知Peer-A与Peer-B的IP/PORT，又由于Peer-A与Peer-B主动给公网IP服务器发包，所以公网服务器可以穿透NAT-A与NAT-B并发送包给Peer-A与Peer-B。
所以只要公网IP将Peer-B的IP/PORT发给Peer-A，Peer-A的IP/PORT发给Peer-B。这样下次Peer-A与Peer-B互相消息，就不会被NAT阻拦了。
WebRTC的NAT/防火墙穿越技术，就是基于上述的一个思路来实现的。在WebRTC中采用ICE框架来保证RTCPeerConnection能实现NAT穿越。

### ICE
ICE（Interactive Connectivity Establishment，互动式连接建立）是一种框架，使各种NAT穿透技术（STUN，TURN...）可以实现统一。该技术可以让客户端成功地穿透远程用户与网络之间可能存在的各类防火墙。

### STUN
NAT 的UDP简单穿越（Session Traversal Utilities for NAT）是一种网络协议，它允许位于NAT（或多重NAT）后的客户端找出自己的公网地址，查出自己位于哪种类型的NAT之后以及NAT为某一个本地端口所绑定的Internet端端口。这些信息被用来在两个同时处于NAT路由器之后的主机之间建立UDP通信。如图2-7所示，STUN服务器能够知道Peer-A以及Peer-B的公网IP及端口。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324133428905.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


即使透过 STUN 服务器取得了公用 IP 位址，也不一定能建立连线。因为不同的NAT类型处理传入的UDP分组的方式是不同的。四种主要类型中有三种是可以使用STUN穿透：完全圆锥型NAT、受限圆锥型NAT和端口受限圆锥型NAT。但大型公司网络中经常采用的对称型 NAT（又称为双向NAT）则不能使用，这类路由器会透过NAT布署所谓的“Symmetric NAT限制”。也就是说，路由器只会接受你之前连线过的节点所建立的连线。这类网络就需要TURN技术。

### TURN
TURN（Traversal Using Relays around NAT）是STUN/RFC5389的一个拓展，主要添加了Relay功能。如果终端在NAT之后， 那么在特定的情景下，有可能使得终端无法和其对等端(peer)进行直接的通信，这时就需要公网的服务器作为一个中继，对来往的数据进行转发。这个转发的协议就被定义为TURN。 
在STURN服务器的基础上，再架设几台TURN服务器。在STUN分配公网IP失败后，可以通过TURN服务器请求公网IP地址作为中继地址。媒体数据由TURN服务器中转。如图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324133449895.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


当媒体数据走TURN中转，这种方式的带宽由服务器端承担。所以在架设中转服务时要考虑硬件及带宽。
提示：ICE跟STUN、TURN不一样，ICE不是一种协议，而是一个框架，它整合了STUN和TURN。 

以上是WebRTC中经常用到的协议，STUN和TURN服务器我们使用coturn开源项目来搭建，地址为：[https://github.com/coturn/coturn](https://github.com/coturn/coturn)。也可以使用Golang技术开发的服务器来搭建，地址为：[https://github.com/pion/turn](https://github.com/pion/turn)。



## 信令服务
从上面我们知道了2个客户端协商媒体信息和网络信息，那怎么去交换?是不是需要一个中间商去做交换?所以我们需要一个信令服务器(Signal server)转发彼此的媒体信息和网络信息。 
我们在基于WebRTC API开发应用(App)时，可以将彼此的App连接到信令服务器(Signal Server，一般搭建在公网，或者两端都可以访问到的局域网)，借助信令服务器，就可以实现SDP媒体信息及Candidate网络信息交换。 
信令服务器不只是交互媒体信息SDP和网络信息Candidate，比如: 房间管理，用户列表，用户进入，用户退出等IM功能。如图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210324134109367.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


在WebRTC中用来描述网络信息的术语叫candidate，如下所示。 

 1. 媒体协商：sdp 
 2. 网络协商：candidate

## 连接建立
介绍完ICE框架中各个独立部分的含义之后，在让我们来看一看整个框架是如何工作的，流程如下所示。
1.连接双方（Peer）通过第三方服务器来交换（Signaling）各自的SessionDescription数据。

2.连接双方（Peer）通过STUN协议从STUN Server那里获取到自己的NAT结构、子网IP和公网IP、端口，这里的IP和端口对我们称之为ICE Candidate。 

3.连接双方（Peer）通过第三方服务器来交换（Signalling）各自ICE Candidates，如果连接双方在同一个NAT下那他们仅通过内网Candidate就能建立起连接，反之如果他们处于非对称型NAT下，就需要STUN Server识别出的公网Candidate进行通讯。
 
4.如果仅通过STUN Server发现的公网Candidate仍然无法建立连接，换句话说就是连接双方（Peer）中至少有一方处于对称NAT下，这就需要处于对称NAT下的客户端（Peer）去寻求TURN Server提供的转发服务，然后将转发形式的Candidate共享（Signalling）给对方（Peer）。
 
5.连接双方（Peer）向目标IP端口发送报文，通过SessionDescription中涉及的密钥以及期望传输的内容，建立起加密长连接。 

A(local)和B(remote)代表两个人, 初始化并分别创建PeerConnection , 并向PeerConnection 添加本地媒体流。处理流程如下所示。

 1. A创建Offer 
 2. A保存Offer(设置本地描述) 
 3. A发送Offer给B 
 4. B保存Offer(设置远端描述)
 5. B创建Answer
 6. B保存Answer(设置本地描述)
 7. B发送Answer给A 
 8. A保存Answer(设置远端描述)
 9. A发送Ice Candidates给B
 10. B发送Ice Candidates给A
 11. A,B收到对方的媒体流并播放

这里我们不介绍具体API的使用及代码编写，只需要理解连接建立并通话的原理及流程即可。 


- WebRTC交流群: 425778886
- 开源地址: [https://github.com/kangshaojun](https://github.com/kangshaojun)

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210320092929961.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2thbmdzaGFvanVuODg4,size_16,color_FFFFFF,t_70)


## WebRTC课程
[请点击这里](https://flutter.ke.qq.com/)