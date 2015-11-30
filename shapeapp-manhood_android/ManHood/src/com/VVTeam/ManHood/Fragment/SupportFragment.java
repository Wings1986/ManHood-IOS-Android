package com.VVTeam.ManHood.Fragment;

import java.util.Random;

import android.app.Fragment;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 08.09.14.
 */
public class SupportFragment extends Fragment {

    private RelativeLayout sendSupportEmailRelative;

    public static SupportFragment newInstance() {
        SupportFragment fragment = new SupportFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initViews(view);
    }

    private void initViews(View view) {
        sendSupportEmailRelative = (RelativeLayout) view.findViewById(R.id.fragment_support_send_a_support_email_relative);
        sendSupportEmailRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            	int min = 0, max = 1000;
            	Random r = new Random();
            	int fakerand = r.nextInt(max - min + 1) + min;
            	
                String subject     = "Support/Feedback #100" + fakerand;
                
                String body = String.format("\n\n\n\n------------------\nPlease do not remove this part\n78ef31%s629a4ac\n %s %s %s version: %s %s\n-----------------------------------",
                					getUserID(),
                					AppData.getInstance().selfUserData == null ? "UnKnown" : AppData.getInstance().selfUserData.getDevice(),
                					getDeviceName(),
                					getAndroidVersion(),
                					getVersion(),
                					AppData.getInstance().isMale() ? "Male" : "Female");
               
                
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("mailto:" + getString(R.string.support_email_address)));
                intent.putExtra(Intent.EXTRA_SUBJECT, subject);
                intent.putExtra(Intent.EXTRA_TEXT, body);
                startActivity(Intent.createChooser(intent, "Send email to support"));
            }
        });
    }

       
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_support, container, false);
    }
    
    public String getUserID() {
	 	final String AB = "0123456789abcdefjhijklmnopqrstuvwxyz";
	    Random rnd = new Random();

	    int len = 30;
	    StringBuilder sb = new StringBuilder( len );
        for( int i = 0; i < len; i++ )
            sb.append( AB.charAt( rnd.nextInt(AB.length()) ) );
        return sb.toString();
    }
    public String getDeviceName() {
 	   String manufacturer = Build.MANUFACTURER;
 	   String model = Build.MODEL;
 	   if (model.startsWith(manufacturer)) {
 	      return capitalize(model);
 	   } else {
 	      return capitalize(manufacturer) + " " + model;
 	   }
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
 	public String getAndroidVersion() {
 	    String release = Build.VERSION.RELEASE;
 	    int sdkVersion = Build.VERSION.SDK_INT;
 	    return "Android SDK: " + sdkVersion + " (" + release +")";
 	}
 	
 	public String getVersion() {
 		PackageInfo pInfo = null;
		try {
			pInfo = getActivity().getPackageManager().getPackageInfo(getActivity().getPackageName(), 0);
			return pInfo.versionName;
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
 		return "";
 	}
}
