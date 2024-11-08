FROM openwrt/sdk:x86_64-v23.05.5

FROM openwrt/sdk:x86_64-v23.05.5

RUN ./scripts/feeds update -a && ./scripts/feeds install luci-base && mkdir -p /builder/package/feeds/utilites/ && mkdir -p /builder/package/feeds/luci/

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop
COPY ./luci-i18n-podkop-ru /builder/package/feeds/luci/luci-i18n-podkop-ru

RUN make defconfig && make package/podkop/compile && make package/luci-app-podkop/compile V=s && make package/feeds/luci/luci-i18n-podkop-ru/compile V=s