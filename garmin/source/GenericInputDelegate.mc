import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;


class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    hidden var mView;

    function initialize(view) {
        Menu2InputDelegate.initialize();
        mView = view;
    }

    function onSelect(item) {
        if (item.getId() == :syncDevices) {
            var delegate = new SyncDevicesDelegate();
            delegate.start();
            WatchUi.pushView(delegate.getView(), delegate, WatchUi.SLIDE_LEFT);
        } else if (item.getId() == :hideDevices) {
            openSelectVisibleDevicesView();
        }
    }

}

class GenericInputDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=>Rez.Strings.OptionsListTitle});
        menu.addItem(
            new MenuItem(
                Rez.Strings.OptionsList_SyncDevices,
                null,
                :syncDevices,
                {}
            )
        );
        menu.addItem(
            new MenuItem(
                Rez.Strings.OptionsList_HideDevices,
                null,
                :hideDevices,
                {}
            )
        );

        var delegate = new SettingsDelegate(menu.weak());
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);

        return true;
    }
}