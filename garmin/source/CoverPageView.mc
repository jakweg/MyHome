import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class MyProgressDelegate extends GenericInputDelegate {
    hidden var mIssuedCommand;
    hidden var mDeviceId;
    function initialize(deviceId, issuedCommand) {
        GenericInputDelegate.initialize();
        mIssuedCommand = issuedCommand;
        mDeviceId = deviceId;
    }

    function start() {
        if (mIssuedCommand == :open) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "open");
        } else if (mIssuedCommand == :close) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "close");
        } else {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "stop");
        }
    }

    function onBack() {
        return true;
    }

    function onFinished(ok, data) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        if (mIssuedCommand == :stop && ok) {
            WatchUi.showToast(Rez.Strings.ActionExecutedStopping, {:icon=>Rez.Drawables.positiveToastIcon});
        } else if (ok) {
            WatchUi.showToast(mIssuedCommand == :open ? Rez.Strings.ActionExecutedOpening : Rez.Strings.ActionExecutedClosing, {:icon=>Rez.Drawables.positiveToastIcon});
        } else {
            WatchUi.showToast(Rez.Strings.ActionFailure, {:icon=>Rez.Drawables.warningToastIcon});
        }
    }
}

class MyActionMenuDelegate extends WatchUi.ActionMenuDelegate {
    hidden var mOnActionSelected;
    function initialize(onActionSelected) {
        mOnActionSelected = onActionSelected;
        ActionMenuDelegate.initialize();
    }

    function onBack() as Void { 
    }

    function onSelect(item as WatchUi.ActionMenuItem) as Void {
        mOnActionSelected.invoke(item.getId());
    }
}


class CoverPageViewDelegate extends GenericInputDelegate {
    hidden var mView;

    function initialize(view) {
        GenericInputDelegate.initialize();
        mView = view;
    }

    function onSelect() as Boolean {
        mView.get().onSelect();
        return true;
    }

}

class CoverPageView extends WatchUi.View {

    hidden var mDevice as Dictionary;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.CoverLayout(dc));
        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.CoverAction_Open }, :open));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.CoverAction_Close }, :close));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.CoverAction_Stop }, :stop));

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelected))
        );
    }

    function onActionSelected(actionId) as Void {
        var action;
        if (actionId == :close) {
            action = :close;
        } else if (actionId == :open) { 
            action = :open;
        } else if (actionId == :stop) { 
            action = :stop;
        } else {
            return;
        }

        var label = Rez.Strings.ActionExecutedStopping;
        if (action == :open) {
            label = Rez.Strings.ActionExecutedOpening;
        } else if (action == :close) {
            label = Rez.Strings.ActionExecutedClosing;
        }

        var progressBar = new WatchUi.ProgressBar(loadResource(label), null);
        var delegate = new MyProgressDelegate(mDevice["id"], action);
        WatchUi.pushView(
            progressBar,
            delegate,
            WatchUi.SLIDE_LEFT
        );

        delegate.start();
    }
}
