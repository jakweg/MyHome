import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class GenericDeviceDelegate extends GenericInputDelegate {
    hidden var mView as WeakReference<GenericDevicePage>;

    function initialize(view as GenericDevicePage) {
        GenericInputDelegate.initialize();
        mView = view.weak();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            mView.get().onSelect();
            return true;
        }
        return false;
    }

    function onTap(clickEvent) {
        return mView.get().onTap(clickEvent);
    }
}

class GenericDevicePage extends WatchUi.View {

    hidden var mDevice as Dictionary;
    hidden var mDescription as DeviceDescription;
    hidden var mPanel as ActionButtonPanel;

    function initialize(device, description as DeviceDescription) {
        View.initialize();
        mDevice = device;
        mDescription = description;
        mPanel = new ActionButtonPanel(description.actions, method(:onActionSelected));
    }

    function getDelegate() as GenericDeviceDelegate {
        return new GenericDeviceDelegate(self);
    }

    function onLayout(dc as Dc) as Void {
        var drawables = Rez.Layouts.GenericDeviceLayout(dc);

        mPanel.onLayout(dc);
        drawables.add(mPanel);

        setLayout(drawables);

        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onTap(clickEvent) as Boolean {
        var coords = clickEvent.getCoordinates() as Array;
        var x = coords[0];
        var y = coords[1];

        return mPanel.onTap(x, y);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        var s = mDescription.actions.size();
        for (var i = 0;i < s; ++i) {
            var action = mDescription.actions[i];
            menu.addItem(new WatchUi.ActionMenuItem({ :label => action.mName }, action.mId));
        }

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelectedViaButtonMenu))
        );
    }

    function onActionSelectedViaButtonMenu(id) as Void {
        // just a hack to make connect iq platform less broken
        WatchUi.pushView(new DummyView(), null, WatchUi.SLIDE_IMMEDIATE);
        onActionSelected(id);
    }

    function onActionSelected(id) as Void {
        executeAction(mDevice["id"], id, method(:actionExecuted));
        mPanel.onRequestedAction(id);
    }

    function actionExecuted(ok, deviceId, actionId) {
        if (!mDevice["id"].equals(deviceId)) {
            return;
        }
        mPanel.onActionExecuted(actionId);
        // System.println("action executed " + ok);
    }
}

class DummyView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onShow() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}