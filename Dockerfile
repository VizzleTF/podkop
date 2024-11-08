FROM openwrt/sdk:x86_64-v23.05.5

# Create required directories
RUN mkdir -p /builder/package/feeds/utilites/ \
    /builder/package/feeds/luci/

# Update feeds and install only required packages
RUN ./scripts/feeds update luci && \
    ./scripts/feeds install luci-base

# Copy source files
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Configure build with minimal options
RUN cp .config .config.orig && \
    echo 'CONFIG_PACKAGE_luci-base=y' > .config && \
    echo 'CONFIG_PACKAGE_podkop=y' >> .config && \
    echo 'CONFIG_PACKAGE_luci-app-podkop=y' >> .config && \
    make defconfig

# Build only required packages
RUN make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j$(nproc)

# Clean up unnecessary files
RUN rm -rf /builder/build_dir/target* \
    /builder/staging_dir/target* \
    /builder/tmp