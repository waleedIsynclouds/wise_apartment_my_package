package com.example.wise_apartment.utils;

import java.util.Map;
import com.example.hxjblinklibrary.blinkble.entity.requestaction.BlinkyAuthAction;

public class PluginUtils {
    /**
     * Helper to create BlinkyAuthAction from MethodChannel arguments.
     */
    public static BlinkyAuthAction createAuthAction(Map<String, Object> args) {
        BlinkyAuthAction auth = new BlinkyAuthAction();
        auth.setAuthCode((String) args.get("authCode"));
        auth.setDnaKey((String) args.get("dnaKey"));
        auth.setMac((String) args.get("mac"));
        
        if (args.containsKey("keyGroupId")) {
            Object val = args.get("keyGroupId");
            if (val instanceof Integer) auth.setKeyGroupId((Integer) val);
        }
        
        if (args.containsKey("bleProtocolVer")) {
            Object val = args.get("bleProtocolVer");
            if (val instanceof Integer) auth.setBleProtocolVer((Integer) val);
        }
        
        return auth;
    }
}
