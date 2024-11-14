FROM openwrt/sdk:x86_64-v23.05.5

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install luci-base && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Install quickjs from custom repo
RUN wget https://github.com/VizzleTF/quickjs_openwrt/releases/download/v0.0.5/quickjs_2020-11-08-2_x86_64.ipk -O /tmp/quickjs.ipk && \
    opkg install /tmp/quickjs.ipk

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

RUN make defconfig && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j4