package com.VVTeam.ManHood;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

import android.app.Application;
import android.os.Handler;

/**
 * Created by blase on 29.08.14.
 */
public class ManHoodApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        AppData.getInstance().init(getBaseContext());
        AppData.getInstance().handler = new Handler();
        RequestManager.getInstance().init(getBaseContext());
        
        RequestManager.getInstance().getDeviceDimension();

    }
}
