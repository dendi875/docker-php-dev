
#  PHP本地开发环境搭建指南

## 前言

开发环境是我们日常工作的一个环境，在团队中搭建一套统一的开发环境能带来如下好处：

* 统一开发环境。一次配置打包，统一分发给团队成员，统一团队开发环境，解决诸如“编码问题”，“缺少模块”，“配置文件不同”带来的问题

* 避免重复搭建开发环境。新员工加入，不用浪费时间搭建开发环境，快速加入开发，减少时间成本的浪费

* 相关模块的新增、升级、替换、卸载清除时也很快捷轻松

本文配置的开发环境有如下优势：

* 兼容开发时常用的操作系统（Win7、Win10、Mac）
* 能方便灵活的修改`PHP`配置文件
* 能方便灵活的修改`Nginx`配置文件
* 能对多个站点进行`HTTPS`的支持
* 把常用的命令封装成了`shell`工具集，简化命令行的操作，如`init.sh`和`dev`

## 配置Docker环境

### 不同系统安装方式有所不同

* win7
    * 检查虚拟化技术支持
        * [检查方法](https://www.shaileshjha.com/how-to-find-out-if-intel-vt-x-or-amd-v-virtualization-technology-is-supported-in-windows-10-windows-8-windows-vista-or-windows-7-machine/)
        * 如果电脑尚未开启虚拟化功能，请对照自己电脑品牌`google`搜索关键字 `开启虚拟化`
    * 下载并安装`Docker Toolbox`
        * 下载
            * [官方](https://www.docker.com/products/docker-toolbox)
            * [google云端硬盘](https://drive.google.com/open?id=1AghM4431aSXG_jTOsxeuPF3XUyADl6Bp)
        * 安装步骤
            * ![toolbox-setup-1](https://github.com/dendi875/images/blob/master/docker/toolbox-setup-1.png)
            * ![toolbox-setup-2](https://github.com/dendi875/images/blob/master/docker/toolbox-setup-2.png)

    * 安装完成后启动`Docker Quickstart Terminal`，看到如下界面表示docker已成功启动

    ```sh

                            ##         .
                      ## ## ##        ==
                   ## ## ## ## ##    ===
               /"""""""""""""""""\___/ ===
          ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
               \______ o           __/
                 \    \         __/
                  \____\_______/
    docker is configured to use the default machine with IP 192.168.99.100
    For help getting started, check out the docs at https://docs.docker.com

    Start interactive shell
    ```

* win10

    * 检查虚拟化技术支持（参考win7）
    * 开启`hype-v`虚拟机
        * `控制面板 > 程序 > 启用或关闭windows功能 > 选中hype-v选项`
    * 下载并安装`Docker for windows`
        * [官方安装说明](https://www.docker.com/products/docker-desk)
    * 安装完成后，重新启动电脑，桌面右下角会出现`docker`标识符，并提示正在启动。在`CMD`命令行窗口运行`docker --version`，显示docker版本信息，表示docker已经安装成功。

* mac
    * 下载并安装`docker-for-mac`
        * [官方安装说明](https://docs.docker.com/docker-for-mac/)

### 下载`docker-php-dev`

```sh
git clone git@github.com:dendi875/docker-php-dev.git
```

**注意：** 实际在企业中使用的时候为了安全和隐私方面的考虑，可以使用**gitlab**搭建自己的`git`私有仓库，然后把 `docker-php-dev`存储到私有仓库中

三、安装自己制作的`CA`证书（非必需）

双击安装 *build/nginx/pki/CA/cacert.crt* ，存储到 **受信任的根证书颁发机构**。
    本操作只对IE、Chrome系列的浏览器有效，Firefox需单独安装。


这个步骤不是必须的，但以下两种情况下你可能会用到

* 开发环境的域名需要支持`HTTPS`

* 开发环境的域名是以`.dev`结尾

最后一种情况的需求是很普遍的，因为一般在企业中会使用不同的域名后缀来区分多个环境，如：

* 开发环境：example.zhangquan.dev
* 测试环境：example.zhangquan.test
* 生产环境：example.zhangquan.com

但是Chrome 浏览器从 v63 版本起将会强制所有的```.dev```域名使用`HTTPS`。为了解决上述两种需求我们可以使用自己制作的`CA`根证书并颁发需要的`SSL`证书。这也就是 **build/nginx/pki/** 目录的功能：

```sh
pki
├── CA
├── mk-crt.sh
├── tls
└── v3.ext
```

现在对`www.test.dev`和`*.zhangquan.dev`站点进行了`HTTPS`的支持，假设需要对另外的多域名站点进行`HTTPS`支持，只需要在 `v3.ext`中加上该域名，如`DNS.2 = *.demo.dev`，然后运行

```sh
$ ./mk-crt.sh
```

接着在`nginx`配置文件中加入相应的域名即可，参照`build/nginx/root/etc/nginx/conf.d/sites.conf`

更多的关于证书相关知识可以参考我的另一篇文章：[使用openssl自建CA和颁发多域名通配符证书](https://github.com/dendi875/Linux/blob/master/%E4%BD%BF%E7%94%A8openssl%E8%87%AA%E5%BB%BACA%E5%92%8C%E9%A2%81%E5%8F%91%E5%A4%9A%E5%9F%9F%E5%90%8D%E9%80%9A%E9%85%8D%E7%AC%A6%E8%AF%81%E4%B9%A6.md)

#### 使用 *init.sh* 脚本初始化开发环境

可指定任意目录，如不指定则使用当前目录。

```sh
$ cd docker-php-dev
$ ./init.sh /x/path/to/workdir
```

例如：

```sh
admin@nb-17-02-521 MINGW64 /c/Users/docker-php-dev (master)
$ ./init.sh
```

初始化脚本主要完成如下工作，如有失败可参考脚本内容手动运行
* 将 `docker-compose.yml` 复制到工作目录
* 虚拟机(`default`)共享目录设置
* 配置`git commit`提交之前`PHP`语法检查的钩子（extra/hooks/pre-commit）
* 拉取最新镜像（`docker-compose pull`）
* 下载项目代码

**注意：** 执行 `docker-compose pull`时拉取的`dendi875/php-nginx:latest`和`dendi875/php-php:7.3`镜像是存放在**dockerhub**公共仓库中，但在企业实际的使用过程中一般是把镜像存放到**阿里云**上，或者基于**Harbor**搭建一个自己内部的私有镜像仓库。


四、启动开发环境

```sh
$ cd /path/to/workdir/
$ docker-compose up -d
Creating network "dockerphpdev_default" with the default driver
Creating dockerphpdev_php_1
Creating dockerphpdev_nginx_1
```

五、站点配置

定制域名的nginx配置：在 docker-compose.override.yml 的 php 配置项里找到 volumes 配置项， 并加入类似下面的配置行 `- ./local/app_domain_root.conf:/etc/nginx/include/app_domain_root.conf`

**注意：** 此处是文件的映射，将custom目录下的一个文件映射到了docker环境里nginx站点配置目录下。

具体系统配置如下：

1）win7

* 查看Docker Machine IP，本例中获取的IP为192.168.99.100

    ```sh
    $ docker-machine ip
    192.168.99.100
    ```

* 修改本地hosts，加入需要使用的域名，就可以访问docker的开发环境了

    ```sh
    example.zhangquan.dev   192.168.99.100
    www.test.dev            192.168.99.100
    ```

* 如果需要配置`service`域名则调整*docker-compose.override.yml*文件中的`extra_hosts`内容，后重启`docker`

    ```sh
    extra_hosts:
        - "example.services.dev.ofc:192.168.99.100"
    ```
2） win10

* 通过`ipconfig`查看本地`ip`，本例中获取的IP为172.16.100.218

* 修改本地hosts，加入需要使用的域名，就可以访问docker的开发环境了

    ```sh
    example.zhangquan.dev   127.0.0.1
    www.test.dev            127.0.0.1
    ```

* 如果需要配置`service`域名则调整*docker-compose.override.yml*文件中的`extra_hosts`内容，后重启`docker`

    ```sh
    extra_hosts:
        - "example.services.dev.ofc:172.16.100.218"
    ```
3）mac

* 通过`ifconfig`查看本地`ip`，本例中获取的IP为172.16.100.219

* 修改本地hosts，加入需要使用的域名，就可以访问docker的开发环境了

    ```sh
    example.zhangquan.dev   127.0.0.1
    www.test.dev            127.0.0.1
    ```

* 如果需要配置`service`域名则调整*docker-compose.override.yml*文件中的`extra_hosts`内容，后重启`docker`

    ```sh
    extra_hosts:
        - "example.services.dev.ofc:172.16.100.219"
    ```

**注意：** 如果修改了`docker-compose`配置文件的内容必须重新启动`docker`才能生效

六、重新启动`docker`

```sh
$ docker-compose down
Stopping dockerphpdev_nginx_1 ...
Stopping dockerphpdev_php_1 ...
[1BRemoving dockerphpdev_nginx_1 ...
Removing dockerphpdev_php_1 ...
[1BRemoving network dockerphpdev_default
```

```sh
$ docker-compose up -d
Creating network "dockerphpdev_default" with the default driver
Creating dockerphpdev_php_1
Creating dockerphpdev_nginx_1
```

七、更新`docker`镜像

```sh
$ cd /path/to/workdir/
$ docker-compose pull
```

## dev 命令 ##

为了便于开发环境的使用, 增加了 dev 这个命令行脚本.

用法:

```
./dev phpunit # 运行PHPUnit测试, e.g. ./dev phpunit path/to/tests --filter NameOfTest
./dev phplog # PHP 服务日志，e.g. ./dev phplog
```

## Docker FAQ

**Q：** 启动`docker`时出现如下错误怎么办？

```sh
$ docker-compose up -d
[31mERROR[0m: SSL error: [SSL: TLSV1_ALERT_PROTOCOL_VERSION] tlsv1 alert proto
col version (_ssl.c:590)
```

**A：** 这是因为与Docker守护进程进行TLS通信的版本默认为TLSv1。 我们需要带VCH的TLSv1_2。 可以使用以下命令设置环境变量：

```sh
export COMPOSE_TLS_VERSION=TLSv1_2
```

**Q：** 某些域名（如：unknow.zhangquan.dev）无法访问开发环境怎么办？

**A：** 默认nginx配置文件已经配置了大部分已知的域名规则，对于一些新建或者特殊的域名，很可能是需要人工配置干预的。需要通过创建 `docker-compose.override.yml` （自定义`docker-compose`配置文件），加入本地开发对应的nginx域名配置文件。


*docker-compose.override.yml* 示例内容：

```sh
version: '2'
services:
  nginx:
# 从本地Dockerfile进行build
    build: ./build/nginx
# 此处为自定义nginx配置
    volumes:
      - ./local/app_domain_root.conf:/etc/nginx/include/app_domain_root.conf
      - ./build/nginx/root/etc/nginx/conf.d/sites.conf:/etc/nginx/conf.d/sites.conf
  php:
# 从本地Dockerfile进行build
    build: ./build/php
# 此处为自定义php配置（文件名必须为*.ini），用于开启未加载的扩展等
    volumes:
      - ./my.ini/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini:ro
      - ./my.ini/swoole.ini:/usr/local/etc/php/conf.d/swoole.ini:ro
    environment:
      - SKIP_NFS=1
# 此处为自定义service配置，用于使用本地webservice
    extra_hosts:
      - "example.services.dev.ofc:192.168.99.100"
```


**Q：** 如何删除所有无效的`<none>`镜像？

**A：** 使用多个命令组合

```sh
$ docker images | grep none | awk '{print $3}' | xargs docker rmi
Untagged: swaggerapi/swagger-editor@sha256:e9ccdeffee0cd2733117155f9ecf1a8dd101e54d39fcb3e23346a5aa6f510448
Deleted: sha256:f34dd5013f2357c17f47c0b9c19732a09051e9df56134d3f630a544b5902800f
Deleted: sha256:2fbd94056958d3c6561aa3fb920381694c49af38e93c75b0388636f32a2c9adf
Deleted: sha256:0dd0635fed926775c5be290b430f8be9ce55fa7456f3b4c204ce32cc39352d60
```

**Q：** 我该如何学习`Docker`？

**A：** `docker-php-dev` 代码中有全部的`build`文件，可以参考这些文件，并配合阅读参考资料，边练边学习。


## 参考资料
* [Docker 技术入门与实战](https://www.gitbook.com/book/yeasy/docker_practice/details)
* [Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Compose file reference](https://docs.docker.com/compose/compose-file/)
* [Alpine Linux Packages](http://pkgs.alpinelinux.org/packages)