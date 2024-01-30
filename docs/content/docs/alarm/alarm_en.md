---
title: "AlarmPawEn"
description: ""
summary: ""
date: 2024-01-29T23:25:38+08:00
lastmod: 2024-01-29T23:25:38+08:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "alarm-498d513f08748d2e5bb2f86be4634b1c"
weight: 1
toc: true
seo:
  title: "alarm" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---




# IOS App

* All app functionality is developed following [Bark](https://github.com/Finb/Bark), with the only difference being the push certificate and server. Please refer to the Bark documentation for usage.
* When using the Bark documentation, remember to replace the server.

## Usage Documentation
[https://bark.day.app](https://bark.day.app)

## Feedback Group
[Bark Feedback Group](https://t.me/joinchat/OsCbLzovUAE0YjY1)

## Backend Code
[AlarmPawServer](https://github.com/tsaohe/AlarmPawServer)
> Deploy the backend code on your server. Docker support is available.

## Sending Push Notifications
1. Open the app, copy the test URL:
```
Use SERVER_ADDRESS to denote the server address push.shkqg.com
```

<img src="https://wx4.sinaimg.cn/mw2000/003rYfqply1grd1meqrvcj60bi08zt9i02.jpg" width=365 />

2. Modify the content and request this URL:

```
You can send GET or POST requests. A successful request will result in an immediate push notification.

URL structure: The first part is the key, followed by three matching options:
/:key/:body
/:key/:title/:body
/:key/:category/:title/:body

Title: Push notification title (slightly bolder than the body).
Body: Push notification content (use '\n' for line breaks).
Category: Currently unused field; you can ignore it.
Post request parameters use the same structure as above.

URL Parameters > GET Parameters > POST Parameters
If your request is https://SERVER_ADDRESS/key/Title/Content?title=Title, the title in the URL won't override the one in the request.

```

## Copy Push Content
When you receive a push notification, pull it down (or swipe left in the notification center) to find a `Copy` button. Click it to copy the push notification content.


> <img src="http://wx4.sinaimg.cn/mw690/0060lm7Tly1g0btjhgimij30ku0a60v1.jpg" width=375 />

```
// This will copy “Verification code 9527”
https://SERVER_ADDRESS/yourkey/Verification code 9527
```

Include the parameter `automaticallyCopy=1` to automatically copy the push notification content to the clipboard when received:

```
// Automatically copy "Verification code 9527" to the clipboard
https://SERVER_ADDRESS/yourkey/Verification code 9527?automaticallyCopy=1 
```


Include the `copy` parameter to specify which part of the push notification to copy:

```
// Automatically copy "9527" to the clipboard
https://SERVER_ADDRESS/yourkey/Verification code 9527?automaticallyCopy=1&copy=9527

```

## Other Parameters

* url
```
// Clicking the push notification will redirect to the specified URL (URL parameters need encoding when sending).
https://SERVER_ADDRESS/yourkey/baiduUrl?url=https://www.baidu.com 
```
* isArchive
```
// Specify whether to save the push notification in the history. Use 0 to not save; other values or the default will save.
https://SERVER_ADDRESS/yourkey/NotSave?isArchive=0
```
* group
```
// Specify the push notification group for viewing in the history.
https://SERVER_ADDRESS/yourkey/GroupBody?group=groupName
```
* icon (Only supported on iOS 15 or above)
```
// Specify the push notification icon.
https://SERVER_ADDRESS/yourkey/Notification Body?icon=http://day.app/assets/images/avatar.jpg

```
* image 
```
// Include a URL for an image to display directly in the notification.
https://SERVER_ADDRESS/yourkey/Body?image=http://day.app/assets/images/avatar.jpg
```
*  Timed Notifications
```
// Set a timed notification
https://SERVER_ADDRESS/yourkey/Timed Notifications?level=timeSensitive

// Optional parameter values
// active: Default value if not set; the system will immediately display the notification.
// timeSensitive: Timed notification, can be displayed in Focus mode.
// passive: Add the notification to the notification list only; it won't wake up the screen.
```

