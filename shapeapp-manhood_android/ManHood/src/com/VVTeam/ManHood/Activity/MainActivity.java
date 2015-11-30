package com.VVTeam.ManHood.Activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;

import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.Fragment.GenericTextViewFragment;
import com.VVTeam.ManHood.Fragment.HistogramFragment;
import com.VVTeam.ManHood.Fragment.WelcomeFragment;
import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.RequestManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.sbstrm.appirater.Appirater;

public class MainActivity extends Activity {
    /**
     * Called when the activity is first created.
     */
	
	EasyRatingDialog easyRatingDialog;
	
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        RequestManager.getInstance().init(MainActivity.this);
        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            if (AppData.getInstance().isMale() != null) {
                openHistogramFragment(false);
            } else {
                openWelcomeFragment(false);
            }
        }
        
        Appirater.appLaunched(this); 
        
        GoogleTracker.StarSendView(this, MainActivity.class.getSimpleName());
        
        CheckGPS();
        
        easyRatingDialog = new EasyRatingDialog(this);
    }

    private void CheckGPS()
    {

        LocationManager manager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        boolean statusOfGPS = manager.isProviderEnabled(LocationManager.GPS_PROVIDER);

        if (!statusOfGPS)
        {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setCancelable(true);
            builder.setTitle("Please enable GPS");
            builder.setMessage("You have to enable GPS");
            builder.setPositiveButton("Yes", new OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					Intent gpsOptionsIntent = new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                    startActivity(gpsOptionsIntent);
				}
			}); 
            builder.show();
        }
    }
    
    @Override
    protected void onStart() {
      super.onStart();
      easyRatingDialog.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        getActionBar().hide();
        easyRatingDialog.showIfNeeded();
    }

    public void openCertificateActivity() {
        Intent intent = new Intent(MainActivity.this, CertificateActivity.class);
        startActivity(intent);
        this.overridePendingTransition(R.anim.slide_in_right,
                R.anim.slide_out_left);
    }

    public void openSettingsActivity() {
        Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
        startActivity(intent);
        this.overridePendingTransition(android.R.anim.slide_in_left,
                android.R.anim.slide_out_right);
    }
    
    public void openGuideActivity() {
        Intent intent = new Intent(MainActivity.this, GuideActivity.class);
        startActivity(intent);
        this.overridePendingTransition(R.anim.slide_in_right,
                R.anim.slide_out_left);
    }

    
    public void openHistogramFragment(boolean isAddToBackStack) {
        HistogramFragment soughtForFragment = (HistogramFragment) getFragmentManager()
                .findFragmentByTag(Constants.HISTOGRAM_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = HistogramFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.add(R.id.content_frame, newFragment, Constants.HISTOGRAM_FRAGMENT);
        //ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        //ft.setCustomAnimations(R.drawable.translate_from_bottom_to_top, R.drawable.translate_from_bottom_to_top);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.HISTOGRAM_FRAGMENT);
        }
        ft.commit();
        AppData.getInstance().handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                removeWelcomeScreen();
            }
        }, 600);
    }

    private void removeWelcomeScreen() {
        WelcomeFragment soughtForFragment = (WelcomeFragment) getFragmentManager()
                .findFragmentByTag(Constants.WELCOME_FRAGMENT);
        if (soughtForFragment == null) {
            //if (soughtForFragment.isVisible()) {
            return;
            //}
        }
        if (!soughtForFragment.isAdded()) {
            return;
        }

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.remove(soughtForFragment);
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        ft.commit();
        Log.d("MainActivity", "Welcome Screen removed");
    }

    public void openWelcomeFragment(boolean isAddToBackStack) {
        WelcomeFragment soughtForFragment = (WelcomeFragment) getFragmentManager()
                .findFragmentByTag(Constants.WELCOME_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = WelcomeFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, newFragment, Constants.WELCOME_FRAGMENT);
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.WELCOME_FRAGMENT);
        }
        ft.commit();
    }


    public void openGenericTextViewFragment(boolean isAddToBackStack, int resourceId) {
        GenericTextViewFragment soughtForFragment = (GenericTextViewFragment) getFragmentManager()
                .findFragmentByTag(Constants.GENERIC_TEXT_VIEW_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = GenericTextViewFragment.newInstance(resourceId);

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.add(R.id.content_frame, newFragment, Constants.GENERIC_TEXT_VIEW_FRAGMENT);
        //ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.GENERIC_TEXT_VIEW_FRAGMENT);
        }
        ft.commit();
    }
}
