import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;


class SelectVisibleDevicesViewDelegate extends WatchUi.Menu2InputDelegate {
    hidden var mView;

    function initialize(view) {
        Menu2InputDelegate.initialize();
        mView = view;
    }

    function onSelect(item) {
        var toggle = item as WatchUi.ToggleMenuItem;
        var deviceId = toggle.getId();
        var shouldShow = toggle.isEnabled();

        var hiddenIds = Application.Storage.getValue("hidden-ids");
        if (hiddenIds == null) {
            hiddenIds = [];
        }
        if (shouldShow) {
            hiddenIds.removeAll(deviceId);
        } else {
            hiddenIds.add(deviceId);
        }
        Application.Storage.setValue("hidden-ids", hiddenIds);
    }

}

function openSelectVisibleDevicesView() {
    var menu = new WatchUi.Menu2({:title=>"Widoczne urządzenia"});
    var hiddenIds = Toybox.Application.Storage.getValue("hidden-ids");
    if (hiddenIds == null) {
        hiddenIds = [];
    }
    var devices = Toybox.Application.Storage.getValue("devices-list");
    if (devices == null) {
        devices = [];
    }
    for (var i = 0; i < devices.size(); ++i) {
        var device = devices[i];
        menu.addItem(
            new ToggleMenuItem(
                device["name"],
                device["category"],
                device["id"],
                hiddenIds.indexOf(device["id"]) == -1,
                {}
            )
        );
    }

    var delegate = new SelectVisibleDevicesViewDelegate(menu.weak());

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
}