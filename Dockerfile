FROM openwrt/sdk:x86_64-v23.05.5

# Обновляем фиды и создаем директории
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Копируем исходники пакетов
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Собираем все необходимые инструменты и пакеты
RUN make defconfig && \
    make package/feeds/luci/luci-po/host/compile && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j4