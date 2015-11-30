package com.VVTeam.ManHood.Fragment;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.Fragment;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Environment;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
import android.text.style.TypefaceSpan;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.VVTeam.ManHood.Activity.CameraActivity;
import com.VVTeam.ManHood.Activity.CertificateActivity;
import com.VVTeam.ManHood.Activity.GoogleTracker;
import com.VVTeam.ManHood.Activity.MainActivity;
import com.VVTeam.ManHood.DataModel.ETUnitConverter;
import com.VVTeam.ManHood.DataModel.HistogramBin;
import com.VVTeam.ManHood.DataModel.SelfUserData;
import com.VVTeam.ManHood.DataModel.UsersData;
import com.VVTeam.ManHood.Helper.DialogCallBack;
import com.VVTeam.ManHood.Helper.DialogHelper;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.View.ETWatermarkView;
import com.VVTeam.ManHood.View.Histogram;
import com.VVTeam.ManHood.Widget.AutoScaleTextView;
import com.VVTeam.ManHood.Widget.CustomTypefaceSpan;

/**
 * Created by blase on 28.08.14.
 */
public class CertificateFragment extends Fragment {

	public static final String TAG = "CertificateFragment";
	
	
//	UIImageView *backView;

	RelativeLayout certificateView;
	ETWatermarkView watermarkView;

	TextView lengthLabel;
	TextView thicknessLabel;
	TextView thickestAtLabel;
	TextView curvatureLabel;
	TextView dateLabel;
	TextView deviceLabel;

	Histogram lengthHisto;
	Histogram girthHisto;
	Histogram thicknessHisto;
	
	
    public UsersData usersData;
    public SelfUserData selfUserData;
    
    
    private TextView titleTextView;
    private RelativeLayout histogramRelative;
    private RelativeLayout photoRelative;


    private TextView manhoodLabelTextView;
    private EditText usernameTextField;

    private Button saveToPhotoLibraryButton;


    public static CertificateFragment newInstance() {
        CertificateFragment fragment = new CertificateFragment();
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
    	
        titleTextView = (TextView) view.findViewById(R.id.fragment_certificate_title_text_view);
        titleTextView.setText(getSpannableStringBuilderManHood(getString(R.string.manhood)));
        histogramRelative = (RelativeLayout) view.findViewById(R.id.fragment_certificate_histogram_relative_layout);
        photoRelative = (RelativeLayout) view.findViewById(R.id.fragment_certificate_photo_relative_layout);
        saveToPhotoLibraryButton = (Button) view.findViewById(R.id.fragment_certificate_save_to_photo_library_button);
        
        certificateView = (RelativeLayout) view.findViewById(R.id.certificateView);
        lengthLabel = (TextView) view.findViewById(R.id.certificate_row_length_text_view);
        thicknessLabel = (TextView) view.findViewById(R.id.certificate_row_thickness_text_view);
        thickestAtLabel = (TextView) view.findViewById(R.id.certificate_row_thickest_at_text_view);
        curvatureLabel = (TextView) view.findViewById(R.id.certificate_row_curvature_text_view);
        dateLabel = (TextView) view.findViewById(R.id.certificate_row_date_of_issue_text_view);
        deviceLabel = (TextView) view.findViewById(R.id.certificate_row_device_text_view);

        usernameTextField = (EditText) view.findViewById(R.id.certificate_row_username_text_view);
        usernameTextField.setText("username");
        usernameTextField.setOnKeyListener(new OnKeyListener() {
			
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				// TODO Auto-generated method stub
				if (event.getAction() == KeyEvent.ACTION_DOWN) {
					if (keyCode == KeyEvent.KEYCODE_ENTER) {
						setWatermarkText(usernameTextField.getText().toString());
					}
				}
				return false;
			}
		});
        
        manhoodLabelTextView = (TextView) view.findViewById(R.id.certificate_row_username_label_text_view);
        manhoodLabelTextView.setText(getSpannableStringBuilderManHood(getString(R.string.manhood__)));
        
        lengthHisto = (Histogram) view.findViewById(R.id.lengthHisto);
        lengthHisto.setClickable(false);
        thicknessHisto = (Histogram) view.findViewById(R.id.thicknessHisto);
        thicknessHisto.setClickable(false);
        girthHisto = (Histogram) view.findViewById(R.id.girthHisto);
        girthHisto.setClickable(false);
        
        watermarkView = (ETWatermarkView) view.findViewById(R.id.watermarkview);
        
        
        histogramRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((CertificateActivity) getActivity()).navigateUp();
            }
        });
        photoRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((CertificateActivity) getActivity()).openGuideActivity();
            }
        });
        saveToPhotoLibraryButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            	
            	usernameTextField.clearFocus();
            	
            	if ( !shouldHideData() ) {
            		if (usernameTextField.getText().toString().equalsIgnoreCase("username")) {
            			DialogHelper.getConfirmationDialog(getActivity(),
                    			"Username is not set",
                    			"Entering a Username is optional",
                    			"Enter username",
                    			"Continue",
                    			new DialogCallBack() {

            						@Override
            						public void onClick(int which) {
            							// TODO Auto-generated method stub
            							if (which == 0) { //ok
            								usernameTextField.setSelection(0);
            								usernameTextField.post(new Runnable() {
												
												@Override
												public void run() {
													// TODO Auto-generated method stub
													usernameTextField.requestFocus();
												}
											});
            							}
            							else {
            								storeImage(makeCertificate());
            							}

            						}
            					}).show();
            			
            		}
            		else {
            			storeImage(makeCertificate());
            		}
            	
            	}
            }
        });
        
        initView();
    }

    private void storeImage(Bitmap image) {
        File pictureFile = getOutputMediaFile();
        if (pictureFile == null) {
            Log.d(TAG, "Error creating media file, check storage permissions: ");// e.getMessage());
            return;
        } 
        try {
            FileOutputStream fos = new FileOutputStream(pictureFile);
            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.close();
            
            
        	GoogleTracker.StarSendEvent(getActivity(), "ui_action", "user_action", "certificate_saved");

            DialogHelper.getConfirmationDialog(getActivity(),
        			"Photo Saved",
        			"This photo has been saved to the device",
        			"OK",
        			null,
        			new DialogCallBack() {

						@Override
						public void onClick(int which) {
							// TODO Auto-generated method stub
							if (which == 0) { //ok
							}
							else {
							}

						}
					}).show();
            
        } catch (FileNotFoundException e) {
            Log.d(TAG, "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d(TAG, "Error accessing file: " + e.getMessage());
        }  
    }
    private  File getOutputMediaFile(){
        // To be safe, you should check that the SDCard is mounted
        // using Environment.getExternalStorageState() before doing this. 
        File mediaStorageDir = new File(Environment.getExternalStorageDirectory()
                + "/"
                + getActivity().getResources().getString(R.string.app_name));

        // This location works best if you want the created images to be shared
        // between applications and persist after your app has been uninstalled.

        // Create the storage directory if it does not exist
        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                return null;
            }
        } 
        
        // Create a media file name
        String timeStamp = new SimpleDateFormat("ddMMyyyy_HHmm", Locale.US).format(Calendar.getInstance().getTime());
        File mediaFile;
        String mImageName="MI_"+ timeStamp +".jpg";
        mediaFile = new File(mediaStorageDir.getPath() + File.separator + mImageName);  
        return mediaFile;
    } 
    
    private SpannableStringBuilder getSpannableStringBuilderManHood(String s) {
        SpannableStringBuilder sb = new SpannableStringBuilder(s);
        Typeface exoExtraLight = Typeface.createFromAsset(getActivity().getAssets(), "fonts/exo-extra_light.ttf");
        Typeface exoExtraBold = Typeface.createFromAsset(getActivity().getAssets(), "fonts/exo-extra_bold.ttf");

        TypefaceSpan exoExtraSpan = new CustomTypefaceSpan("", exoExtraLight);
        TypefaceSpan exoExtraBoldSpan = new CustomTypefaceSpan("", exoExtraBold);

        sb.setSpan(exoExtraSpan, 0, 3, Spannable.SPAN_INCLUSIVE_INCLUSIVE);

        sb.setSpan(exoExtraBoldSpan, 3, s.length(), Spannable.SPAN_INCLUSIVE_INCLUSIVE);
        return sb;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_certificate, container, false);
    }
    
    
    private void initView() {
    	try {
    		JSONObject jsonObj = new JSONObject(loadJSONFromAsset("json/All_json.txt"));
    		usersData = new UsersData(jsonObj.getJSONObject("All"));
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    	
    	selfUserData = AppData.getInstance().selfUserData;
    	
//        lengthHisto.setBins(createBinsFromEdges(usersData.getlengthBins(), usersData.getlengthCounts()));
//        girthHisto.bins = createBinsFromEdges(usersData.getgirthBins(), usersData.getgirthCounts());
//        thicknessHisto.bins = createBinsFromEdges(usersData.getthicknessBins(), usersData.getthicknessCounts());
        
//        lengthHisto.secondHighlightedBinColor = lengthLabel.getCurrentTextColor();
//        girthHisto.secondHighlightedBinColor = thickestAtLabel.getCurrentTextColor();
//        thicknessHisto.secondHighlightedBinColor = thicknessLabel.textColor;

        
        if ( shouldHideData() ) {
            
            String naText = "---";
            lengthLabel.setText(naText);
            thicknessLabel.setText(naText);
            thickestAtLabel.setText(naText);
            curvatureLabel.setText(naText);
            dateLabel.setText(naText);
            deviceLabel.setText(naText);
            
            usernameTextField.setVisibility(View.GONE);

        } else {
            
//            int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
            
            lengthLabel.setText(String.format("%.1f %s / %.1f %s",
            					 selfUserData.getLength(),
            					 ETUnitConverter.nameForUnitType(ETUnitConverter.ConverterUnitTypeCM),
            					 ETUnitConverter.convertCMValue(selfUserData.getLength(), ETUnitConverter.ConverterUnitTypeINCH),
                                 ETUnitConverter.nameForUnitType(ETUnitConverter.ConverterUnitTypeINCH)));
            
            thicknessLabel.setText(String.format("%.1f %s / %.1f %s",
					 			selfUserData.getGirth(),
					 			ETUnitConverter.nameForUnitType(ETUnitConverter.ConverterUnitTypeCM),
					 			ETUnitConverter.convertCMValue(selfUserData.getGirth(), ETUnitConverter.ConverterUnitTypeINCH),
					 			ETUnitConverter.nameForUnitType(ETUnitConverter.ConverterUnitTypeINCH)));

            thickestAtLabel.setText(ETUnitConverter.fractionForValue(selfUserData.getThickness()));

            curvatureLabel.setText(String.format("%.0f˚", Math.floor(selfUserData.getTipPoint().y)));

            String date = new SimpleDateFormat("dd MMM yyyy", Locale.US).format(selfUserData.getDate());
            dateLabel.setText(date);
            
            deviceLabel.setText(selfUserData.getDevice());
            
            usernameTextField.setVisibility(View.VISIBLE);
            
            
            int lengthBinIndex = binIndexForValue(selfUserData.getLength(), usersData.getlengthBins());
            if ( lengthBinIndex != -1 ) {
                lengthHisto.secondHighlightedBinIndex = lengthBinIndex;
            }
            
            int girthBinIndex = binIndexForValue(selfUserData.getGirth(), usersData.getgirthBins());
            if ( girthBinIndex != -1 ) {
                girthHisto.secondHighlightedBinIndex = girthBinIndex;
            }
            
            int thicknessBinIndex = binIndexForValue(selfUserData.getThickness(), usersData.getthicknessBins());
            if ( thicknessBinIndex != -1 ) {
                thicknessHisto.secondHighlightedBinIndex = thicknessBinIndex;
            }

        }
        
        watermarkText();
    }
    
    public String loadJSONFromAsset(String fileName) {
        String json = null;
        try {

            InputStream is = getActivity().getAssets().open(fileName);

            int size = is.available();

            byte[] buffer = new byte[size];

            is.read(buffer);

            is.close();

            json = new String(buffer, "UTF-8");

        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
        return json;

    }
    
    private List<HistogramBin> createBinsFromEdges(JSONArray edeges, JSONArray counts) {
    	List<HistogramBin> bins = new ArrayList<HistogramBin>();
    	for (int i = 0 ; i < counts.length() ; i ++) {
    		try {
    			HistogramBin bin = new HistogramBin((float) edeges.getDouble(i), (float) edeges.getDouble(i+1), (float) counts.getDouble(i));
    		
    			bins.add(bin);
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
    	}
    	return bins;
    }
    private int binIndexForValue(float value, JSONArray edges) {
        if (edges.length() == 0) 
        	return -1;
        
        float firstValue = 0.0f, lastValue = 0.0f;
        
        try {
        	firstValue = Float.parseFloat(edges.get(0).toString());
        	lastValue = Float.parseFloat(edges.get(edges.length()-1).toString());
        } catch (Exception e) {
        	e.printStackTrace();
        }
        
        if ( value < firstValue || value > lastValue ) {
            return -1;
        }
        
        
        int result = -1;
        for (int i = 0 ; i < edges.length() ; i ++) {
        	if (i == 0)
        		continue;
        	
        	float objValue = 0.0f;
        	try {
        		objValue = Float.parseFloat(edges.get(i).toString());
        	} catch (Exception e) {
        		e.printStackTrace();
        	}
        	
        	if (value <= objValue) {
        		result = i - 1;
        		break;
        	}
        		
        }
        
        return result;
    }
    
    private boolean shouldHideData() {
    	
        boolean female = !AppData.getInstance().isMale();
        boolean privacyLock = false; //[[NSUserDefaults standardUserDefaults] privacyLock];
        
        return (selfUserData == null) || female || privacyLock || AppData.getInstance().isHidePersonalData();
    }
    
    private void watermarkText() {
 	   String username = (shouldHideData() || usernameTextField.getText().toString().equalsIgnoreCase("username")) ? "" : usernameTextField.getText().toString() ;
	    
 	   if (!AppData.getInstance().isMale()) {
 		   username = "Example";
 	   }
 	   if (AppData.getInstance().isHidePersonalData()) {
 		   username = "";
 	   }
 	   
 	   setWatermarkText(username);
    }
    private void setWatermarkText(String name) {
 	  SpannableStringBuilder sb = new SpannableStringBuilder("ManHood" + name);
      Typeface exoExtraLight = Typeface.createFromAsset(getActivity().getAssets(), "fonts/exo-extra_light.ttf");
      Typeface exoExtraBold = Typeface.createFromAsset(getActivity().getAssets(), "fonts/exo-extra_bold.ttf");
      Typeface exoExtraRegular = Typeface.createFromAsset(getActivity().getAssets(), "fonts/exo-regular.ttf");

      TypefaceSpan exoExtraSpan = new CustomTypefaceSpan("", exoExtraLight);
      TypefaceSpan exoExtraBoldSpan = new CustomTypefaceSpan("", exoExtraBold);
      TypefaceSpan exoExtraRegularSpan = new CustomTypefaceSpan("", exoExtraRegular);

      sb.setSpan(exoExtraSpan, 0, 3, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
      sb.setSpan(exoExtraBoldSpan, 3, 7, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
      sb.setSpan(exoExtraRegularSpan, 7, 7+name.length(), Spannable.SPAN_INCLUSIVE_INCLUSIVE);

      watermarkView.setText(sb);

    }
    
    private Bitmap makeCertificate() {
    	
    	certificateView.setDrawingCacheEnabled(true);
    	certificateView.buildDrawingCache();
    	Bitmap bm = certificateView.getDrawingCache();
    	
    	int PHOTO_SIZE = 640;
    	
    	Bitmap resized = Bitmap.createScaledBitmap(bm, PHOTO_SIZE, PHOTO_SIZE, true);
    	
    	return resized;
    }
}
