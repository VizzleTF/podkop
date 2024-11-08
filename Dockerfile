FROM openwrt/sdk:x86_64-v23.05.5

# Установка необходимых инструментов для работы с переводами
RUN apt-get update && apt-get install -y gettext

# Обновление feeds
RUN ./scripts/feeds update -a && \
    ./scripts/feeds install -a

# Создание необходимых директорий
RUN mkdir -p /builder/package/feeds/utilites/ && \
    mkdir -p /builder/package/feeds/luci/

# Копирование исходных файлов
COPY ./podkop /builder/package/feeds/utilites/podkop
COPY ./luci-app-podkop /builder/package/feeds/luci/luci-app-podkop

# Подготовка и компиляция переводов
RUN cd /builder/package/feeds/luci/luci-app-podkop && \
    # Создание директории для скомпилированных переводов
    mkdir -p po/ru/LC_MESSAGES && \
    # Компиляция .po файла в .mo
    msgfmt po/ru/podkop.po -o po/ru/LC_MESSAGES/podkop.mo

# Сборка пакетов
RUN make defconfig && \
    make package/podkop/compile && \
    make package/luci-app-podkop/compile V=s -j4