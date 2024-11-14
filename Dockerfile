FROM openwrt/sdk:x86_64-v23.05.5

# Добавляем собственный feed для quickjs
RUN mkdir -p /builder/feeds/custom
COPY feeds.conf.default /builder/feeds.conf.default
RUN echo "src-git custom https://github.com/VizzleTF/quickjs_openwrt.git" >> feeds.conf.default

# Обновляем и устанавливаем все необходимые пакеты
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    ./scripts/feeds install dnsmasq-full curl jq kmod-nft-tproxy coreutils-base64 && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Собираем с подробным выводом
RUN make defconfig && \
    make package/podkop/compile V=sc && \
    make package/luci-app-podkop/compile V=sc