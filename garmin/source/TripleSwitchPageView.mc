import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class MyProgressDelegateTripleSwitch extends WatchUi.BehaviorDelegate {
    hidden var mIssuedCommand;
    hidden var mDeviceId;
    function initialize(deviceId, issuedCommand) {
        BehaviorDelegate.initialize();
        mIssuedCommand = issuedCommand;
        mDeviceId = deviceId;
    }

    function start() {
        if (mIssuedCommand == :switchOn1) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_1", true);
        } else if (mIssuedCommand == :switchOn2) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_2", true);
        } else if (mIssuedCommand == :switchOn3) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_3", true);
        } else if (mIssuedCommand == :switchOff1) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_1", false);
        } else if (mIssuedCommand == :switchOff2) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_2", false);
        } else if (mIssuedCommand == :switchOff3) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_3", false);
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

class TripleSwitchPageViewDelegate extends GenericInputDelegate {
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

class TripleSwitchPageView extends WatchUi.View {

    hidden var mDevice as Dictionary;

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
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Włącz pierwszą lampę" }, :switchOn1));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Wyłącz pierwszą lampę" }, :switchOff1));

        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Włącz drugą lampę" }, :switchOn2));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Wyłącz drugą lampę" }, :switchOff2));

        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Włącz trzecią lampę" }, :switchOn3));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => "Wyłącz trzecią lampę" }, :switchOff3));

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelected))
        );
    }

    function onActionSelected(actionId) as Void {
        var label;
        if (actionId == :switchOn1 || actionId == :switchOn2 || actionId == :switchOn3) {
            label = "Włączanie";
        } else if (actionId == :switchOff1 || actionId == :switchOff2 || actionId == :switchOff3) {
            label = "Wyłączanie";
        } else {
            return;
        }

        var progressBar = new WatchUi.ProgressBar(label, null);
        var delegate = new MyProgressDelegateTripleSwitch(mDevice["id"], actionId);
        WatchUi.pushView(
            progressBar,
            delegate,
            WatchUi.SLIDE_LEFT
        );

        delegate.start();
    }
}
