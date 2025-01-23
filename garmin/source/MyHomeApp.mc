import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PageLoopFactory extends WatchUi.ViewLoopFactory {
    hidden var mDevicesList;

    function initialize(devicesList) {
        ViewLoopFactory.initialize();
        mDevicesList = devicesList;
    }

    function getSize() as Lang.Number {
        return mDevicesList.size();
    }

    function getView(page as Lang.Number) as [ WatchUi.View ] or [ WatchUi.View, WatchUi.BehaviorDelegate ] {
        var device = mDevicesList[page];
        
        if (device["category"].equals("curtain")) {
            var view = new RollerPageView(device);
            return [ view, new RollerPageViewDelegate(view.weak()) ];
        } 

        if (device["category"].equals("triple-switch")) {
            var view = new TripleSwitchPageView(device);
            return [ view, new TripleSwitchPageViewDelegate(view.weak()) ];
        }


        var view = new UnsupportedDevicePageView(device);
        return [ view, new WatchUi.BehaviorDelegate() ];
    }

}

class MyHomeApp extends Application.AppBase {

    var rollerState;

    function initialize() {
        AppBase.initialize();
    }


    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var devices = Application.Storage.getValue("devices-list");
        if (devices == null || devices.size() == 0) {
            var delegate = new SyncDevicesDelegate();
            delegate.start();
            return [delegate.getView(), delegate];
        }


        var loop = new WatchUi.ViewLoop(new PageLoopFactory(devices),
        {:wrap => true});

        return [loop, new WatchUi.ViewLoopDelegate(loop)];
    }

}

function getApp() as MyHomeApp {
    return Application.getApp() as MyHomeApp;
}