FROM openwrt/sdk:x86_64-v23.05.5

# Обновляем и устанавливаем feeds
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a && \
    ./scripts/feeds install luci-base

# Создаём необходимые директории
RUN mkdir -p /builder/package/feeds/utilities/ && \
    mkdir -p /builder/package/feeds/luci/

# Копируем исходники пакетов
COPY ./podkop /builder/package/feeds/utilities/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop
COPY ./luci-i18n-podkop-ru /builder/package/feeds/luci/luci-i18n-podkop-ru

# Обновляем индексы пакетов
RUN ./scripts/feeds update -i

# Конфигурируем и собираем
RUN make defconfig && \
    make package/feeds/utilities/podkop/compile V=sc && \
    make package/feeds/luci/luci-app-podkop/compile V=sc && \
    make package/feeds/luci/luci-i18n-podkop-ru/compile V=sc