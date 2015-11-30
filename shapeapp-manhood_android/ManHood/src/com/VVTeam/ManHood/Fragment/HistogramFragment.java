package com.VVTeam.ManHood.Fragment;

import android.animation.Animator;
import android.animation.AnimatorInflater;
import android.app.AlertDialog;
import android.app.Fragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.provider.MediaStore.Images;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.VVTeam.ManHood.Activity.CameraActivity;
import com.VVTeam.ManHood.Activity.CertificateActivity;
import com.VVTeam.ManHood.Activity.GoogleTracker;
import com.VVTeam.ManHood.Activity.GuideActivity;
import com.VVTeam.ManHood.Activity.MainActivity;
import com.VVTeam.ManHood.DataModel.ETUnitConverter;
import com.VVTeam.ManHood.DataModel.HistogramBin;
import com.VVTeam.ManHood.DataModel.PolarPlotData;
import com.VVTeam.ManHood.DataModel.SelfUserData;
import com.VVTeam.ManHood.DataModel.UsersData;
import com.VVTeam.ManHood.Enum.SliceRange;
import com.VVTeam.ManHood.Helper.DialogCallBack;
import com.VVTeam.ManHood.Helper.DialogHelper;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.Observable.ObservableWithPublicSetChanged;
import com.VVTeam.ManHood.View.Histogram;
import com.VVTeam.ManHood.View.PolarPlot;
import com.VVTeam.ManHood.View.Histogram.ORIENT;
import com.VVTeam.ManHood.View.HistogramCallBack.HistogramSelectionState;
import com.VVTeam.ManHood.View.HistogramCallBack;
import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.RequestManager;
import com.inapppurcharse.util.IabHelper;
import com.inapppurcharse.util.IabResult;
import com.inapppurcharse.util.Inventory;
import com.inapppurcharse.util.Purchase;

import java.io.File;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.Observable;
import java.util.Observer;

import org.json.JSONArray;
import org.json.JSONException;

/**
 * Created by blase on 27.08.14.
 */
public class HistogramFragment extends Fragment implements Observer {

	public static final String TAG = "HistogramFragment";
	 

	enum OfflineMode {
	    OfflineModeNo,
	    OfflineModeSoft,
	    OfflineModeFull,
	} 
	
    private RelativeLayout parentLayout;
    private RelativeLayout settingsRelative;
    private RelativeLayout markRelative;
    private RelativeLayout worldRelative;
    private RelativeLayout areaRelative;
    private RelativeLayout hoodRelative;
    private RelativeLayout contentRelative;
    
    private Histogram lengthHisto;
    private Histogram girthHisto;
    private Histogram thicknessHisto;
    private PolarPlot polarPlot;
    
    private TextView textBoxTitleLabel, textBoxSubtitleLabel, textBoxSubtitleValueLabel, lengthSelectedLabel, girthSelectedLabel, thicknessSelectedLabel, curvedSelectedLabel;
    private LinearLayout layoutSubTitle;
    private TextView lengthTOPLabel, thinkestAtTOPLabel, girthTOPLabel;
    
    private Button yourResultButton;
    private boolean yourButtonSelected = false;
    private boolean histogramSelected = false;
    
    private TextView lengthTopLB, lengthMiddleLB, lengthBottomLB, thicknessTopLB, thicknessMiddleLB, thicknessBottomLB, girthTopLB, girthMiddleLB, girthBottomLB; 
    // Data
    public String nearestUserID;
    public UsersData usersData;
    public SelfUserData selfUserData;
    
    OfflineMode offlineMode;
    SliceRange	selectedRange = SliceRange.SliceRangeAll;
    int oldSelectedRange;
    
    /* In-app billing */
    private static final String LICENSE_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhz0a2CcueSOok76pHqWT2FZp2zlPToKUKr7lRfoax24qr264mJbciGeVPgjzI2IMVw9BT66hzTdun77uDZBzbuNi0vv7/2Q0g1aywUXj0fboeONvvjwV3SrhiKTC9LfKk87QdVxB3U/8LFHTV8Ziqa0njy+cpXxCJRz/SJ9IEuFsgYwPtcz35Cg7T4Fh2toGD5vhlksobZYnPVAMWy05RsEDzYhf2KWiqHfQoK0Riv3DrDNLdGP2lHn4ekWf1SEQ0aVPeJEG7+SK47MdA0tTTaw3kZ0Ag3/Dg63PCWlLZ1eDGOL24NufYQM1rnrvdQ64AJgqddT3TOUPQdEbPQYTZwIDAQAB";
	public String PURCHASE_ITEM1 = "android.test.purchased"; //"com.vvteam.manhood.item3";//
	
    // The helper object
    IabHelper mHelper;

    static final int RC_REQUEST = 10001;

    
    public static HistogramFragment newInstance() {
        HistogramFragment fragment = new HistogramFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        AppData.getInstance().authObservable.addObserver(HistogramFragment.this);
        AppData.getInstance().histogramsObservable.addObserver(HistogramFragment.this);
        AppData.getInstance().selfUserDataObservable.addObserver(HistogramFragment.this);
    }

    
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initViews(view);
    }

    @Override
    public void onResume() {
    	// TODO Auto-generated method stub
        if (AppData.getInstance().isHidePersonalData()) {
        	yourResultButton.setVisibility(View.GONE);
        } else {
        	yourResultButton.setVisibility(View.VISIBLE);
        }
        if (!AppData.getInstance().isMale()) {
        	yourResultButton.setVisibility(View.GONE);
        }

    	super.onResume();
    }
    private void initViews(View view) {
        parentLayout = (RelativeLayout) view.findViewById(R.id.fragment_histogram_parent_relative_layout);
        /*BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = 2;
        parentLayout.setBackgroundDrawable(new BitmapDrawable(BitmapFactory.decodeResource(getResources(), R.drawable.histogram_bg, options)));*/
        settingsRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_settings_relative_layout);
        markRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_mark_relative_layout);
        worldRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_world_relative);
//        worldRelative.setSelected(true);
        worldRelative.setBackgroundResource(R.drawable.cell_p);
        areaRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_area_relative);
        hoodRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_hood_relative);
        yourResultButton = (Button) view.findViewById(R.id.fragment_histogram_your_result_button);
        
        contentRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_content_relative);
        
        
        RelativeLayout shareRelative = (RelativeLayout) view.findViewById(R.id.fragment_histogram_share_button_relative);
        shareRelative.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				GoogleTracker.StarSendEvent(getActivity(), "ui_action", "user_action", "histogram_share");
				
				Bitmap image = makeSnapshot();
				
				File pictureFile = getOutputMediaFile();
				try {
					 FileOutputStream fos = new FileOutputStream(pictureFile);
			            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
			            fos.close();
			            
			            
	            
				} catch (Exception e) {
					
				}
				
//				String pathofBmp = Images.Media.insertImage(getActivity().getContentResolver(), makeSnapshot(), "Man Hood App", null);
//			    Uri bmpUri = Uri.parse(pathofBmp);
				Uri bmpUri = Uri.fromFile(pictureFile);
			    final Intent emailIntent = new Intent(     android.content.Intent.ACTION_SEND);
			    emailIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			    emailIntent.putExtra(Intent.EXTRA_STREAM, bmpUri);
			    emailIntent.setType("image/png");
			    emailIntent.putExtra(Intent.EXTRA_SUBJECT, "Man Hood App");
			    getActivity().startActivity(emailIntent);
			    
			}
		});
        
        
        polarPlot = (PolarPlot) view.findViewById(R.id.polarPlot);
        
        thicknessHisto = (Histogram) view.findViewById(R.id.thicknessHisto);
        thicknessHisto.setOrientation(ORIENT.LEFT);
        thicknessHisto.setBackgroundColor(Color.TRANSPARENT);
        lengthHisto = (Histogram) view.findViewById(R.id.lengthHistogram); 
        lengthHisto.setOrientation(ORIENT.RIGHT);
        lengthHisto.setBackgroundColor(Color.TRANSPARENT);
        girthHisto = (Histogram) view.findViewById(R.id.girthHistogram);
        girthHisto.setOrientation(ORIENT.BOTTOM);
        girthHisto.setBackgroundColor(Color.TRANSPARENT);
        		
        lengthHisto.setCallBackListener( new HistogramCallBack() {
			
			@Override
			public void setValueSelectionChangedBlock(Histogram histo,
					HistogramSelectionState selectionState, float value,
					HistogramBin bin) {
				// TODO Auto-generated method stub
				if (selectionState == HistogramSelectionState.HistogramSelectionStateSelected) {
					histogramSelected = true;
					
					setNearestUserID(usersData.userIDWithNearestLength(value));
	                
					setSelection(true, girthHisto, usersData.girthOfUserWithID(nearestUserID));
					setSelection(true, thicknessHisto, usersData.thicknessOfUserWithID(nearestUserID));
//					setSelection(false, lengthHisto, 0.0f);
					setSelection(true, lengthHisto, value);
					
	                setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);					
				}
				else if (selectionState == HistogramSelectionState.HistogramSelectionStateNotSelected) {
					histogramSelected = false;
					
	                setNearestUserID(null);
	                setSelectionForAverage();
	                setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);
				}
				else if (selectionState == HistogramSelectionState.HistogramSelectionStateDelayedFinish) {
					
				}
				
			}
		});
        
        girthHisto.setCallBackListener( new HistogramCallBack() {
			
			@Override
			public void setValueSelectionChangedBlock(Histogram histo,
					HistogramSelectionState selectionState, float value,
					HistogramBin bin) {
				// TODO Auto-generated method stub
				if (selectionState == HistogramSelectionState.HistogramSelectionStateSelected) {
					histogramSelected = true;
					
					setNearestUserID(usersData.userIDWithNearestGirth(value));
					
					setSelection(true, lengthHisto, usersData.lengthOfUserWithID(nearestUserID));
					setSelection(true, thicknessHisto, usersData.thicknessOfUserWithID(nearestUserID));
//					setSelection(false, girthHisto, 0.0f);
					setSelection(true, girthHisto, value);
					
	                setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);					
				}
				else if (selectionState == HistogramSelectionState.HistogramSelectionStateNotSelected) {
					histogramSelected = false;
					
	                setNearestUserID(null);
	                
	                setSelectionForAverage();
	                setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);
				}
				else if (selectionState == HistogramSelectionState.HistogramSelectionStateDelayedFinish) {
					
				}
				
			}
		});

        thicknessHisto.setCallBackListener( new HistogramCallBack() {
	
        	@Override
        	public void setValueSelectionChangedBlock(Histogram histo,
        			HistogramSelectionState selectionState, float value,
        			HistogramBin bin) {
        		// TODO Auto-generated method stub
        		if (selectionState == HistogramSelectionState.HistogramSelectionStateSelected) {
        			histogramSelected = true;
        			
        			setNearestUserID(usersData.userIDWithNearestThickness(value));
        			
        			setSelection(true, girthHisto, usersData.girthOfUserWithID(nearestUserID));
        			setSelection(true, lengthHisto, usersData.lengthOfUserWithID(nearestUserID));
//        			setSelection(false, thicknessHisto, 0.0f);
        			setSelection(true, thicknessHisto, value);
        			
                    setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);					
        		}
        		else if (selectionState == HistogramSelectionState.HistogramSelectionStateNotSelected) {
        			histogramSelected = false;
        			
        			setNearestUserID(null);
                    setSelectionForAverage();
                    setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);
        		}
        		else if (selectionState == HistogramSelectionState.HistogramSelectionStateDelayedFinish) {
        			
        		}
        		
        	}
        });


        textBoxTitleLabel = (TextView) view.findViewById(R.id.txtBoxTitle);
        textBoxTitleLabel.setText("AVERAGE");
        
        layoutSubTitle = (LinearLayout) view.findViewById(R.id.layoutSubTitle);
        layoutSubTitle.setVisibility(View.INVISIBLE);
        textBoxSubtitleLabel = (TextView) view.findViewById(R.id.txtBoxSubTitleLabel);
        textBoxSubtitleValueLabel = (TextView) view.findViewById(R.id.txtBoxSubTitleValue);
        
        lengthSelectedLabel = (TextView) view.findViewById(R.id.txtlengthselected);
        lengthSelectedLabel.setText("50%");
        lengthTOPLabel = (TextView) view.findViewById(R.id.lengthTOPLabel);
        
        girthSelectedLabel = (TextView) view.findViewById(R.id.txtgirthselected);
        girthSelectedLabel.setText("50%");
        girthTOPLabel = (TextView) view.findViewById(R.id.girthTOPLabel);
        
        thicknessSelectedLabel = (TextView) view.findViewById(R.id.txtthicknessselected);
        thicknessSelectedLabel.setText("50%");
        thinkestAtTOPLabel = (TextView) view.findViewById(R.id.thinkestAtTOPLabel);
        
        curvedSelectedLabel = (TextView) view.findViewById(R.id.txtcurvedselected);
        curvedSelectedLabel.setText("0˚");
        
        girthTopLB = (TextView) view.findViewById(R.id.girthTop);
        girthMiddleLB = (TextView) view.findViewById(R.id.girthMiddle);
        girthBottomLB	= (TextView) view.findViewById(R.id.girthBottom);

        thicknessTopLB = (TextView) view.findViewById(R.id.thicknessTop);
        thicknessMiddleLB = (TextView) view.findViewById(R.id.thicknessMiddle);
        thicknessBottomLB	= (TextView) view.findViewById(R.id.thicknessBottom);

        lengthTopLB = (TextView) view.findViewById(R.id.lengthTop);
        lengthMiddleLB = (TextView) view.findViewById(R.id.lengthMiddle);
        lengthBottomLB	= (TextView) view.findViewById(R.id.lengthBottom);

        
        settingsRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((MainActivity) getActivity()).openSettingsActivity();
            }
        });
        markRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((MainActivity) getActivity()).openCertificateActivity();
            }
        });
        
        worldRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            	setSelectedRange(SliceRange.SliceRangeAll);
                updateRangeSwitch();
            }
        });
        areaRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            	setSelectedRange(SliceRange.SliceRange200);
                updateRangeSwitch();
            }
        });
        hoodRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            	setSelectedRange(SliceRange.SliceRange20);
                updateRangeSwitch();
            }
        });
        
     
        yourResultButton.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				
				if (event.getAction() == MotionEvent.ACTION_DOWN) {
					youTouchDown();
				}
				else if (event.getAction() == MotionEvent.ACTION_UP) {
					youTouchUp();
//					final Handler handler = new Handler();
//			    	handler.postDelayed(new Runnable() {
//			    	    @Override
//			    	    public void run() {
//			    	    	youTouchUp();			    
//			    	    }
//			    	}, 2000);
				}
				
				return true;
			}
		});
        
        
        
        
        
        RequestManager.getInstance().checkUser();
        
        
        /* in-app billing */
        String base64EncodedPublicKey = LICENSE_KEY;
    	
    	// Create the helper, passing it our context and the public key to verify signatures with
        Log.d(TAG, "Creating IAB helper.");
        mHelper = new IabHelper(getActivity(), base64EncodedPublicKey);

        // enable debug logging (for a production application, you should set this to false).
        mHelper.enableDebugLogging(true);

        // Start setup. This is asynchronous and the specified listener
        // will be called once setup completes.
        Log.d(TAG, "Starting setup.");
        mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            public void onIabSetupFinished(IabResult result) {
                Log.d(TAG, "Setup finished.");

                if (!result.isSuccess()) {
                    // Oh noes, there was a problem.
                	Log.d(TAG, "Problem setting up in-app billing: " + result);
                    return;
                }

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) return;

                // IAB is fully set up. Now, let's get an inventory of stuff we own.
                Log.d(TAG, "Setup successful. Querying inventory.");
                mHelper.queryInventoryAsync(mGotInventoryListener);
            }
        });
        
    }

 // Listener that's called when we finish querying the items and subscriptions we own
    IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
            Log.d(TAG, "Query inventory finished.");

            // Have we been disposed of in the meantime? If so, quit.
            if (mHelper == null) return;

            // Is it a failure?
            if (result.isFailure()) {
            	Log.d(TAG, "Failed to query inventory: " + result);
                return;
            }

            Log.d(TAG, "Query inventory was successful.");

            /*
             * Check for items we own. Notice that for each purchase, we check
             * the developer payload to see if it's correct! See
             * verifyDeveloperPayload().
             */

            // Check for gas delivery -- if we own gas, we should fill up the tank immediately
//            Purchase gasPurchase = inventory.getPurchase(PURCHASE_ITEM1);
//            if (gasPurchase != null && verifyDeveloperPayload(gasPurchase)) {
//                Log.d(TAG, "We have gas. Consuming it.");
//                mHelper.consumeAsync(inventory.getPurchase(PURCHASE_ITEM1), mConsumeFinishedListener);
//                return;
//            }

            Log.d(TAG, "Initial inventory query finished; enabling main UI.");
        }
    };    
    
    /** Verifies the developer payload of a purchase. */
    boolean verifyDeveloperPayload(Purchase p) {
        String payload = p.getDeveloperPayload();

        /*
         * TODO: verify that the developer payload of the purchase is correct. It will be
         * the same one that you sent when initiating the purchase.
         *
         * WARNING: Locally generating a random string when starting a purchase and
         * verifying it here might seem like a good approach, but this will fail in the
         * case where the user purchases an item on one device and then uses your app on
         * a different device, because on the other device you will not have access to the
         * random string you originally generated.
         *
         * So a good developer payload has these characteristics:
         *
         * 1. If two different users purchase an item, the payload is different between them,
         *    so that one user's purchase can't be replayed to another user.
         *
         * 2. The payload must be such that you can verify it even when the app wasn't the
         *    one who initiated the purchase flow (so that items purchased by the user on
         *    one device work on other devices owned by the user).
         *
         * Using your own server to store and verify developer payloads across app
         * installations is recommended.
         */

        return true;
    }
    
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
    	
    	if (mHelper == null) return;
    	
        // Pass on the activity result to the helper for handling
        if (!mHelper.handleActivityResult(requestCode, resultCode, data)) {
            // not handled, so handle it ourselves (here's where you'd
            // perform any handling of activity results not related to in-app
            // billing...
            super.onActivityResult(requestCode, resultCode, data);
        }
        else {
            Log.d(TAG, "onActivityResult handled by IABUtil.");
        }
    };
    
    
    
    
    // Callback for when a purchase is finished
    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
            Log.d(TAG, "Purchase finished: " + result + ", purchase: " + purchase);

            // if we were disposed of in the meantime, quit.
            if (mHelper == null) return;

            if (result.isFailure()) {
            	Log.d(TAG, "Error purchasing: " + result);
                return;
            }
            if (!verifyDeveloperPayload(purchase)) {
            	Log.d(TAG, "Error purchasing. Authenticity verification failed.");
                return;
            }

            Log.d(TAG, "Purchase successful.");
            
//            AppData.getInstance().setSubscriptionValid(purchase.getToken());
            RequestManager.getInstance().setSubscription(purchase.getToken());
            
//        	DialogHelper.getConfirmationDialog(getActivity(),
//        			"Success!",
//        			"You purchased this item",
//        			"OK",
//        			null,
//        			new DialogCallBack() {
//
//						@Override
//						public void onClick(int which) {
//							// TODO Auto-generated method stub
//							if (which == 0) { //ok
//							}
//
//						}
//					}).show();


//            if (purchase.getSku().equals(PURCHASE_ITEM1)) {
//                // bought 1/4 tank of gas. So consume it.
//                Log.d(TAG, "Purchase is gas. Starting gas consumption.");
//                mHelper.consumeAsync(purchase, mConsumeFinishedListener);
//            }

        }
    };
    
    
    
    
    
    @Override
    public Animator onCreateAnimator(int transit, boolean enter, int nextAnim) {
        final int animatorId = (enter) ? R.anim.translate_from_bottom_to_top : R.anim.translate_from_top_to_bottom;
        Animator animator = AnimatorInflater.loadAnimator(getActivity(), animatorId);
        return animator;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_histogram, container, false);
    }

    @Override
    public void update(Observable observable, Object data) {
        switch (((ObservableWithPublicSetChanged) observable).getType()) {
            case AUTH:
                if(data != null && ((Boolean)data))
                {
                    RequestManager.getInstance().checkUserData();
                }
                else
                {

                }
                break;
            case HISTO:
                if(data != null && ((Boolean)data))
                {
                	updateViewsData();
                }
                else
                {
                	if (((ObservableWithPublicSetChanged) observable).getGroup().equalsIgnoreCase("20")) {
                		selectedRange = SliceRange.fromInt(oldSelectedRange);
                        updateRangeSwitch();
                        
                    	DialogHelper.getConfirmationDialog(getActivity(),
                    			((ObservableWithPublicSetChanged) observable).getMessage(),
                    			"You need to purchase for it",
                    			"OK",
                    			null,
                    			new DialogCallBack() {

        							@Override
        							public void onClick(int which) {
        								// TODO Auto-generated method stub
        								if (which == 0) { //ok
        									 mHelper.launchPurchaseFlow(getActivity(), PURCHASE_ITEM1, RC_REQUEST,
        				                            mPurchaseFinishedListener, "");
        								}

        							}
        						}).show();
                	}
                }
            	
                break;
            case SELF_USER_DATA:
            	
            	if(data != null && ((Boolean)data))
                {
            		Log.d(TAG + "self user data", "" + AppData.getInstance().selfUserData.getLength());
                }
                else
                {

                }
            	
            	
            	
            	break;
        }
        showProgress(false);
    }

    private void showProgress(boolean show) {
        AppData.getInstance().handler.post(new Runnable() {
            @Override
            public void run() {

            }
        });
    }

    @Override
    public void onDestroy() {
    	
        AppData.getInstance().authObservable.deleteObserver(HistogramFragment.this);
        AppData.getInstance().histogramsObservable.deleteObserver(HistogramFragment.this);
        AppData.getInstance().selfUserDataObservable.deleteObserver(HistogramFragment.this);
        
        Log.d(TAG, "Destroying helper.");
        if (mHelper != null) {
            mHelper.dispose();
            mHelper = null;
        }

        
        super.onDestroy();
    }
    
    private UsersData usersDataForSliceRange(SliceRange range) {
    	UsersData _userData = null;
    	try {
    		String type = "all";
    		if (range == SliceRange.SliceRangeAll) {
    			type = "all";
    		} else if (range == SliceRange.SliceRange200) {
    			type = "200";
    		} else if (range == SliceRange.SliceRange20) {
    			type = "20";
    		}
    		
    		_userData = new UsersData(AppData.getInstance().userData.getJSONObject(type));
    		
    	} catch (JSONException e) {
    		e.printStackTrace();
    		_userData = null;
    	}
    	
    	return _userData;    			
    }
    
    private void updateViewsData() {
        
    	selfUserData = AppData.getInstance().selfUserData;
        
    	usersData = usersDataForSliceRange(selectedRange);
    	if (usersData == null) {
    		lengthHisto.setBins(null);
    		girthHisto.setBins(null);
    		thicknessHisto.setBins(null);
    		
        	setSelection(false, lengthHisto, -1);
        	setSelection(false, girthHisto, -1);
        	setSelection(false, thicknessHisto, -1);

        	 lengthSelectedLabel.setText("%");
             girthSelectedLabel.setText("%");
             thicknessSelectedLabel.setText("%");
             curvedSelectedLabel.setText("˚");
             
             lengthHisto.setClickable(false);
             girthHisto.setClickable(false);
             thicknessHisto.setClickable(false);
             
             lengthTopLB.setText("");
             lengthMiddleLB.setText("");
             lengthBottomLB.setText("");
             girthTopLB.setText("");
             girthMiddleLB.setText("");
             girthBottomLB.setText("");
             thicknessTopLB.setText("");
             thicknessMiddleLB.setText("");
             thicknessBottomLB.setText("");
             
    		return;
    	}
    	
    	lengthHisto.setBins(createBinsFromEdges(usersData.getlengthBins(), usersData.getlengthCounts()));
    	girthHisto.setBins(createBinsFromEdges(usersData.getgirthBins(), usersData.getgirthCounts()));
    	thicknessHisto.setBins(createBinsFromEdges(usersData.getthicknessBins(), usersData.getthicknessCounts()));
    	
    	lengthHisto.setClickable(true);
        girthHisto.setClickable(true);
        thicknessHisto.setClickable(true);
        
    	setSelectionForAverage();
    	
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
    
    private void setupPolarPlotWithCurrentUserID(String userID, UsersData _usersData, SelfUserData _selfUserData) {
    	
    	List<PolarPlotData> plotData = new ArrayList<PolarPlotData>();
    	
    	if (userID != null && userID.length() > 0) {
    		plotData.addAll(plotDataForUserWithID(userID, _usersData));
    	}
    	
    	if (yourButtonSelected) {
    		plotData.addAll(plotDataForSelfUserData(_selfUserData));
    	}
    	
    	polarPlot.setData(plotData);

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
    
    private List<PolarPlotData> plotDataForUserWithID(String userID, UsersData _usersData) {

    	Bitmap orgBmp = BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_b);

    	float width = orgBmp.getWidth() * 50.0f / 100.0f;
    	float height = width;
    	
    	PolarPlotData base = new PolarPlotData(0, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_b), (int)width, (int)height, true),
    			_usersData.basePositionOfUserWithID(userID));
    	
    	PolarPlotData mid = new PolarPlotData(2, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_m), (int)width, (int)height, true),
    			_usersData.midPositionOfUserWithID(userID));

    	PolarPlotData upper = new PolarPlotData(4, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_s), (int)width, (int)height, true),
    			_usersData.upperPositionOfUserWithID(userID));

    	PolarPlotData tip = new PolarPlotData(6, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_smaller), (int)width, (int)height, true),
    			_usersData.tipPositionOfUserWithID(userID));

    	List<PolarPlotData> list = new ArrayList<PolarPlotData>();
    	list.add(base);
    	list.add(mid);
    	list.add(upper);
    	list.add(tip);
    	
    	return list;
    }
    
    private List<PolarPlotData> plotDataForSelfUserData(SelfUserData _usersData) {
    	Bitmap orgBmp = BitmapFactory.decodeResource(getResources(), R.drawable.g_circle_b);
    	float width = orgBmp.getWidth() * 50.0f / 100.0f;
    	float height = width;
    	
    	PolarPlotData base = new PolarPlotData(1, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_b), (int)width, (int)height, true),
    			_usersData.getBasePoint());
    	
    	PolarPlotData mid = new PolarPlotData(3, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_m), (int)width, (int)height, true),
//    			BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_m),
    			_usersData.getMidPoint());

    	PolarPlotData upper = new PolarPlotData(5, 
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_s), (int)width, (int)height, true),
//    			BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_s),
    			_usersData.getUpperPoint());

    	PolarPlotData tip = new PolarPlotData(7, 
//    			BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_smaller),
    			Bitmap.createScaledBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.b_circle_smaller), (int)width, (int)height, true),
    			_usersData.getTipPoint());

    	List<PolarPlotData> list = new ArrayList<PolarPlotData>();
    	list.add(base);
    	list.add(mid);
    	list.add(upper);
    	list.add(tip);
    	
    	return list;
    }
    
    private void setSelectionForAverage() {
    	setSelection(true, lengthHisto, usersData.getaverageLength());
    	setSelection(true, girthHisto, usersData.getaverageGirth());
    	setSelection(true, thicknessHisto, usersData.getaverageThickness());
    }

    private void unselectAll() {
    	setSelection(false, lengthHisto, 0.0f);
    	setSelection(false, girthHisto, 0.0f);
    	setSelection(false, thicknessHisto, 0.0f);
    }
    
    
    private void setSelection(boolean selection, Histogram histogram, float value) {
        if ( selection ) {
            
            int binIndex = -1;
            
            for (int i = 0 ; i < histogram.bins.size() ; i ++) {
            	HistogramBin bin = histogram.bins.get(i);
            	if (value > bin.leftEdge && value < bin.rightEdge) {
            		binIndex = i;
            		break;
            	}
            }
            
            if ( binIndex != -1 ) {
//                ConverterUnitType unit = [ETUnitConverter typeFromString:[[NSUserDefaults standardUserDefaults] unitType]];
            	int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
            	
                histogram.highlightedBinIndex = binIndex;
                if ( histogram == thicknessHisto ) {
                    histogram.highlightedBinText = ETUnitConverter.fractionForValue(value);
                } else {
                    histogram.highlightedBinText = String.format("%.1f %s",
                    		ETUnitConverter.convertCMValue(value, unit),
                    		ETUnitConverter.nameForUnitType(unit)); 
                }
                histogram.value = value;
            }
        } else {
            histogram.highlightedBinIndex = -1;
        }
        
        histogram.invalidate();
        
        refreshDataText();
    }
    
    private void setSelection(boolean selection, UsersData usersData, SelfUserData selfUserData) {
    
        if ( selection ) {
            
        	int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
        	
        	int lengthBinIndex = binIndexForValue(selfUserData.getLength(), usersData.getlengthBins());
            if ( lengthBinIndex != -1 ) {
                lengthHisto.secondHighlightedBinIndex = lengthBinIndex;
                lengthHisto.secondHighlightedBinText = String.format("%.1f %s", 
                		ETUnitConverter.convertCMValue(selfUserData.getLength(), unit),
                		ETUnitConverter.nameForUnitType(unit));
            }
            
            int girthBinIndex = binIndexForValue(selfUserData.getGirth(), usersData.getgirthBins());
            if ( girthBinIndex != -1 ) {
                girthHisto.secondHighlightedBinIndex = girthBinIndex;
                girthHisto.secondHighlightedBinText = String.format("%.1f %s", 
                		ETUnitConverter.convertCMValue(selfUserData.getGirth(), unit),
                		ETUnitConverter.nameForUnitType(unit));
            }
            
            int thicknessBinIndex = binIndexForValue(selfUserData.getThickness(), usersData.getthicknessBins());
            if ( thicknessBinIndex != -1 ) {
                thicknessHisto.secondHighlightedBinIndex = thicknessBinIndex;
                thicknessHisto.secondHighlightedBinText = ETUnitConverter.fractionForValue(selfUserData.getThickness());
            }
        } else {
            lengthHisto.secondHighlightedBinIndex = -1;
            girthHisto.secondHighlightedBinIndex = -1;
            thicknessHisto.secondHighlightedBinIndex = -1;
        }
        
        refreshDataText();
        
    }
    
    private void refreshDataText() {

    	thicknessTopLB.setText("");
    	thicknessBottomLB.setText("");
    	lengthTopLB.setText("");
    	lengthBottomLB.setText("");
    	girthTopLB.setText("");
    	girthBottomLB.setText("");
    	
    	if (histogramSelected && yourButtonSelected) {
    		if (thicknessHisto.highlightedBinText != null) {
    			thicknessMiddleLB.setText(thicknessHisto.highlightedBinText);
    			thicknessMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    		if (girthHisto.highlightedBinText != null) {
    			girthMiddleLB.setText(girthHisto.highlightedBinText);
    			girthMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    		if (lengthHisto.highlightedBinText != null) {
    			lengthMiddleLB.setText(lengthHisto.highlightedBinText);
    			lengthMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    		
    		if ( selfUserData != null ) {
        		// length
        		int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
        		
        		String lengthStr = String.format("%.1f %s", 
                		ETUnitConverter.convertCMValue(selfUserData.getLength(), unit),
                		ETUnitConverter.nameForUnitType(unit));
        		
        		if (lengthHisto.value < selfUserData.getLength()) {
        			lengthTopLB.setText(lengthStr);
        			lengthBottomLB.setText("");
        		} else {
        			lengthTopLB.setText("");
        			lengthBottomLB.setText(lengthStr);
        		}
        		
        		String girthStr = String.format("%.1f %s", 
                		ETUnitConverter.convertCMValue(selfUserData.getGirth(), unit),
                		ETUnitConverter.nameForUnitType(unit));
        		
        		if (girthHisto.value < selfUserData.getGirth()) {
        			girthTopLB.setText(girthStr);
        			girthBottomLB.setText("");
        		} else {
        			girthTopLB.setText("");
        			girthBottomLB.setText(girthStr);
        		}
        		
        		String thicknessStr = ETUnitConverter.fractionForValue(selfUserData.getThickness());
        		if (thicknessHisto.value < selfUserData.getThickness()) {
        			thicknessTopLB.setText(thicknessStr);
        			thicknessBottomLB.setText("");
        		} else {
        			thicknessTopLB.setText("");
        			thicknessBottomLB.setText(thicknessStr);
        		}
        	}
    	}
    	else if (yourButtonSelected){
    		if (thicknessHisto.secondHighlightedBinText != null) {
    			thicknessMiddleLB.setText(thicknessHisto.secondHighlightedBinText);
    			thicknessMiddleLB.setTextColor(Color.parseColor("#4eb4e3"));
    		}
    		if (girthHisto.secondHighlightedBinText != null) {
    			girthMiddleLB.setText(girthHisto.secondHighlightedBinText);
    			girthMiddleLB.setTextColor(Color.parseColor("#4eb4e3"));
    		}
    		if (lengthHisto.secondHighlightedBinText != null) {
    			lengthMiddleLB.setText(lengthHisto.secondHighlightedBinText);
    			lengthMiddleLB.setTextColor(Color.parseColor("#4eb4e3"));
    		}
    	}
    	else {
    		if (thicknessHisto.highlightedBinText != null) {
    			thicknessMiddleLB.setText(thicknessHisto.highlightedBinText);
    			thicknessMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    		if (girthHisto.highlightedBinText != null) {
    			girthMiddleLB.setText(girthHisto.highlightedBinText);
    			girthMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    		if (lengthHisto.highlightedBinText != null) {
    			lengthMiddleLB.setText(lengthHisto.highlightedBinText);
    			lengthMiddleLB.setTextColor(Color.parseColor("#00ff00"));
    		}
    	}
    	
    }
    
    private void showUserParametersWithAnimation(boolean animate) {
    	if ( nearestUserID == null || yourButtonSelected ) {
            layoutSubTitle.setVisibility(View.INVISIBLE);
        } else {
       	 	layoutSubTitle.setVisibility(View.VISIBLE);
            
       	 	int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
       	 
            float value = 0.0f;
            if ( lengthHisto.selecting ) {
           	 	textBoxSubtitleLabel.setText("LENGTH");
                
                value = usersData.lengthOfUserWithID(nearestUserID);
                textBoxSubtitleValueLabel.setText(String.format("%.1f %s", 
               		 ETUnitConverter.convertCMValue(value, unit), ETUnitConverter.nameForUnitType(unit)));
            } else if ( girthHisto.selecting ) {
                textBoxSubtitleLabel.setText("THICKNESS");
                value = usersData.girthOfUserWithID(nearestUserID);
                textBoxSubtitleValueLabel.setText(String.format("%.1f %s", ETUnitConverter.convertCMValue(value, unit), ETUnitConverter.nameForUnitType(unit))); 
            } else if ( thicknessHisto.selecting ) {
           	 	textBoxSubtitleLabel.setText("THICKEST AT");
                value = usersData.thicknessOfUserWithID(nearestUserID);
                textBoxSubtitleValueLabel.setText(ETUnitConverter.fractionForValue(value));
            }
        }
        
        String lengthStr = "";
        String girthStr = "";
        String thinknessStr = "";
        String curvedStr = "";
        String title = "";
        
        if ( offlineMode == OfflineMode.OfflineModeFull ) { // NO connection state
            lengthTOPLabel.setVisibility(View.INVISIBLE);
            thinkestAtTOPLabel.setVisibility(View.INVISIBLE);
            girthTOPLabel.setVisibility(View.INVISIBLE);
            
//            
//            BOOL hasLocation = [ETGeolocation sharedInstance].currentLocation != nil;
//            title = hasLocation ? @"NO CONNECTION" : @"NO LOCATION" ;
//            lengthStr = @"...";
//            girthStr = @"...";
//            thinknessStr = @"...";
//            curvedStr = @"...";
            
        } else if ( yourButtonSelected) {
            if (nearestUserID == null) { // Histogram not selected
                title = "YOUR POSITION";
                
                lengthTOPLabel.setVisibility(View.VISIBLE);
                thinkestAtTOPLabel.setVisibility(View.VISIBLE);
                girthTOPLabel.setVisibility(View.VISIBLE);
                
                String nearestLengthUserID = usersData.userIDWithNearestLength(selfUserData.getLength());
                String nearestGirthUserID = usersData.userIDWithNearestGirth(selfUserData.getGirth());
                String nearestThinknessUserID = usersData.userIDWithNearestThickness(selfUserData.getThickness()); 
                
                float lengthPosition = (float) usersData.positionByLengthOfUserWithID(nearestLengthUserID) / usersData.getUsersCount() * 100;
                float girthPosition = (float) usersData.positionByGirthOfUserWithID(nearestGirthUserID) / usersData.getUsersCount() * 100;
                float thinknessPosition = (float) usersData.positionByThicknessOfUserWithID(nearestThinknessUserID) / usersData.getUsersCount() * 100;
                float curved = selfUserData.getTipPoint().y;
                
                lengthStr = String.format("%d%%", 100 - Math.round(lengthPosition));
                girthStr = String.format("%d%%", 100 - Math.round(girthPosition));
                thinknessStr = String.format("%d%%", 100 - Math.round(thinknessPosition));
                curvedStr = String.format("%.0f˚", Math.floor(curved));
                
            } else { 
                title = "DIFFERENCE"; // before @"YOU & THIS GUY"
                
                lengthTOPLabel.setVisibility(View.INVISIBLE);
                thinkestAtTOPLabel.setVisibility(View.INVISIBLE);
                girthTOPLabel.setVisibility(View.INVISIBLE);
                
                String nearestLengthUserID = usersData.userIDWithNearestLength(selfUserData.getLength());
                String nearestGirthUserID = usersData.userIDWithNearestGirth(selfUserData.getGirth());
                String nearestThinknessUserID = usersData.userIDWithNearestThickness(selfUserData.getThickness());
                
                float lengthDifference = Math.abs((float)usersData.lengthOfUserWithID(nearestLengthUserID) - (float)usersData.lengthOfUserWithID(nearestUserID));
                float girthDifference = Math.abs((float)usersData.girthOfUserWithID(nearestGirthUserID) - (float)usersData.girthOfUserWithID(nearestUserID));
                float thinknessDifference = Math.abs((float)usersData.thicknessOfUserWithID(nearestThinknessUserID) - (float)usersData.thicknessOfUserWithID(nearestUserID));
                float curvedDifference = Math.abs(selfUserData.getTipPoint().y - usersData.tipPositionOfUserWithID(nearestUserID).y);
                
                int unit = ETUnitConverter.typeFromString(AppData.getInstance().getUnitsType().toString());
                
                lengthStr = String.format("%.1f %s", ETUnitConverter.convertCMValue(lengthDifference, unit), ETUnitConverter.nameForUnitType(unit));
                girthStr = String.format("%.1f %s", ETUnitConverter.convertCMValue(girthDifference, unit), ETUnitConverter.nameForUnitType(unit));
                thinknessStr = ETUnitConverter.fractionForValue(thinknessDifference);
                curvedStr = String.format("%.0f˚", Math.floor(curvedDifference));
                
            }
        } else {
            
       	 	lengthTOPLabel.setVisibility(View.VISIBLE);
            thinkestAtTOPLabel.setVisibility(View.VISIBLE);
            girthTOPLabel.setVisibility(View.VISIBLE);
            
            if (nearestUserID == null) { // Histogram not selected
                title = "AVERAGE";
                float lengthPosition = 50.0f;
                float girthPosition = 50.0f;
                float thinknessPosition = 50.0f;
                float curved = 0.0f;
                
                lengthStr = String.format("%d%%", 100 - Math.round(lengthPosition));
                girthStr = String.format("%d%%", 100 - Math.round(girthPosition));
                thinknessStr = String.format("%d%%", 100 - Math.round(thinknessPosition));
                curvedStr = String.format("%.0f˚", Math.floor(curved));
            } else {
                title = "DATA POINT"; //before @"THIS GUY";
                float lengthPosition = (float)usersData.positionByLengthOfUserWithID(nearestUserID) / usersData.getUsersCount() * 100;
                float girthPosition = (float)usersData.positionByGirthOfUserWithID(nearestUserID) / usersData.getUsersCount() * 100;
                float thinknessPosition = (float)usersData.positionByThicknessOfUserWithID(nearestUserID) / usersData.getUsersCount() * 100;
                float curved = usersData.tipPositionOfUserWithID(nearestUserID).y;

                lengthStr = String.format("%d%%", 100 - (long)Math.round(lengthPosition));
                girthStr = String.format("%d%%", 100 - (long)Math.round(girthPosition));
                thinknessStr = String.format("%d%%", 100 - (long)Math.round(thinknessPosition));
                curvedStr = String.format("%.0f˚", Math.floor(curved));
            }
        }
        
        textBoxTitleLabel.setText(title);
        lengthSelectedLabel.setText(lengthStr);
        girthSelectedLabel.setText(girthStr);
        thicknessSelectedLabel.setText(thinknessStr);
        curvedSelectedLabel.setText(curvedStr);                             
    }
        
        
    private void setNearestUserID(String _nearestUserID) {
        nearestUserID = _nearestUserID;
        
        showUserParametersWithAnimation(true);
    }
    
    private void setSelectedRange(SliceRange _selectedRange) {
        
        
        offlineMode = OfflineMode.OfflineModeNo;
        
        boolean male = AppData.getInstance().isMale();
        boolean female = !male;

        boolean shouldIgnore = selectedRange == _selectedRange;
        oldSelectedRange = selectedRange.getValue();
        selectedRange = _selectedRange;
        
        if ( shouldIgnore ) {
            
        } else if ( male ) {
            if ( selfUserData == null ) {
                if ( selectedRange == SliceRange.SliceRange200 || selectedRange == SliceRange.SliceRange20 ) {
                    showClosestNeedMesurementMessage();
                    shouldIgnore = true;
                }
            } else {
                if ( selectedRange == SliceRange.SliceRange20 ) {
                	shouldIgnore = false;
//                	showDisableMessage();
//                	shouldIgnore = true;
//                    if ( !AppData.getInstance().isSubscriptionValid() ) {
//                        shouldIgnore = true;
//                        
//                        String payload = "";
//                        mHelper.launchPurchaseFlow(getActivity(), PURCHASE_ITEM1, RC_REQUEST,
//                                mPurchaseFinishedListener, payload);
//                    }
                }
            }
        } else {
            if ( selectedRange == SliceRange.SliceRange20 ) {
            	shouldIgnore = false;
//            	showDisableMessage();
//            	shouldIgnore = true;
//                if ( !AppData.getInstance().isSubscriptionValid() ) {
//                    shouldIgnore = true;
//                    
//                    String payload = "";
//                    mHelper.launchPurchaseFlow(getActivity(), PURCHASE_ITEM1, RC_REQUEST,
//                            mPurchaseFinishedListener, payload);
//                }
            }
        }
        
        if ( shouldIgnore ) {
            selectedRange = SliceRange.fromInt(oldSelectedRange);
             updateRangeSwitch();
            return;
        }
        
        updateRangeSwitch();
        
        
        if ( (selectedRange == SliceRange.SliceRange20 || selectedRange == SliceRange.SliceRange200)
        		&& AppData.getInstance().getCurrentLocation() == null ) {
            offlineMode = OfflineMode.OfflineModeFull;
            updateViewsData();
        } else {
        	RequestManager.getInstance().executeDownloadHistogramDataFromGroup(selectedRange);

        }

        
    }
    
    private void updateRangeSwitch() {
//    	worldRelative.setSelected(false);
//    	areaRelative.setSelected(false);
//        hoodRelative.setSelected(false);
        worldRelative.setBackgroundColor(Color.TRANSPARENT);
        areaRelative.setBackgroundColor(Color.TRANSPARENT);
        hoodRelative.setBackgroundColor(Color.TRANSPARENT);
        
        if (selectedRange == SliceRange.SliceRangeAll) {
//        	worldRelative.setSelected(true);
        	worldRelative.setBackgroundResource(R.drawable.cell_p);
        }
        else if (selectedRange == SliceRange.SliceRange200) {
//        	areaRelative.setSelected(true);
        	areaRelative.setBackgroundResource(R.drawable.cell_p);
        }
        else if (selectedRange == SliceRange.SliceRange20) {
//        	hoodRelative.setSelected(true);
        	hoodRelative.setBackgroundResource(R.drawable.cell_p);
        }
    }
    
    private void showClosestNeedMesurementMessage() {
    	
    		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getActivity());
 
			// set title
			alertDialogBuilder.setTitle("Measurement needed to see the Area around you");
 
			// set dialog message
			alertDialogBuilder
				.setMessage("To see the close by, you need to get yourself measured")
				.setCancelable(false)
				.setPositiveButton("How-To",new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog,int id) {
						
						((MainActivity)getActivity()).openGuideActivity();
						
					}
				  })
				.setNegativeButton("Cancel",new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog,int id) {
						// if this button is clicked, just close
						// the dialog box and do nothing
						dialog.cancel();
					}
				});
 
				// create alert dialog
				AlertDialog alertDialog = alertDialogBuilder.create();
 
				// show it
				alertDialog.show();
    }
    
    private void showMesurementMessage() {
    	AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getActivity());
    	 
		// set title
		alertDialogBuilder.setTitle("Mapping the world, Hood by Hood");

		// set dialog message
		alertDialogBuilder
			.setMessage("Start with yourself first")
			.setCancelable(false)
			.setPositiveButton("How-To",new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog,int id) {

					((MainActivity)getActivity()).openGuideActivity();
					
				}
			  })
			.setNegativeButton("Cancel",new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog,int id) {
					// if this button is clicked, just close
					// the dialog box and do nothing
					dialog.cancel();
				}
			});

			// create alert dialog
			AlertDialog alertDialog = alertDialogBuilder.create();

			// show it
			alertDialog.show();
			
        
    }
    
    private void showDisableMessage() {
    	
		AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getActivity());

		// set title
		alertDialogBuilder.setTitle("Join the Inner Circle!");

		// set dialog message
		alertDialogBuilder
			.setMessage("This feature is not available in the Beta version.")
			.setCancelable(false)
			.setPositiveButton("Cancel",new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog,int id) {
					dialog.cancel();
				}
			  });
			

			// create alert dialog
			AlertDialog alertDialog = alertDialogBuilder.create();

			// show it
			alertDialog.show();
}
    
    
    private void youTouchDown() {
        
        if ( selfUserData == null ) {
            showMesurementMessage();
            return;
        }
        
        yourButtonSelected = true;
        
        setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);
        setSelection(yourButtonSelected, usersData, selfUserData);
        showUserParametersWithAnimation(true);
        
        if ( nearestUserID == null) {
        	setSelection(false, lengthHisto, 0.0f);
        	setSelection(false, girthHisto, 0.0f);
        	setSelection(false, thicknessHisto, 0.0f);
        }
    }

    private void youTouchUp() {
    	yourButtonSelected = false;
        
    	setupPolarPlotWithCurrentUserID(nearestUserID, usersData, selfUserData);
        setSelection(yourButtonSelected, usersData, selfUserData);
        showUserParametersWithAnimation(true);
        
        if ( nearestUserID == null) {
        	setSelectionForAverage();
        }

    }

    private Bitmap makeSnapshot() {
    	
    	contentRelative.setDrawingCacheEnabled(true);
    	contentRelative.buildDrawingCache();
    	Bitmap bm = contentRelative.getDrawingCache();

        int width = bm.getWidth();
        int height = bm.getHeight();
        
        Bitmap background = BitmapFactory.decodeResource(getResources(), R.drawable.histogram_bg);
        Bitmap logo = BitmapFactory.decodeResource(getResources(), R.drawable.manhoodlogo);

        
    	Bitmap cs = null; 


        cs = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888); 

        Canvas comboImage = new Canvas(cs); 

        
        Rect src = new Rect(0,0,background.getWidth()-1, background.getHeight()-1);
        Rect dest = new Rect(0,0,width-1, height-1);
        comboImage.drawBitmap(background, src, dest, null);
        comboImage.drawBitmap(bm, 0f, 0f, null); 
        comboImage.drawBitmap(logo, 7.0f, height - logo.getHeight() - 4.0f, null); 

     	return cs;
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
        String mImageName="HI_"+ timeStamp +".jpg";
        mediaFile = new File(mediaStorageDir.getPath() + File.separator + mImageName);  
        return mediaFile;
    } 
}

