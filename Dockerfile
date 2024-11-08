FROM openwrt/sdk:x86_64-v23.05.5

# Обновляем и устанавливаем фиды
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Копируем исходники пакетов
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Применяем конфигурацию и собираем пакеты с подробным выводом
RUN make defconfig && \
    make -j1 V=sc && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s