import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class DeviceDescription {
    var actions as Array<ActionSpecification>;
    function initialize(actions_ as Array<ActionSpecification>) {
        actions = actions_;
    }
}

function getGenericDeviceDescription(device as Dictionary) as DeviceDescription? {
    var category = device["category"];

    if ("light-switch".equals(category)) {
        return new DeviceDescription([
            new ActionSpecification("A", :switchLedOn, Rez.Strings.SwitchAction_LampOn, [:switchLedOff]),
            new ActionSpecification("B", :switchLedOff, Rez.Strings.SwitchAction_LampOff, [:switchLedOn])
        ]);
    }

    if ("switch".equals(category)) {
        return new DeviceDescription([
            new ActionSpecification("A", :switchOn, Rez.Strings.SwitchAction_On, [:switchOff]),
            new ActionSpecification("B", :switchOff, Rez.Strings.SwitchAction_Off, [:switchOn])
        ]);
    }

    if ("triple-switch".equals(category)) {
        return new DeviceDescription([
            new ActionSpecification("D", :switchOff2, Rez.Strings.TripleSwitchAction_Off2, [:switchOn2]),
            new ActionSpecification("F", :switchOff3, Rez.Strings.TripleSwitchAction_Off3, [:switchOn3]),
            new ActionSpecification("B", :switchOff1, Rez.Strings.TripleSwitchAction_Off1, [:switchOn1]),
            new ActionSpecification("A", :switchOn1, Rez.Strings.TripleSwitchAction_On1, [:switchOff1]),
            new ActionSpecification("C", :switchOn2, Rez.Strings.TripleSwitchAction_On2, [:switchOff2]),
            new ActionSpecification("E", :switchOn3, Rez.Strings.TripleSwitchAction_On3, [:switchOff3]),
        ]);
    }

    if ("curtain".equals(category)) {
        return new DeviceDescription([
            new ActionSpecification("A", :open,  Rez.Strings.CoverAction_Open, [:stop, :close]),
            new ActionSpecification("B", :stop,  Rez.Strings.CoverAction_Stop, [:open, :close]),
            new ActionSpecification("C", :close, Rez.Strings.CoverAction_Close, [:stop, :open]),
        ]);
    }

    return null;
}

class ActionCallback {
    hidden var m_deviceId as String, 
                       m_action as Symbol,
                       m_onFinished as Method;
    function initialize(deviceId as String, 
                       action as Symbol,
                       onFinished as Method) {
        m_deviceId = deviceId;
        m_action = action;
        m_onFinished = onFinished;
    }

    function invoke(ok, data) {
        m_onFinished.invoke(ok, m_deviceId, m_action);
    }
}

function executeAction(deviceId as String, 
                       action as Symbol,
                       onFinished as Method) {
    var call = new ApiCall(new ActionCallback(deviceId, action, onFinished));

    if (action == :switchLedOn) {
        call.sendCommand(deviceId, "switch_led", true);
    } else if (action == :switchLedOff) {
        call.sendCommand(deviceId, "switch_led", false);
    } else if (action == :switchOn) {
        call.sendCommand(deviceId, "switch_1", true);
    } else if (action == :switchOff) {
        call.sendCommand(deviceId, "switch_1", false);
    } else if (action == :switchOn1) {
        call.sendCommand(deviceId, "switch_1", true);
    } else if (action == :switchOn2) {
        call.sendCommand(deviceId, "switch_2", true);
    } else if (action == :switchOn3) {
        call.sendCommand(deviceId, "switch_3", true);
    } else if (action == :switchOff1) {
        call.sendCommand(deviceId, "switch_1", false);
    } else if (action == :switchOff2) {
        call.sendCommand(deviceId, "switch_2", false);
    } else if (action == :switchOff3) {
        call.sendCommand(deviceId, "switch_3", false);
    } else if (action == :open) {
        call.sendCommand(deviceId, "control", "open");
    } else if (action == :close) {
        call.sendCommand(deviceId, "control", "close");
    } else if (action == :stop) {
        call.sendCommand(deviceId, "control", "stop");
    }
}