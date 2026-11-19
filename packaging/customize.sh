#!/system/bin/sh

ui_print " "
ui_print "***********************************"
ui_print "   AFRd2 AV1 LayerFast Test Build  "
ui_print "***********************************"
ui_print "Magisk 24.3 compatible installer"

[ -f "$MODPATH/afrd" ] || abort "AFRd2 daemon is missing"
[ -f "$MODPATH/afrd.ini" ] || abort "AFRd2 configuration is missing"
[ -f "$MODPATH/service.sh" ] || abort "service.sh is missing"
[ -f "$MODPATH/afrd-disp.dex" ] || abort "SystemControl helper is missing"
[ -f "$MODPATH/afrd-disp.sh" ] || abort "SystemControl wrapper is missing"

set_perm "$MODPATH/afrd" 0 0 0755
set_perm "$MODPATH/afrd-disp.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/afrd.ini" 0 0 0644
set_perm "$MODPATH/afrd-disp.dex" 0 0 0644
set_perm "$MODPATH/module.prop" 0 0 0644

ui_print "Installation files and permissions checked."
ui_print "Reboot after installation."
