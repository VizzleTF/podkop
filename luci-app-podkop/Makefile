# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-podkop
PKG_VERSION:=0.2.3
PKG_RELEASE:=1

LUCI_TITLE:=LuCI podkop app
LUCI_DEPENDS:=+luci-base +liblua +libnl-tiny +podkop
LUCI_PKGARCH:=all
LUCI_DESCRIPTION:=Domain routing. Use of VLESS, Shadowsocks technologies

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=ITDog <podkop@itdog.info>

# Добавляем поддержку русского языка
PO2LMO:=$(TOPDIR)/scripts/po2lmo

# Определяем путь к файлам перевода
LUCI_LANG_PATH:=$(PKG_BUILD_DIR)/po
LUCI_LANG:=ru

# Правило для компиляции переводов
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
	[ ! -d $(LUCI_LANG_PATH)/$(LUCI_LANG) ] || { \
		mkdir -p $(PKG_BUILD_DIR)/po/tmp/; \
		$(PO2LMO) $(LUCI_LANG_PATH)/$(LUCI_LANG)/podkop.po $(PKG_BUILD_DIR)/po/tmp/podkop.$(LUCI_LANG).lmo; \
	}
endef

# Правило для установки переводов
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/po/tmp/podkop.$(LUCI_LANG).lmo $(1)/usr/lib/lua/luci/i18n/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature