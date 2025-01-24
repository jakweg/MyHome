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
            WatchUi.showToast(Rez.Strings.ActionExecutedSuccessfully, {:icon=>Rez.Drawables.positiveToastIcon});
        } else {
            WatchUi.showToast(Rez.Strings.ActionFailure, {:icon=>Rez.Drawables.warningToastIcon});
        }
    }
}

class TripleSwitchPageViewDelegate extends GenericInputDelegate {
    hidden var mView;

    function initialize(view) {
        GenericInputDelegate.initialize();
        mView = view;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            mView.get().onSelect();
            return true;
        }
        return false;
    }

    function onTap(clickEvent) {
        var id = getIdOfClickedDrawable(clickEvent, mView.get().mDrawables.get() as Array);
        if ("on1".equals(id)) {
            mView.get().onActionSelected(:switchOn1);
            return true;
        } else if ("on2".equals(id)) {
            mView.get().onActionSelected(:switchOn2);
            return true;
        } else if ("on3".equals(id)) {
            mView.get().onActionSelected(:switchOn3);
            return true;
        } else if ("off1".equals(id)) {
            mView.get().onActionSelected(:switchOff1);
            return true;
        } else if ("off2".equals(id)) {
            mView.get().onActionSelected(:switchOff2);
            return true;
        } else if ("off3".equals(id)) {
            mView.get().onActionSelected(:switchOff3);
            return true;
        }
        return false;
    }
}

class TripleSwitchPageView extends WatchUi.View {

    hidden var mDevice as Dictionary;
    var mDrawables;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        var drawables = Rez.Layouts.TripleLightLayout(dc);
        mDrawables = drawables.weak();
        setLayout(drawables);
        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_On1 }, :switchOn1));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_Off1 }, :switchOff1));

        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_On2 }, :switchOn2));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_Off2 }, :switchOff2));

        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_On3 }, :switchOn3));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.TripleSwitchAction_Off3 }, :switchOff3));

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelected))
        );
    }

    function onActionSelected(actionId) as Void {
        var label;
        if (actionId == :switchOn1 || actionId == :switchOn2 || actionId == :switchOn3) {
            label = Rez.Strings.TurningOn;
        } else if (actionId == :switchOff1 || actionId == :switchOff2 || actionId == :switchOff3) {
            label = Rez.Strings.TurningOff;
        } else {
            return;
        }

        var progressBar = new WatchUi.ProgressBar(loadResource(label), null);
        var delegate = new MyProgressDelegateTripleSwitch(mDevice["id"], actionId);
        WatchUi.pushView(
            progressBar,
            delegate,
            WatchUi.SLIDE_LEFT
        );

        delegate.start();
    }
}
