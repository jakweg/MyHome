import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SyncDevicesDelegate extends WatchUi.InputDelegate {

    hidden var mView;
    function initialize() {
        InputDelegate.initialize();
        mView = new WatchUi.ProgressBar(
            "Synchronizowania urządzeń",
            null
        );
    }

    function getView() {
        return mView;
    }
    function onBack() {
        return true;
    }

    function start() {
        new ApiCall(method(:mDevicesDownloaded)).getDevices();
    }

    function mDevicesDownloaded(ok, data as Dictionary) as Void {
        if (!ok) {
            WatchUi.showToast("Niepowodzenie", {:icon=>Rez.Drawables.warningToastIcon});
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return;
        }

        Application.Storage.setValue("devices-list", data["devices"]);

        WatchUi.showToast("Zsynchronizowano", {:icon=>Rez.Drawables.positiveToastIcon});
        WatchUi.popView(WatchUi.SLIDE_BLINK);
    }
}