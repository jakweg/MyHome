import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class MyProgressDelegateLight extends WatchUi.BehaviorDelegate {
    hidden var mIssuedCommand;
    hidden var mDeviceId;
    hidden var mHideProgressView;
    function initialize(deviceId, issuedCommand, hideProgressView) {
        BehaviorDelegate.initialize();
        mIssuedCommand = issuedCommand;
        mDeviceId = deviceId;
        mHideProgressView = hideProgressView;
    }

    function start() {
        if (mIssuedCommand == :switchOn) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_led", true);
        } else if (mIssuedCommand == :switchOff) {
            new ApiCall(method(:onFinished)).sendCommand(mDeviceId, "switch_led", false);
        }
    }

    function onBack() {
        return true;
    }

    function onFinished(ok, data) {
        if (mHideProgressView) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
        if (!ok) {
            WatchUi.showToast(Rez.Strings.ActionFailure, {:icon=>Rez.Drawables.warningToastIcon});
        }
    }
}

class LightPageViewDelegate extends GenericInputDelegate {
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
        if ("on".equals(id)) {
            mView.get().onActionSelected2(:switchOn, false);
            return true;
        } else if ("off".equals(id)) {
            mView.get().onActionSelected2(:switchOff, false);
            return true;
        }
        return false;
    }
}

class LightPageView extends WatchUi.View {

    hidden var mDevice as Dictionary;
    var mDrawables;

    function initialize(device) {
        View.initialize();
        mDevice = device;
    }

    function onLayout(dc as Dc) as Void {
        var drawables = Rez.Layouts.SingleLightLayout(dc);
        mDrawables = drawables.weak();
        setLayout(drawables);
        (findDrawableById("deviceName") as Text).setText(mDevice["name"]);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onSelect() {
        var menu = new WatchUi.ActionMenu(null);
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.SwitchAction_LampOn }, :switchOn));
        menu.addItem(new WatchUi.ActionMenuItem({ :label => Rez.Strings.SwitchAction_LampOff }, :switchOff));

        WatchUi.showActionMenu(
            menu,
            new MyActionMenuDelegate(method(:onActionSelected))
        );
    }

    function onActionSelected(actionId) as Void {
        onActionSelected2(actionId, true);
    }

    function onActionSelected2(actionId, showProgressView) as Void {
        var label;
        if (actionId == :switchOn) {
            label = Rez.Strings.TurningOn;
        } else if (actionId == :switchOff) {
            label = Rez.Strings.TurningOff;
        } else {
            return;
        }

        var progressBar = new WatchUi.ProgressBar(loadResource(label), null);
        var delegate = new MyProgressDelegateLight(mDevice["id"], actionId, showProgressView);
        if (showProgressView) {
            WatchUi.pushView(
                progressBar,
                delegate,
                WatchUi.SLIDE_LEFT
            );
        }

        delegate.start();
    }
}
