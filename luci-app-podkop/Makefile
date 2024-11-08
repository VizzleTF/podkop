include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Podkop
LUCI_DEPENDS:=+podkop
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-podkop
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

# Explicitly define the language package
define Package/$(PKG_NAME)-i18n-ru/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/podkop.ru.lmo $(1)/usr/lib/lua/luci/i18n/podkop.ru.lmo
endef

# Call the default package build
$(eval $(call BuildPackage,$(PKG_NAME)))
# Build the Russian translation package
$(eval $(call BuildPackage,$(PKG_NAME)-i18n-ru))