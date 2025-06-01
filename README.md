[![GitHub License](https://img.shields.io/github/license/talebook/talebook?style=flat-square)](https://github.com/talebook/talebook/blob/master/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/talebook/talebook.svg)](https://hub.docker.com/r/poxenstudio/talebook)


# Tale Book: My Calibre WebServer
A better online books library management website built on Calibre + Vue
[中文说明](documents/README.zh_CN.md)

## Simple and Easy-to-Use Personal Book Management System

**Noted: Online publishing is not allowed for personal websites in China. It is recommended for personal use only!**

## Road Map
* v3.9.0 (Completed)
    1. Updated Calibre 7.6, system uses Ubuntu 24.04
    2. Added information reset in management, updated when scraping occurs
* v3.10.0
    1. Added book export functionality (e.g., converting epub to azw3 for Kindle use)
* NEXT
    1. Support for information sharing

## Introduction
This is a simple personal book management system based on Calibre, supporting **online reading**. Key features include:
* Beautiful interface: The default Calibre web interface is unattractive and difficult to use, so a new interface was developed based on Vue, supporting both PC and mobile browsing.
* Multi-user support: Developed multi-user functionality for easier use, supporting login via ~~Douban~~ (deprecated), QQ, Weibo, GitHub, and other social platforms.
* Online reading: Supports online reading of eBooks via the [epub.js](https://github.com/intity/epubreader-js) library (chapter review functionality under development).
* Batch scanning and importing of books.
* Email push: Easily push books to Kindle.
* OPDS support: Use apps like [KyBooks](http://kybook-reader.com/) for convenient reading.
* One-click installation: Web-based initialization configuration for easy website setup.
* Optimized file storage paths for large libraries: Supports categorization by letter or maintaining Chinese filenames.
* Quick book information updates: Supports importing basic book information from Baidu Encyclopedia and Douban searches.
* Private mode: Requires an access code to enter the website, suitable for sharing within small circles.

This project was formerly known as `calibre-webserver`.

## Docker ![Docker Pulls](https://img.shields.io/docker/pulls/talebook/talebook.svg)

Deployment is simple, and Docker is recommended. The image is available at [dockerhub](https://hub.docker.com/r/talebook/talebook).
* Built on `Ubuntu 24.04` and `Calibre 7.6` for improved compatibility. Do not set Docker's UID/GID to `root` (ID:0).

Recommended usage with `docker-compose`. Download the configuration file [docker-compose.yml](docker-compose.yml) from the repository and execute the command to start:
```
wget https://raw.githubusercontent.com/HorkyChen/talebook/master/docker-compose.yml
docker-compose -f docker-compose.yml up -d
```

If using native Docker, execute the following command:

`docker run -d --name talebook -p <local port>:80 -v <local data directory>:/data poxenstudio/talebook`

For example:

`docker run -d --name talebook -p 8080:80 -v /tmp/demo:/data poxenstudio/talebook`

## FAQ

For common issues, please refer to the [User Guide](document/UserGuide.zh_CN.md). If unresolved, submit an issue or [join the QQ group for discussion](https://qm.qq.com/q/5lSfpJGsBq).

For manual installation, refer to the [Developer Guide](document/Development.zh_CN.md).

NAS installation guide: Refer to the following posts by users: [Post 1](https://post.smzdm.com/p/a992p6e0/), [Post 2](https://post.smzdm.com/p/a3d7ox0k/), [Post 3](https://odcn.top/2019/02/26/2734/), * [Feiniu NAS](https://club.fnnas.com/forum.php?mod=viewthread&tid=27403).

**If you think this project is great, feel free to support the author on [Afdian](https://afdian.net/@talebook) to help optimize and sustain the project!**

**Disclaimer: This project does not maintain any public book library sites, such as joyeuse, wenyuange, etc., which are built by users. Please do not consult me about related issues, as I cannot assist!**

## Contributors
[![](https://contrib.rocks/image?repo=HorkyChen/talebook)](https://github.com/HorkyChen/talebook/graphs/contributors)

## Demonstration

[Demo site (password: admin/demodemo)](http://demo.talebook.org)

[Video introduction (thanks to @Pan06da)](https://player.bilibili.com/player.html?aid=482258810&bvid=BV1AT411S7c3&cid=1018595245&page=1)

Screenshots of the project demonstration:
![](document/screenshot.png)

