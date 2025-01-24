import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PageLoopFactory extends WatchUi.ViewLoopFactory {
    hidden var mDevicesList as Array;

    function initialize(devicesList) {
        ViewLoopFactory.initialize();
        mDevicesList = devicesList;
    }

    function getSize() as Lang.Number {
        return mDevicesList.size();
    }

    function getView(page as Lang.Number) as [ WatchUi.View ] or [ WatchUi.View, WatchUi.BehaviorDelegate ] {
        var device = mDevicesList[page] as Dictionary;
        var category = device["category"];
        
        if (category.equals("curtain")) {
            var view = new CoverPageView(device);
            return [ view, new CoverPageViewDelegate(view.weak()) ];
        } 

        if (category.equals("triple-switch")) {
            var view = new TripleSwitchPageView(device);
            return [ view, new TripleSwitchPageViewDelegate(view.weak()) ];
        }

        if (category.equals("light-switch")) {
            var view = new LightPageView(device);
            return [ view, new LightPageViewDelegate(view.weak()) ];
        }

        if (category.equals("switch")) {
            var view = new SingleSwitchPageView(device);
            return [ view, new SingleSwitchPageViewDelegate(view.weak()) ];
        }


        var view = new UnsupportedDevicePageView(device);
        return [ view, new GenericInputDelegate() ];
    }
}

class MyHomeApp extends Application.AppBase {

    var coverState;

    function initialize() {
        AppBase.initialize();
    }


    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var devices = Application.Storage.getValue("devices-list") as Array?;
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
            var device = devices[i] as Dictionary?;
            if (hiddenIds.indexOf(device["id"]) == -1) {
                filteredDevices.add(device);
            }
        }
        if (filteredDevices.size() == 0) {
            filteredDevices = devices;
        }

        var factory = new PageLoopFactory(filteredDevices);
        var loop = new WatchUi.ViewLoop(factory, {:wrap => true});
    
        return [loop, new WatchUi.ViewLoopDelegate(loop)];
    }

}

function getApp() as MyHomeApp {
    return Application.getApp() as MyHomeApp;
}