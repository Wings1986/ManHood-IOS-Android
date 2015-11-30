package com.VVTeam.ManHood.Activity;

import android.app.ActionBar;
import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.app.TaskStackBuilder;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.TextView;

import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.Fragment.GenericTextViewFragment;
import com.VVTeam.ManHood.Fragment.HelpFragment;
import com.VVTeam.ManHood.Fragment.SupportFragment;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 08.09.14.
 */
public class HelpActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        setContentView(R.layout.activity_support);
        getActionBar().setBackgroundDrawable(new ColorDrawable(Color.argb(60, 0, 0, 0)));
        getActionBar().setDisplayShowCustomEnabled(true);
        getActionBar().setDisplayShowTitleEnabled(false);
        getActionBar().setDisplayUseLogoEnabled(false);
        View customTitleView = getLayoutInflater().inflate(R.layout.actionbar_custom_title, null, false);
        ((TextView) customTitleView.findViewById(R.id.actionbar_title_text_view)).setText(R.string.help_caps);
        ActionBar.LayoutParams params = new ActionBar.LayoutParams(//Center the textview in the ActionBar !
                ActionBar.LayoutParams.WRAP_CONTENT, 
                ActionBar.LayoutParams.MATCH_PARENT, 
                Gravity.CENTER);
        getActionBar().setCustomView(customTitleView, params);
        if (savedInstanceState == null) {
            openHelpFragment(false);
        }
        
        GoogleTracker.StarSendView(this, HelpActivity.class.getSimpleName());
    }

    public void openHelpFragment(boolean isAddToBackStack) {
        HelpFragment soughtForFragment = (HelpFragment) getFragmentManager()
                .findFragmentByTag(Constants.SUPPORT_FRAGMENT);
        if (soughtForFragment != null) {
            if (soughtForFragment.isVisible()) {
                return;
            }
        }
        Fragment newFragment = HelpFragment.newInstance();

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.add(R.id.content_frame, newFragment, Constants.SUPPORT_FRAGMENT);
        //ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.SUPPORT_FRAGMENT);
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
        Fragment newFragment = GenericTextViewFragment.newInstance(resourceId, true);

        FragmentTransaction ft = getFragmentManager().beginTransaction();
        ft.add(R.id.content_frame, newFragment, Constants.GENERIC_TEXT_VIEW_FRAGMENT);
        //ft.setTransition(FragmentTransaction.TRANSIT_NONE);
        if (isAddToBackStack) {
            ft.addToBackStack(Constants.GENERIC_TEXT_VIEW_FRAGMENT);
        }
        ft.commit();
    }

    public void openGuideActivity() {
        Intent intent = new Intent(HelpActivity.this, GuideActivity.class);
        intent.putExtra("is_from_settings", true);
        startActivity(intent);
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

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                navigateUp();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

}
