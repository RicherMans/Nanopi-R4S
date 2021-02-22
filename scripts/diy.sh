#!/bin/bash

# Add Some Package
rm -rf package/custom
mkdir -p package/custom
pushd package/custom
#git clone https://github.com/coolsnowwolf/packages
git clone https://github.com/kenzok8/small
git clone https://github.com/kenzok8/openwrt-packages
git clone https://github.com/Lienol/openwrt-package

#修复small库里面V2ray 路径错误问题
rm -rf ./small/v2ray
rm -rf ./openwrt-package/package/v2ray
rm -rf ./openwrt-packages/package/v2ray
rm -rf ./openwrt-packages/luci-app-aliddns
rm -rf ./openwrt-package/package/v2ray-plugin
rm -rf ./openwrt-packages/package/v2ray-plugin
rm -rf ./small/v2ray-plugin
rm -rf ../lean/luci-app-docker

git clone https://github.com/tty228/luci-app-serverchan
git clone https://github.com/rufengsuixing/luci-app-adguardhome
# Add luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ../lean/luci-theme-argon


git clone --depth=1 https://github.com/KFERMercer/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-lib-docker
git clone https://github.com/jerrykuku/lua-maxminddb.git
git clone https://github.com/jerrykuku/luci-app-vssr.git
git clone https://github.com/honwen/luci-app-aliddns
git clone https://github.com/goofysun/luci-app-koolproxyR
# Add mentohust & luci-app-mentohust
git clone --depth=1 https://github.com/BoringCat/luci-app-mentohust
git clone --depth=1 https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk
# Add subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter
# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter

popd
# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd


# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i "/commit luci/i\uci set luci.main.mediaurlbase='/luci-static/argon'" zzz-default-settings
# DEfault language to English
sed -i 's/\(luci.main.lang=\)\(.*\)/\1en/g' zzz-default-settings
sed -i '/http/d' zzz-default-settings
sed -i '/exit/i\chmod +x /bin/ipv6-helper' zzz-default-settings
popd

sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd
# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

git am ../patches/*.patch
echo -e " Lean's OpenWrt built on "$(date +%Y.%m.%d)"\n -----------------------------------------------------" >> package/base-files/files/etc/banner
