package com.VVTeam.ManHood.Activity;

import android.app.ActionBar;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.support.v4.view.ViewPager;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.TextView;

import com.VVTeam.ManHood.Adapter.GuidePagerAdapter;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.R;
import com.viewpagerindicator.CirclePageIndicator;

/**
 * Created by blase on 29.08.14.
 */
public class GuideActivity extends Activity {

    private boolean isFromSettings;
    private ViewPager guideViewPager;
    private GuidePagerAdapter guideViewPagerAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        isFromSettings = getIntent().getBooleanExtra("is_from_settings", false);
        AppData.getInstance().initGuideItemList();	
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        setContentView(R.layout.activity_guide);
        getActionBar().setBackgroundDrawable(new ColorDrawable(Color.argb(60, 0, 0, 0)));
        getActionBar().setDisplayShowCustomEnabled(true);
        getActionBar().setDisplayShowTitleEnabled(false);
        ActionBar.LayoutParams params = new ActionBar.LayoutParams(//Center the textview in the ActionBar !
                ActionBar.LayoutParams.WRAP_CONTENT, 
                ActionBar.LayoutParams.MATCH_PARENT, 
                Gravity.CENTER);
        
        View customTitleView = getLayoutInflater().inflate(R.layout.actionbar_custom_title, null, false);
        ((TextView) customTitleView.findViewById(R.id.actionbar_title_text_view)).setText(R.string.how_to_guide);
        getActionBar().setCustomView(customTitleView, params);
        
        GoogleTracker.StarSendView(this, GuideActivity.class.getSimpleName());
        
        
        guideViewPager = (ViewPager) findViewById(R.id.activity_guide_view_pager);
        if (AppData.getInstance().guideItemList == null) {
            AppData.getInstance().initGuideItemList();
        }
        AppData.getInstance().guideItemList.get(AppData.getInstance().guideItemList.size() - 1).setOnClickListener(AppData.getInstance().isMale() ? new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openCameraActivity();
            }
        } : new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                navigateUp();
            }
        });
        guideViewPagerAdapter = new GuidePagerAdapter(GuideActivity.this, AppData.getInstance().guideItemList);
        guideViewPager.setAdapter(guideViewPagerAdapter);
        //Necessary or the pager will only have one extra page to show
        // make this at least however many pages you can see
        guideViewPager.setOffscreenPageLimit(2);//soonToTheCinemaAdapter.getCount());
        //A little space between pages
        /*int margin = (int) TypedValue
                .applyDimension(TypedValue.COMPLEX_UNIT_DIP, 57, getResources().getDisplayMetrics());
        guideViewPager.setPageMargin(-margin);*/
        //If hardware acceleration is enabled, you should also remove
        // clipping on the pager for its children.
        guideViewPager.setClipChildren(false);

        CirclePageIndicator titleIndicator = (CirclePageIndicator) findViewById(R.id.activity_guide_view_pager_indicator);
        titleIndicator.setViewPager(guideViewPager);
    }

    public void openCameraActivity() {
        Intent intent = new Intent(GuideActivity.this, CameraActivity.class);
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

    private void navigateUp() {
        Intent upIntent;
        if (!isFromSettings) {
            upIntent = NavUtils.getParentActivityIntent(this);
        } else {
            final ComponentName target = new ComponentName(this,
                    "com.VVTeam.ManHood.Activity.HelpActivity"
            );
            upIntent = new Intent().setComponent(target);
            upIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        }
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
