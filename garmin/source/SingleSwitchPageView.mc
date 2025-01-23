import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class MyProgressDelegateSingleSwitch extends WatchUi.BehaviorDelegate {
    hidden var mIssuedCommand;
    hidden var mDeviceId;
    function initialize(deviceId, issuedCommand) {
        BehaviorDelegate.initialize();
        mIssuedCommand = issuedCommand;
        mDeviceId = deviceId;
    }

    function start() {
        if (mIssuedCommand == :switchOn) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_1", true);
        } else if (mIssuedCommand == :switchOff) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_1", false);
        }
    }

    function onBack() {
        return true;
    }

    function onFinished(ok, data) {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        if (ok) {
            WatchUi.showToast("Wykonano", {:icon=>Rez.Drawables.positiveToastIcon});
        } else {
            WatchUi.showToast("Nie udało się :(", {:icon=>Rez.Drawables.warningToastIcon});
        }
    }
}

class SingleSwitchPageViewDelegate extends GenericInputDelegate {
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

class SingleSwitchPageView extends WatchUi.View {

    hidden var mDevice;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.TripleLightLayout(dc));
        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Włącz" }, :switchOn));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Wyłącz" }, :switchOff));

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelected))
        );
    }

    function onActionSelected(actionId) as Void {
        var label;
        if (actionId == :switchOn) {
            label = "Włączanie";
        } else if (actionId == :switchOff) {
            label = "Wyłączanie";
        } else {
            return;
        }

        var progressBar = new WatchUi.ProgressBar(label, null);
        var delegate = new MyProgressDelegateSingleSwitch(mDevice["id"], actionId);
        WatchUi.pushView(
            progressBar,
            delegate,
            WatchUi.SLIDE_LEFT
        );

        delegate.start();
    }
}
