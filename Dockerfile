FROM openwrt/sdk:x86_64-v23.05.5

RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/ && \
    wget https://github.com/VizzleTF/quickjs_openwrt/releases/download/v0.0.5/quickjs_2020-11-08-2_aarch64_cortex-a53.ipk -O quick.ipk && \
    tar xf quick.ipk && \
    tar xf data.tar.gz && \
    mkdir -p /builder/staging_dir/target-x86_64_musl/root-x86_64/usr/bin/ && \
    cp usr/bin/qjs /builder/staging_dir/target-x86_64_musl/root-x86_64/usr/bin/

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

RUN make defconfig && \
    make package/podkop/compile V=sc && \
    make package/luci-app-podkop/compile V=sc