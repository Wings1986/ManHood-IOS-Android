package com.VVTeam.ManHood.Activity;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.app.TaskStackBuilder;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.DataModel.ETUnitConverter;
import com.VVTeam.ManHood.DataModel.HistogramBin;
import com.VVTeam.ManHood.DataModel.SelfUserData;
import com.VVTeam.ManHood.DataModel.UsersData;
import com.VVTeam.ManHood.Fragment.CertificateFragment;
import com.VVTeam.ManHood.View.Histogram;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 28.08.14.
 */
public class CertificateActivity extends Activity {

    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().hide();
        setContentView(R.layout.activity_certificate);
        if (savedInstanceState == null) {
            openCertificateFragment(false);
        }
        GoogleTracker.StarSendView(this, CertificateActivity.class.getSimpleName());
    }

    private void openCertificateFragment(boolean isAddToBackStack) {
        CertificateFragment soughtForFragment = (CertificateFragment) getFragmentManager()
                .findFragmentByTag(Constants.CERTIFICATE_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = CertificateFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.replace(R.id.content_frame, newFragment, Constants.CERTIFICATE_FRAGMENT);
        ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.CERTIFICATE_FRAGMENT);
        }
        ft.commit();
    }

    public void openGuideActivity() {
        Intent intent = new Intent(CertificateActivity.this, GuideActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                navigateUp();
                return true;
        }
        return super.onOptionsItemSelected(item);
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
        this.overridePendingTransition(android.R.anim.slide_in_left,
                android.R.anim.slide_out_right);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();

        this.overridePendingTransition(android.R.anim.slide_in_left,
                android.R.anim.slide_out_right);
    }
    
    
}
