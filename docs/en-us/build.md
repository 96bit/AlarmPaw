## 下载源码
从GitHub下载源码 [AlarmPaw](https://github.com/tsaohe/AlarmPaw)

或
```sh
git clone https://github.com/tsaohe/AlarmPaw.git
```
## 配置依赖
- Golang 1.18+
- Go Mod (env GO111MODULE=on)
- Go Mod Proxy (env GOPROXY=https://goproxy.cn)

## 交叉编译所有平台
```sh
# linux amd 版本
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o  main.go 
# 本机直接运行编译
go build -o  main.go 
# 其他平台 询问ChatGpt
```

