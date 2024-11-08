FROM openwrt/sdk:x86_64-v23.05.5

RUN ./scripts/feeds update -a && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

COPY ./luci-i18n-podkop-ru /builder/package/feeds/luci/luci-i18n-podkop-ru

# Подготовка файла локализации
RUN mkdir -p /builder/package/feeds/luci/luci-i18n-podkop-ru/files && \
    po2lmo /builder/package/feeds/luci/luci-app-podkop/po/ru/podkop.po /builder/package/feeds/luci/luci-i18n-podkop-ru/files/podkop.ru.lmo

RUN make defconfig && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile && \
    make package/luci-i18n-podkop-ru/compile V=sc -j1