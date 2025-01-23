import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class UnsupportedDevicePageView extends WatchUi.View {
    hidden var mDevice;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.UnsupportedDeviceLayout(dc));

        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }
}
