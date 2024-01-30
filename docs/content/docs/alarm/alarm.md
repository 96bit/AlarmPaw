---
title: "AlarmPaw"
description: ""
summary: ""
date: 2024-01-29T22:51:34+08:00
lastmod: 2024-01-29T22:51:34+08:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "alarm-6575bc015b8380ec488d28ffd028740a"
weight: 3
toc: true
seo:
  title: "Alarm" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

# IOS App

* App 所有功能均参照[Bark](https://github.com/Finb/Bark)开发, 只是推送的证书和服务器不同，请直接参照bark文档进行使用
* 使用bark文档时 记得替换服务器

## 使用文档
[https://bark.day.app](https://bark.day.app)

## 问题反馈 Telegram 群
[Bark反馈群](https://t.me/joinchat/OsCbLzovUAE0YjY1)
## 后端代码 
[AlarmPawServer](https://github.com/tsaohe/AlarmPawServer)
>将后端代码部署在你自己的服务器上。支持Docker

## 发送推送
1. 打开APP，复制测试URL 
```
以下使用SERVER_ADDRESS 指代服务器地址 push.shkqg.com
```

<img src="https://wx4.sinaimg.cn/mw2000/003rYfqply1grd1meqrvcj60bi08zt9i02.jpg" width=365 />

2. 修改内容，请求这个URL
```
可以发 get 或者 post 请求 ，请求成功会立即收到推送 

URL 组成: 第一个部分是 key , 之后有三个匹配 
/:key/:body 
/:key/:title/:body 
/:key/:category/:title/:body 

title 推送标题 比 body 字号粗一点 
body 推送内容 换行请使用换行符 '\n'
category 另外的功能占用的字段，还没开放 忽略就行 
post 请求 参数名也是上面这些

URL参数 > GET参数 > POST参数
假如 你的请求是 https://SERVER_ADDRESS/key/标题/内容?title=标题

后面的title不会覆盖前面的title

```

## 复制推送内容
收到推送时下拉推送（或在通知中心左滑查看推送）有一个`复制`按钮，点击即可复制推送内容。

> <img src="http://wx4.sinaimg.cn/mw690/0060lm7Tly1g0btjhgimij30ku0a60v1.jpg" width=375 />

```
//将复制“验证码是9527”
https://SERVER_ADDRESS/yourkey/验证码是9527
```

携带参数 automaticallyCopy=1， 收到推送时，推送内容会自动复制到粘贴板（如发现不能自动复制，可尝试重启一下手机）
```
//自动复制 “验证码是9527” 到粘贴板
https://SERVER_ADDRESS/yourkey/验证码是9527?automaticallyCopy=1 
```


携带copy参数， 则上面两种复制操作，将只复制copy参数的值
```
//自动复制 “9527” 到粘贴板
https://SERVER_ADDRESS/yourkey/验证码是9527?automaticallyCopy=1&copy=9527

```

## 其他参数

* url
```
// 点击推送将跳转到url的地址（发送时，URL参数需要编码）
https://SERVER_ADDRESS/yourkey/百度网址?url=https://www.baidu.com 
```
* isArchive
```
// 指定是否需要保存推送信息到历史记录，0 为不保存，其他值或默认保存。
https://SERVER_ADDRESS/yourkey/不需要保存?isArchive=0
```
* group
```
// 指定推送消息分组，可在历史记录中按分组查看推送。
https://SERVER_ADDRESS/yourkey/需要分组的推送?group=groupName
```
* icon (仅 iOS15 或以上支持）
```
// Specify the push notification icon.
https://SERVER_ADDRESS/yourkey/需要自定义图标的推送?icon=http://day.app/assets/images/avatar.jpg

```
* image 
```
// 可以携带一张图片URL,直接在通知里展示
https://SERVER_ADDRESS/yourkey/Body?image=http://day.app/assets/images/avatar.jpg
```
* Timed Notifications
```
// Set a timed notification
https://SERVER_ADDRESS/yourkey/Timed Notifications?level=timeSensitive

// 可选参数值
// active：不设置时的默认值，系统会立即亮屏显示通知。
// timeSensitive：时效性通知，可在专注状态下显示通知。
// passive：仅将通知添加到通知列表，不会亮屏提醒
```
