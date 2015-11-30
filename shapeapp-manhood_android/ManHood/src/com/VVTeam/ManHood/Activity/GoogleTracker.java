package com.VVTeam.ManHood.Activity;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import android.content.Context;


public class GoogleTracker {

	static final String  kGAIKey = "UA-50531426-2";
	
	public static void StarRunStatus(Context mContext, int status, String mCatagory, String mAction, String mLabel) {
		
		Tracker tracker = GoogleAnalytics.getInstance(mContext).newTracker(kGAIKey);
		tracker.enableAdvertisingIdCollection(true);
	}
	

	public static void StarSendView(Context mContext, String mView) {
		
		Tracker tracker = GoogleAnalytics.getInstance(mContext).newTracker(kGAIKey);
		tracker.enableAdvertisingIdCollection(true);
		
		tracker.setScreenName(mView);
		
		// Set screen name.
		tracker.setScreenName(mView);

		// Send a screen view.
		tracker.send(new HitBuilders.AppViewBuilder().build());
		
	}

	public static void StarSendEvent(Context mContext, String mCatagory, String mAction, String mLabel) {
		
		Tracker tracker = GoogleAnalytics.getInstance(mContext).newTracker(kGAIKey);
		tracker.enableAdvertisingIdCollection(true);
		
			// Build and send an Event.
		tracker.send(new HitBuilders.EventBuilder()
			    .setCategory(mCatagory)
			    .setAction(mAction)
			    .setLabel(mLabel)
			    .build());
			
	}
	
}
