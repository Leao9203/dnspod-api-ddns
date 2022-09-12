# dnspod-api-ddns

基于 DNSPod API 开发文档写的脚本，灵感来源于上一个 CF-DDNS 脚本修改过程中所累积的经验。目前基本上已经写好了，测试时没遇到什么 BUG，如果有，建议先提 issue

## 用法

具体用法建议优先参考我写的文章
我的博客：[基于 DNSPod 开发文档写了个 DDNS 脚本 | Leao's Blog | Leao的博客](https://blog.ascn.site/post/20220912222454/)
Bilibili：[基于 DNSPod 开发文档写了个 DDNS 脚本 - 哔哩哔哩](https://www.bilibili.com/read/cv18562500)

### 参数

``` shell
dnspod-ddns.sh
    -i # DNSPod Token 的 ID
    -k # DNSPod Token ID 所对应的 Token
    -d # DDNS 的主域名，例如 ascn.site
    -r # DDNS 的域名记录，例如 blog
    -t # DDNS 的类型，允许的值为 A 或者 AAAA
    -a # 检测出口 IP 的 API，可选输入，例如 ip.sb，或者我所搭建的 ip.leao9203.xyz，建议优先自己搭建一个
    -f # 是否忽略 IP 变化，强制更新。如果启用，请设置为 true
```

顺带一提，脚本在初次运行时会自动在当前用户的目录下的 `.config`/`dnspod-ddns` 生成一个保存 IP 的文件，来判断 IP 是否更新。如果目录不存在会自动创建。

### 设置 crontab 自动更新

``` shell
*/1 * * * * dnspod-ddns.sh 附加参数
```

频率为每分钟检查一次 IP 是否更新，如果觉得太频繁可以把 `1` 改为其他数值（小于 60 的整数）

### 其他用法

除了通过附加参数来使用，也可以直接修改脚本内的一些变量来使用，脚本内已经加了注解，修改第 4 行至第 22 行的变量内容即可。
