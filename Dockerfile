FROM openwrt/sdk:x86_64-v23.05.5

# Create required directories
RUN mkdir -p /builder/package/feeds/utilites/ \
    /builder/package/feeds/luci/

# Create feeds.conf
RUN echo 'src-git packages https://git.openwrt.org/feed/packages.git^99f5616^' > /builder/feeds.conf && \
    echo 'src-git luci https://git.openwrt.org/project/luci.git^63ba3cb^' >> /builder/feeds.conf && \
    echo 'src-git routing https://git.openwrt.org/feed/routing.git^6bbcbf9^' >> /builder/feeds.conf && \
    echo 'src-git telephony https://git.openwrt.org/feed/telephony.git^129c8e0^' >> /builder/feeds.conf && \
    echo 'src-git ucode https://git.openwrt.org/project/ucode.git' >> /builder/feeds.conf

# Update and install all required feeds
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

# Configure build with required packages
RUN make defconfig && \
    echo 'CONFIG_PACKAGE_lua=y' >> .config && \
    echo 'CONFIG_PACKAGE_liblua=y' >> .config && \
    echo 'CONFIG_PACKAGE_libucode=y' >> .config && \
    echo 'CONFIG_PACKAGE_ucode=y' >> .config && \
    echo 'CONFIG_PACKAGE_ucode-mod-fs=y' >> .config && \
    echo 'CONFIG_PACKAGE_ucode-mod-uci=y' >> .config && \
    echo 'CONFIG_PACKAGE_ucode-mod-ubus=y' >> .config && \
    echo 'CONFIG_PACKAGE_libnl-tiny=y' >> .config && \
    echo 'CONFIG_PACKAGE_rpcd=y' >> .config && \
    echo 'CONFIG_PACKAGE_rpcd-mod-file=y' >> .config && \
    echo 'CONFIG_PACKAGE_rpcd-mod-luci=y' >> .config && \
    echo 'CONFIG_PACKAGE_cgi-io=y' >> .config && \
    echo 'CONFIG_PACKAGE_luci-base=y' >> .config && \
    echo 'CONFIG_PACKAGE_podkop=y' >> .config && \
    echo 'CONFIG_PACKAGE_luci-app-podkop=y' >> .config && \
    make defconfig

# Copy source files
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Build base packages first with maximum debugging
RUN make V=sc package/lua/compile && \
    make V=sc package/lua/install && \
    make V=sc -j1 package/libucode/compile && \
    make V=sc package/libucode/install && \
    make V=sc package/libnl-tiny/compile && \
    make V=sc package/libnl-tiny/install && \
    make V=sc package/ucode/compile && \
    make V=sc package/ucode/install && \
    make V=sc package/rpcd/compile && \
    make V=sc package/rpcd/install && \
    make V=sc package/cgi-io/compile && \
    make V=sc package/cgi-io/install && \
    make V=sc package/luci-base/compile && \
    make V=sc package/luci-base/install && \
    make V=sc -j$(nproc) package/podkop/compile && \
    make V=sc -j$(nproc) package/luci-app-podkop/compile

# Clean up unnecessary files
RUN rm -rf /builder/build_dir/target* \
    /builder/staging_dir/target* \
    /builder/tmp