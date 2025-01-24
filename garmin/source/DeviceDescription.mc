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
            // new ActionSpecification("A", :a), new ActionSpecification("B", :b), new ActionSpecification("C", :c),
            // new ActionSpecification("D", :a), new ActionSpecification("E", :b), new ActionSpecification("F", :c),
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
    if (action == :switchLedOn) {
        new ApiCall(new ActionCallback(deviceId, action, onFinished)).sendCommand(deviceId, "switch_led", true);
    } else if (action == :switchLedOff) {
        new ApiCall(new ActionCallback(deviceId, action, onFinished)).sendCommand(deviceId, "switch_led", false);
    }
}