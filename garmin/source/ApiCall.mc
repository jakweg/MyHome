import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;

class ApiCall {

    hidden var mCallback; 
    function initialize(callback) {
        mCallback = callback;
    }

    function onReceive(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 || responseCode == 204) {
            System.println("Request Successful: " + responseCode);    
            // System.println(data);                  
            mCallback.invoke(true, data);
        } else {
            System.println("Response failed with status: " + responseCode);           
            mCallback.invoke(false, data);
        }
    }

    hidden function makeRequest(endpoint as String, params) as Void {
        var url = getAPIEndpointRoot() + endpoint;                        

        var options = {                                            
            :method => params == null ? Communications.HTTP_REQUEST_METHOD_GET : Communications.HTTP_REQUEST_METHOD_POST,     
            :headers => {                                          
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Authorization" => "Bearer " + getAPITokenString(),
            },
        
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(url, params, options, method(:onReceive));
    }

    function getDevices() as Void {
        makeRequest("devices", null);
    }

    function sendCommand(deviceId as String, code as String, value as String or Boolean) as Void {
        var body = {};
        body["code"] = code;
        body["value"] = value;
        makeRequest("device/" + deviceId + "/command", body);
    }
}