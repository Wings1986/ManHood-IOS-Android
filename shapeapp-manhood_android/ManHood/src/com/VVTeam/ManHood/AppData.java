package com.VVTeam.ManHood;

import android.content.Context;
import android.content.SharedPreferences;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;

import com.VVTeam.ManHood.DataModel.SelfUserData;
import com.VVTeam.ManHood.DataModel.UsersData;
import com.VVTeam.ManHood.Enum.ObservableType;
import com.VVTeam.ManHood.Enum.TextSettingType;
import com.VVTeam.ManHood.Observable.ObservableWithPublicSetChanged;
import com.VVTeam.ManHood.UIModel.GuideItemModel;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;

/**
 * Created by blase on 29.08.14.
 */
public class AppData {
    public static final String PREFERENCES = "preferences";
    public static final String KEY_IS_MALE = "is_male";
    public static final String KEY_HIDE_PERSONAL_DATA = "hide_personal_data";
    public static final String KEY_UNITS_TYPE = "units_type";
    public static final String KEY_UUID = "user_uuid";
    public static final String KEY_AUTH_TOKEN = "key_auth_token";
    public static final String KEY_USER_SETTINGS = "userSettings";
    public static final String KEY_JOB_ID = "job_id";
    public static final String KEY_MODEL = "model";
    public static final String KEY_IMAGE_REF = "image_ref";
    public static final String KEY_IMAGE_FRONT = "image_front";
    public static final String KEY_IMAGE_SIDE = "image_side";
    public static final String KEY_LOCATION = "location";
    public static final String KEY_WIDTH = "width";
    public static final String KEY_HEIGHT = "height";
    public static final String KEY_RECEIPT = "receipt";
    
    public static final String KEY_ERROR_MSG = "error_msg";
    public static final String KEY_ERROR_CODE = "error_code";
    public static final String KEY_DEVICE_MODEL = "model";
    public static final String KEY_DEVICE_MANU = "manufacturer";
    public static final String KEY_DEVICE_WIDTH = "device_width";
    public static final String KEY_DEVICE_HEIGHT = "device_height";

    public static final String AUTH_PREFERENCES = "auth_preferences";
    public static final String USER_PREFERENCES = "user_preferences";
    public static final String HTTP_X_SESSION_ID = "HTTP_X_SESSION_ID";
    public static final String X_SESSION_ID = "X-SESSION-ID";
    
    public static final String KEY_IAP_SUBSCRIPT = "key_i";

    public Context context;
    public List<GuideItemModel> guideItemList;
    public Handler handler;
    public SelfUserData selfUserData;
    public JSONObject userData;

    public ObservableWithPublicSetChanged authObservable;
    public ObservableWithPublicSetChanged histogramsObservable;
    public ObservableWithPublicSetChanged selfUserDataObservable;
    public ObservableWithPublicSetChanged analyPhotoObservable;

    public void init(Context context) {
        this.context = context;
        authObservable = new ObservableWithPublicSetChanged(ObservableType.AUTH);
        histogramsObservable = new ObservableWithPublicSetChanged(ObservableType.HISTO);
        selfUserDataObservable = new ObservableWithPublicSetChanged(ObservableType.SELF_USER_DATA);
        analyPhotoObservable = new ObservableWithPublicSetChanged(ObservableType.ANALY_PHOTO);
        
        initSelfUserData();
    }

    public void initSelfUserData() {
        //TODO init self user data
    }

    public void saveSelfUserData(SelfUserData userData) {
        this.selfUserData = userData;
        //TODO save self user data in permanent memory
    }
    public void saveUsersData(JSONObject jsonObj) {
    	this.userData = jsonObj;
        //TODO save self user data in permanent memory
    }

    public void initGuideItemList() {
        guideItemList = new ArrayList<GuideItemModel>();
        guideItemList.add(new GuideItemModel(R.drawable.guide_il_1, context.getString(R.string.step_1), context.getString(R.string.step_1_description)));
        guideItemList.add(new GuideItemModel(R.drawable.guide_il_2, context.getString(R.string.step_2), context.getString(R.string.step_2_description)));
        guideItemList.add(new GuideItemModel(R.drawable.guide_il_3, context.getString(R.string.step_3), context.getString(R.string.step_3_description)));
        guideItemList.add(new GuideItemModel(R.drawable.guide_il_4, context.getString(R.string.step_4), context.getString(R.string.step_4_description)));
        guideItemList.add(new GuideItemModel(R.drawable.guide_il_5, context.getString(R.string.step_5), context.getString(R.string.step_5_description)));
        boolean isMale = isMale();
        guideItemList.add(new GuideItemModel(R.drawable.ready_to_go_icon, context.getString(isMale ? R.string.ready_male_title : R.string.ready_female_title),
                context.getString(isMale ? R.string.ready_male_description : R.string.ready_female_description)));
    }

    /*public String getDeviceModelName() {
        return "Nexus 5";
    }*/

    public String getDeviceModelName() {
        String manufacturer = getDeviceManufacturer();
        String model = getDeviceMode();
        if (model.startsWith(manufacturer)) {
            return capitalize(model);
        } else {
            return capitalize(manufacturer) + " " + model;
        }
    }
    public String getDeviceMode() {
    	return Build.MODEL;
    }
    public String getDeviceManufacturer() {
    	return Build.MANUFACTURER;
    }

    public Location getCurrentLocation() {
        LocationManager manager = (LocationManager) context
                .getSystemService(Context.LOCATION_SERVICE);
        Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.ACCURACY_FINE);
        String provider = manager.getBestProvider(criteria, true);
        Location bestLocation;
        if (provider != null)
            bestLocation = manager.getLastKnownLocation(provider);
        else
            bestLocation = null;
        Location latestLocation = getLatest(bestLocation,
                manager.getLastKnownLocation(LocationManager.GPS_PROVIDER));
        latestLocation = getLatest(latestLocation,
                manager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER));
        latestLocation = getLatest(latestLocation,
                manager.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER));
        return latestLocation;
    }

    /**
     * Get the location with the later date
     *
     * @param location1
     * @param location2
     * @return location
     */
    private static Location getLatest(final Location location1,
                                      final Location location2) {
        if (location1 == null)
            return location2;

        if (location2 == null)
            return location1;

        if (location2.getTime() > location1.getTime())
            return location2;
        else
            return location1;
    }


    private String capitalize(String s) {
        if (s == null || s.length() == 0) {
            return "";
        }
        char first = s.charAt(0);
        if (Character.isUpperCase(first)) {
            return s;
        } else {
            return Character.toUpperCase(first) + s.substring(1);
        }
    }

    public Boolean isMale() {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        if (sp.contains(KEY_IS_MALE)) {
            return sp.getBoolean(KEY_IS_MALE, true);
        }
        return null;
    }

    public void saveGenderChoice(boolean isMale) {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putBoolean(KEY_IS_MALE, isMale);
        edit.commit();
    }

    public boolean isHidePersonalData() {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        return sp.getBoolean(KEY_HIDE_PERSONAL_DATA, false);
    }

    public void switchHidePersonalData() {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putBoolean(KEY_HIDE_PERSONAL_DATA, !sp.getBoolean(KEY_HIDE_PERSONAL_DATA, false));
        edit.commit();
    }

    public TextSettingType getUnitsType() {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        return TextSettingType.fromString(sp.getString(KEY_UNITS_TYPE, TextSettingType.IN.toString()));
    }

    public void saveUnitsType(TextSettingType unitsType) {
        SharedPreferences sp = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(KEY_UNITS_TYPE, unitsType.toString());
        edit.commit();
    }

    public void saveAuthData(String uuid, String authToken) {
        SharedPreferences sp = context.getSharedPreferences(AUTH_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(KEY_UUID, uuid);
        edit.putString(KEY_AUTH_TOKEN, authToken);
        edit.commit();
    }

    public void saveAuthToken(String authToken) {
        SharedPreferences sp = context.getSharedPreferences(AUTH_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(KEY_AUTH_TOKEN, authToken);
        edit.commit();
    }

    public void saveAuthData(String uuid, String authToken, boolean isMale) {
        SharedPreferences sp = context.getSharedPreferences(AUTH_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(KEY_UUID, uuid);
        edit.putString(KEY_AUTH_TOKEN, authToken);
        edit.putBoolean(KEY_IS_MALE, isMale);
        edit.commit();
    }

    public String getUUID() {
        SharedPreferences sp = context.getSharedPreferences(AUTH_PREFERENCES, Context.MODE_PRIVATE);
        Log.d("user UUID", "user UUID: " + sp.getString(KEY_UUID, ""));
        return sp.getString(KEY_UUID, "");
    }

    public String getAuthToken() {
        SharedPreferences sp = context.getSharedPreferences(AUTH_PREFERENCES, Context.MODE_PRIVATE);
        return sp.getString(KEY_AUTH_TOKEN, "");
    }

    public void setJobId(String jobId) {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putString(KEY_JOB_ID, jobId);
        edit.commit();
    }

    public String getJobId() {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        if (sp.contains(KEY_JOB_ID)) {
            return sp.getString(KEY_JOB_ID, "");
        }
        return null;
    }

    public void setSubscriptionValid(boolean subscript) {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor edit = sp.edit();
        edit.putBoolean(KEY_IAP_SUBSCRIPT, subscript);
        edit.commit();
    }

    public boolean isSubscriptionValid() {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        if (sp.contains(KEY_IAP_SUBSCRIPT)) 
        {
            return sp.getBoolean(KEY_IAP_SUBSCRIPT, false);
        }
        return false;
    }
    
    public void setDeviceWidthHeight(float width, float height) {
    	 SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
         SharedPreferences.Editor edit = sp.edit();
         edit.putFloat(KEY_DEVICE_WIDTH, width);
         edit.putFloat(KEY_DEVICE_HEIGHT, height);
         edit.commit();
    }
    public float getDeviceWidth() {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        if (sp.contains(KEY_DEVICE_WIDTH)) {
            return sp.getFloat(KEY_DEVICE_WIDTH, 1.0f);
        }
        return 1.0f;
    }
    public float getDeviceHeight() {
        SharedPreferences sp = context.getSharedPreferences(USER_PREFERENCES, Context.MODE_PRIVATE);
        if (sp.contains(KEY_DEVICE_HEIGHT)) {
            return sp.getFloat(KEY_DEVICE_HEIGHT, 1.0f);
        }
        return 1.0f;
    }
    
    // Debug
    void writeToFile(String data) {
    	try {
    	      File root = new File(Environment.getExternalStorageDirectory(), "HistogramDebug");
    	        if (!root.exists()) {
    	            root.mkdirs();
    	        }
    	        File gpxfile = new File(root, "log.txt");
    	        FileWriter writer = new FileWriter(gpxfile);
    	        writer.append(data);
    	        writer.flush();
    	        writer.close();
    	} catch (IOException e) {
          Log.e("Exception", "File write failed: " + e.toString());
      } 
        
//        try {
//            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("log.txt", Context.MODE_PRIVATE));
//            outputStreamWriter.write(data);
//            outputStreamWriter.close();
//        }
//        catch (IOException e) {
//            Log.e("Exception", "File write failed: " + e.toString());
//        } 
    }


    private static AppData instance;

    public static AppData getInstance() {
        if (instance == null) {
            instance = new AppData();
        }
        return instance;
    }

    private AppData() {
    }
}
