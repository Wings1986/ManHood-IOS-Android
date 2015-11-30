package com.VVTeam.ManHood.Activity;

import android.app.ActionBar;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.NavUtils;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.TextView;

import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.Fragment.CameraFragment;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 12.09.14.
 */
public class CameraActivity extends FragmentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        setContentView(R.layout.activity_camera);
        getActionBar().setBackgroundDrawable(new ColorDrawable(Color.argb(60, 0, 0, 0)));
        getActionBar().setDisplayShowCustomEnabled(true);
        getActionBar().setDisplayShowTitleEnabled(false);
        View customTitleView = getLayoutInflater().inflate(R.layout.actionbar_custom_title, null, false);
        ((TextView) customTitleView.findViewById(R.id.actionbar_title_text_view)).setText(R.string.camera_caps);
        ActionBar.LayoutParams params = new ActionBar.LayoutParams(//Center the textview in the ActionBar !
                ActionBar.LayoutParams.WRAP_CONTENT, 
                ActionBar.LayoutParams.MATCH_PARENT, 
                Gravity.CENTER);
        getActionBar().setCustomView(customTitleView, params);
        if (savedInstanceState == null) {
            openCameraFragment(false);
        }
        
        GoogleTracker.StarSendView(this, CameraActivity.class.getSimpleName());
    }

    /*@Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.fragment_camera, menu);
        return super.onCreateOptionsMenu(menu);
    }*/

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                navigateUp();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void openCameraFragment(boolean isAddToBackStack) {
        CameraFragment soughtForFragment = (CameraFragment) getFragmentManager()
                .findFragmentByTag(Constants.CAMERA_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = CameraFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, newFragment, Constants.CAMERA_FRAGMENT);
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.CAMERA_FRAGMENT);
        }
        ft.commit();
    }

    @Override
    public void onBackPressed() {
        navigateUp();
        //super.onBackPressed();
    }
    
    public void openMainActivity() {
        Intent intent = new Intent(CameraActivity.this, MainActivity.class);
        startActivity(intent);
        this.overridePendingTransition(R.anim.slide_in_right,
                R.anim.slide_out_left);
        finish();
    }


    private void navigateUp() {
        CameraFragment cameraFragment = (CameraFragment) getFragmentManager().findFragmentByTag(Constants.CAMERA_FRAGMENT);
        if (cameraFragment != null) {
            if (cameraFragment.isVisible()) {
                if (cameraFragment.navigateUp()) {
                    return;
                }
            }
        }
        Intent upIntent;
        //if (!isFromSettings) {
        upIntent = NavUtils.getParentActivityIntent(this);
                /*} else {
                    final ComponentName target = new ComponentName(this,
                            "com.VVTeam.ManHood.Activity.HelpActivity"
                    );
                    upIntent = new Intent().setComponent(target);
                    upIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                }*/
        if (NavUtils.shouldUpRecreateTask(this, upIntent)) {
            // This activity is NOT part of this app's task, so create a new task
            // when navigating up, with a synthesized back stack.
            android.support.v4.app.TaskStackBuilder.create(this)
                    // Add all of this activity's parents to the back stack
                    .addNextIntentWithParentStack(upIntent)
                            // Navigate up to the closest parent
                    .startActivities();
        } else {
            // This activity is part of this app's task, so simply
            // navigate up to the logical parent activity.
            NavUtils.navigateUpTo(this, upIntent);
        }
    }
}
