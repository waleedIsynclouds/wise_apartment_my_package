package com.example.wise_apartment.utils;

import android.util.Log;
import java.util.HashMap;
import java.util.Map;

import com.example.hxjblinklibrary.blinkble.entity.reslut.LockKeyResult;

/**
 * LockKeyResultMapper
 * 
 * Converts LockKeyResult objects from the HXJ SDK to Maps that can be
 * transmitted to Flutter via EventChannel/MethodChannel.
 * 
 * Note: LockKeyResult represents a SINGLE key, not a collection.
 */
public class LockKeyResultMapper {
    private static final String TAG = "LockKeyResultMapper";

    /**
     * Convert a LockKeyResult (single key) to a Map.
     * 
     * @param result The LockKeyResult from the SDK (represents one key)
     * @return Map representation of the key
     */
    public static Map<String, Object> toMap(LockKeyResult result) {
        Map<String, Object> map = new HashMap<>();
        if (result == null) return map;

        try {
            map.put("isMore", result.isMore());
            map.put("keyNum", result.getKeyNum());
            map.put("modifyTimestamp", result.getModifyTimestamp());
            map.put("vaildMode", result.getVaildMode());
            map.put("weeks", result.getWeeks());
            map.put("dayStartTimes", result.getDayStartTimes());
            map.put("dayEndTimes", result.getDayEndTimes());
            map.put("keyType", result.getKeyType());
            map.put("appUserID", result.getAppUserID());
            map.put("keyID", result.getKeyID());
            map.put("vaildNumber", result.getVaildNumber());
            map.put("vaildStartTime", result.getVaildStartTime());
            map.put("vaildEndTime", result.getVaildEndTime());
            map.put("deleteMode", result.getDeleteMode());
            map.put("key", result.getKey());
        } catch (Exception e) {
            Log.e(TAG, "Failed to convert LockKeyResult to map", e);
        }

        return map;
    }

    /**
     * Get the keyNum from a LockKeyResult.
     * 
     * @param result The LockKeyResult from the SDK
     * @return The keyNum value, or 0 if unavailable
     */
    public static int getKeyNum(LockKeyResult result) {
        if (result == null) return 0;
        try {
            return result.getKeyNum();
        } catch (Exception e) {
            Log.e(TAG, "Failed to get keyNum from LockKeyResult", e);
            return 0;
        }
    }
}
