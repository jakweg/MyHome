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
        return [ view, new GenericInputDelegate() ];
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

        var hiddenIds = Toybox.Application.Storage.getValue("hidden-ids");
        if (hiddenIds == null) {
            hiddenIds = [];
        }

        var filteredDevices = [];
        for (var i = 0; i < devices.size(); ++i) {
            var device = devices[i] as Dictionary<String, String>;
            if (hiddenIds.indexOf(device["id"]) == -1) {
                filteredDevices.add(device);
            }
        }
        if (filteredDevices.size() == 0) {
            filteredDevices = devices;
        }

        var loop = new WatchUi.ViewLoop(new PageLoopFactory(filteredDevices),
        {:wrap => true});

        return [loop, new WatchUi.ViewLoopDelegate(loop)];
    }

}

function getApp() as MyHomeApp {
    return Application.getApp() as MyHomeApp;
}