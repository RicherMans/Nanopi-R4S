# NanoPi R4S (4GB) Build

This repo contains my NanoPi-R4S builds mainly using LEDE.

The main changes are that the image is 4GB large (most others are 1GB).




## Build locally

To build the image locally using Docker, run:

```bash
git clone Richermans/Nanopi-R4S
cd NanoPi-R4S
docker build . -t openwrt_builder
docker run --mount src=`pwd`,target=/home/user/,type=bind -it openwrt_builder ./compile_local.sh
```

## Features
* [SuLingGG/OpenWrt-Rpi/README.md](https://github.com/SuLingGG/OpenWrt-Rpi/blob/main/README.md)

## References

* https://github.com/LewiVir/NanoPi-R4S
* https://github.com/SuLingGG/OpenWrt-Rpi
* https://github.com/P3TERX/Actions-OpenWrt
