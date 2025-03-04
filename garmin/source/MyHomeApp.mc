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

        var description = getGenericDeviceDescription(device);

        Toybox.Application.Storage.setValue("last-device-id", device["id"]);

        if (description != null) {
            var view = new GenericDevicePage(device, description);
            return [ view, view.getDelegate() ];
        }

        var view = new UnsupportedDevicePageView(device);
        return [ view, new GenericInputDelegate() ];
    }
}

class MyHomeApp extends Application.AppBase {

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

        var lastUsedDeviceId = Toybox.Application.Storage.getValue("last-device-id");

        var hiddenIds = Toybox.Application.Storage.getValue("hidden-ids");
        if (hiddenIds == null) {
            hiddenIds = [];
        }

        var filteredDevices = [];
        var pageNumber = 0;
        for (var i = 0; i < devices.size(); ++i) {
            var device = devices[i] as Dictionary?;
            var id = device["id"];
            if (hiddenIds.indexOf(id) == -1) {
                filteredDevices.add(device);
                if (id.equals(lastUsedDeviceId)) {
                    pageNumber = filteredDevices.size() - 1;
                }
            }
        }
        if (filteredDevices.size() == 0) {
            filteredDevices = devices;
        }

        var factory = new PageLoopFactory(filteredDevices);
        var loop = new WatchUi.ViewLoop(factory, { 
            :wrap => true, 
            :page => pageNumber,
        });
    
        return [loop, new WatchUi.ViewLoopDelegate(loop)];
    }

}

function getApp() as MyHomeApp {
    return Application.getApp() as MyHomeApp;
}