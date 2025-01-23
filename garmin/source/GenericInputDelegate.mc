import Toybox.WatchUi;

class GenericInputDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        openSelectVisibleDevicesView();
        return true;
    }
}