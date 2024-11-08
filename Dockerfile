FROM openwrt/sdk:x86_64-v23.05.5

# Create required directories
RUN mkdir -p /builder/package/feeds/utilites/ \
    /builder/package/feeds/luci/

# Create feeds.conf with correct versions
RUN echo 'src-git-full base https://git.openwrt.org/openwrt/openwrt.git;v23.05.5' > /builder/feeds.conf && \
    echo 'src-git-full packages https://git.openwrt.org/feed/packages.git;openwrt-23.05' >> /builder/feeds.conf && \
    echo 'src-git-full luci https://git.openwrt.org/project/luci.git;openwrt-23.05' >> /builder/feeds.conf

# Update and install specific feeds
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -f -p base -a && \
    ./scripts/feeds install -f -p luci -a && \
    ./scripts/feeds install -f -p packages -a 

# Configure build with required packages
RUN make defconfig && \
    echo 'CONFIG_PACKAGE_lua=y' >> .config && \
    echo 'CONFIG_PACKAGE_liblua=y' >> .config && \
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

# Build packages with maximum debugging
RUN set -e && \
    make V=sc package/lua/compile && \
    make V=sc package/libnl-tiny/compile && \
    make V=sc package/rpcd/compile && \
    make V=sc package/cgi-io/compile && \
    make V=sc package/luci-base/compile && \
    make V=sc -j1 package/podkop/compile && \
    make V=sc -j1 package/luci-app-podkop/compile

# Clean up unnecessary files
RUN rm -rf /builder/build_dir/target* \
    /builder/staging_dir/target* \
    /builder/tmp