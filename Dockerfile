FROM openwrt/sdk:x86_64-v23.05.5

# Создаем необходимые директории
RUN mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Обновляем только необходимые фиды
RUN ./scripts/feeds update luci && \
    ./scripts/feeds install luci-base po2lmo

# Копируем исходные файлы
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Подготавливаем конфигурацию только для необходимых пакетов
RUN make defconfig && \
    echo "CONFIG_PACKAGE_luci-base=y" >> .config && \
    echo "CONFIG_PACKAGE_podkop=y" >> .config && \
    echo "CONFIG_PACKAGE_luci-app-podkop=y" >> .config && \
    make oldconfig

# Собираем пакеты
RUN make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j$(nproc)