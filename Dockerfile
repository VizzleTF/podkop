FROM openwrt/sdk:x86_64-v23.05.5

# Создаем необходимые директории
RUN mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Обновляем и устанавливаем все необходимые фиды
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

# Устанавливаем необходимые пакеты для работы с lua и netlink
RUN ./scripts/feeds install libnl-tiny && \
    ./scripts/feeds install luci-base && \
    ./scripts/feeds install liblua

# Копируем исходные файлы
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Подготавливаем конфигурацию
RUN make defconfig && \
    echo "CONFIG_PACKAGE_lua=y" >> .config && \
    echo "CONFIG_PACKAGE_liblua=y" >> .config && \
    echo "CONFIG_PACKAGE_libnl-tiny=y" >> .config && \
    echo "CONFIG_PACKAGE_luci-base=y" >> .config && \
    echo "CONFIG_PACKAGE_podkop=y" >> .config && \
    echo "CONFIG_PACKAGE_luci-app-podkop=y" >> .config && \
    make oldconfig

# Собираем пакеты
RUN make package/luci-base/compile V=s && \
    make package/podkop/compile V=s && \
    make package/luci-app-podkop/compile V=s -j$(nproc)