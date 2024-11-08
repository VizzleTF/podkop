FROM openwrt/sdk:x86_64-v23.05.5

# Create required directories
RUN mkdir -p /builder/package/feeds/utilites/ \
    /builder/package/feeds/luci/

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

# Build required packages first, then our packages
RUN make package/lua/compile && \
    make package/libucode/compile && \
    make package/libnl-tiny/compile && \
    make package/rpcd/compile && \
    make package/cgi-io/compile && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j$(nproc)

# Clean up unnecessary files
RUN rm -rf /builder/build_dir/target* \
    /builder/staging_dir/target* \
    /builder/tmp