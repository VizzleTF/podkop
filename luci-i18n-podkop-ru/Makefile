include $(TOPDIR)/rules.mk

LUCI_LANG.ru=Русский

LUCI_BASENAME:=podkop

LUCI_PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-i18n-podkop-ru
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=Русский перевод для luci-app-podkop
  DEPENDS:=luci-app-podkop
  PKGARCH:=all
endef

define Package/luci-i18n-podkop-ru/description
  Русский перевод для luci-app-podkop
endef

define Package/luci-i18n-podkop-ru/install
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n/
  $(INSTALL_DATA) $(PKG_BUILD_DIR)/podkop.ru.lmo $(1)/usr/lib/lua/luci/i18n/podkop.ru.lmo
endef

$(eval $(call BuildPackage,luci-i18n-podkop-ru))