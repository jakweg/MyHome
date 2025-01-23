import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class MyProgressDelegate extends WatchUi.BehaviorDelegate {
    hidden var mIssuedCommand;
    hidden var mDeviceId;
    function initialize(deviceId, issuedCommand) {
        BehaviorDelegate.initialize();
        mIssuedCommand = issuedCommand;
        mDeviceId = deviceId;
    }

    function start() {
        if (mIssuedCommand == :open) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "open");
        } else if (mIssuedCommand == :close) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "stop");
        } else {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "control", "close");
        }
    }

    function onBack() {
        return true;
    }

    function onFinished(ok, data) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        if (mIssuedCommand == :stop && ok) {
            WatchUi.showToast("Zatrzymano", {:icon=>Rez.Drawables.positiveToastIcon});
        } else if (ok) {
            WatchUi.showToast(mIssuedCommand == :open ? "Otwieranie" : "Zamykanie", {:icon=>Rez.Drawables.positiveToastIcon});
        } else {
            WatchUi.showToast("Nie udało się :(", {:icon=>Rez.Drawables.warningToastIcon});
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


class RollerPageViewDelegate extends WatchUi.BehaviorDelegate {
    hidden var mView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        mView = view;
    }

    function onSelect() as Boolean {
        mView.get().onSelect();
        return true;
    }

}

class RollerPageView extends WatchUi.View {

    hidden var mDevice;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.RollerLayout(dc));
        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Otwórz" }, :open));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Zamknij" }, :close));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Zatrzymaj" }, :stop));

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

        var label = "Zatrzymywanie";
        if (action == :open) {
            label = "Otwieranie";
        } else if (action == :close) {
            label = "Zamykanie";
        }

        var progressBar = new WatchUi.ProgressBar(label, null);
        var delegate = new MyProgressDelegate(mDevice["id"], action);
        WatchUi.pushView(
            progressBar,
            delegate,
            WatchUi.SLIDE_LEFT
        );

        delegate.start();
    }
}
