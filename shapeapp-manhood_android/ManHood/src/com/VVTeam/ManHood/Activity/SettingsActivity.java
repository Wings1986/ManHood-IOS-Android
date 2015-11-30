package com.VVTeam.ManHood.Activity;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.app.TaskStackBuilder;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore.Images;
import android.support.v4.app.NavUtils;

import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.Fragment.GenericTextViewFragment;
import com.VVTeam.ManHood.Fragment.SettingsFragment;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 29.08.14.
 */
public class SettingsActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().hide();
        setContentView(R.layout.activity_settings);
        if (savedInstanceState == null) {
            openSettingsFragment(false);
        }
        
        GoogleTracker.StarSendView(this, SettingsActivity.class.getSimpleName());
    }


    public void openSettingsFragment(boolean isAddToBackStack) {
        SettingsFragment soughtForFragment = (SettingsFragment) getFragmentManager()
                .findFragmentByTag(Constants.SETTINGS_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = SettingsFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, newFragment, Constants.SETTINGS_FRAGMENT);
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.SETTINGS_FRAGMENT);
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
    
    public void openTellFriends() {
    	final Intent emailIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"));
	    emailIntent.putExtra(Intent.EXTRA_TEXT, "Help me map our Hood!\n#ManHoodApp");
	    startActivity(Intent.createChooser(emailIntent, "Tell a friend"));
    }
    
    public void openSupportActivity() {
        Intent intent = new Intent(SettingsActivity.this, SupportActivity.class);
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    public void openHelpActivity() {
        Intent intent = new Intent(SettingsActivity.this, HelpActivity.class);
        startActivity(intent);
        overridePendingTransition(R.anim.slide_in_right, R.anim.slide_out_left);
    }

    public void navigateUp() {
        Intent upIntent = NavUtils.getParentActivityIntent(this);
        if (NavUtils.shouldUpRecreateTask(this, upIntent)) {
            // This activity is NOT part of this app's task, so create a new task
            // when navigating up, with a synthesized back stack.
            TaskStackBuilder.create(this)
                    // Add all of this activity's parents to the back stack
                    .addNextIntentWithParentStack(upIntent)
                            // Navigate up to the closest parent
                    .startActivities();
        } else {
            // This activity is part of this app's task, so simply
            // navigate up to the logical parent activity.
            NavUtils.navigateUpTo(this, upIntent);
        }
        this.overridePendingTransition(R.anim.slide_in_right,
                R.anim.slide_out_left);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        this.overridePendingTransition(R.anim.slide_in_right,
                R.anim.slide_out_left);
    }
}
