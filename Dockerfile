FROM openwrt/sdk:x86_64-v23.05.5

# Создаем необходимые директории
RUN mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Обновляем фиды и устанавливаем необходимые пакеты
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    ./scripts/feeds install luci-base

# Копируем исходные файлы
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Конфигурируем и собираем
RUN make defconfig && \
    make package/luci-base/compile && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j4