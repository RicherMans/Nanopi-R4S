#!/usr/bin/env bash

# Best to run this script from a docker container, such as:
# 
#docker build . -t openwrt_builder
#docker run --mount src=`pwd`,target=/home/user/,type=bind -it openwrt_builder ./compile_local.sh

DIY_SCRIPT="scripts/diy.sh"
CONFIG_FILE="configs/lean/lean.config"
REPO_URL="https://github.com/coolsnowwolf/lede"
REPO_BRANCH="master"

# Download source
(
    git clone $REPO_URL -b $REPO_BRANCH
)

OPENWRTROOT="$PWD/lede" 

(
    cd $OPENWRTROOT 
    ./scripts/feeds update -a 
    chmod +x ../${DIY_SCRIPT}
    ../${DIY_SCRIPT}
    ../scripts/preset-clash-core.sh armv8
    ../scripts/preset-terminal-tools.sh
    ./scripts/feeds install -a
)

(
    cd $OPENWRTROOT
    cp ../$CONFIG_FILE .config
    make defconfig
    ../scripts/modify_cpu_arch_config.sh #Optimizations for CortexA72
    make download -j8
    find dl -size -1024c -exec ls -l {} \;
    find dl -size -1024c -exec rm -f {} \;
)

(
    cd $OPENWRTROOT
    #Compile
    echo -e "$(nproc) thread compile"
    make tools/compile -j$(nproc) || make tools/compile -j1 V=s
    make toolchain/compile -j$(nproc) || make toolchain/compile -j1 V=s
    make target/compile -j$(nproc) || make target/compile -j1 V=s IGNORE_ERRORS=1
    make diffconfig
    make package/compile -j$(nproc) IGNORE_ERRORS=1 || make package/compile -j1 V=s IGNORE_ERRORS=1
    make package/index

)

( 
    ROOT=$PWD
    cd $OPENWRTROOT/bin/packages/*
    PLATFORM=$(basename `pwd`)
    cd $OPENWRTROOT/bin/targets/*
    TARGET=$(basename `pwd`)
    cd *
    SUBTARGET=$(basename `pwd`)
    cd $ROOT
    cd configs/opkg
    sed -i "s/subtarget/$SUBTARGET/g" distfeeds*.conf
    sed -i "s/target\//$TARGET\//g" distfeeds*.conf
    sed -i "s/platform/$PLATFORM/g" distfeeds*.conf
    cd $OPENWRTROOT
    #mkdir -p files/etc/uci-defaults/
    #cp ../scripts/init-settings.sh files/etc/uci-defaults/99-init-settings
    mkdir -p files/etc/opkg
    cp ../configs/opkg/distfeeds-packages-server.conf files/etc/opkg/distfeeds.conf.server
    mkdir -p files/www/snapshots
    cp -r bin/targets files/www/snapshots
    cp ../configs/opkg/distfeeds-18.06-local.conf files/etc/opkg/distfeeds.conf
    cp ../configs/opkg/distfeeds-18.06-remote.conf files/etc/opkg/distfeeds.conf

    cp files/etc/opkg/distfeeds.conf.server files/etc/opkg/distfeeds.conf.mirror
    sed -i "s/http:\/\/192.168.123.100:2345\/snapshots/https:\/\/openwrt.cc\/snapshots\/$(date +"%Y-%m-%d")\/lean/g" files/etc/opkg/distfeeds.conf.mirror
    mkdir -p files/www/ipv6-modules
    cp bin/packages/$PLATFORM/luci/luci-proto-ipv6* files/www/ipv6-modules
    cp bin/packages/$PLATFORM/base/{ipv6helper*,odhcpd-ipv6only*,odhcp6c*,6in4*} "files/www/ipv6-modules"
    cp bin/targets/$TARGET/$SUBTARGET/packages/{ip6tables*,kmod-nf-nat6*,kmod-ipt-nat6*,kmod-sit*,kmod-ip6tables-extra*} "files/www/ipv6-modules"
    mkdir -p files/bin
    cp ../scripts/ipv6-helper.sh files/bin/ipv6-helper
    make package/install -j$(nproc) || make package/install -j1 V=s
    make target/install -j$(nproc) || make target/install -j1 V=s
    make checksum
)
