FROM openwrt/sdk:x86_64-v23.05.5

RUN ./scripts/feeds update -a && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Install required tools for translations
RUN sudo apt-get update && \
    sudo apt-get install -y gettext

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

RUN make defconfig && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile && \
    make package/luci-app-podkop-i18n-ru/compile V=s -j4