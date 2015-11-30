package com.VVTeam.ManHood;

import android.content.Context;
import android.location.Location;
import android.text.TextUtils;
import android.util.Log;

import com.VVTeam.ManHood.DataModel.SelfUserData;
import com.VVTeam.ManHood.DataModel.UsersData;
import com.VVTeam.ManHood.Enum.SliceRange;
import com.VVTeam.ManHood.Helper.DialogCallBack;
import com.VVTeam.ManHood.Helper.DialogHelper;
import com.VVTeam.ManHood.Observable.ObservableWithPublicSetChanged;
import com.VVTeam.ManHood.Widget.SlideRelativeLayout;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BaseJsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import org.apache.http.Header;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicHeader;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

/**
 * Created by blase on 08.09.14.
 */
public class RequestManager {

    public static final String TAG = "RequestManager";
    public static final String BASIC_AUTH_VALUE = "Basic " + " bW9iaWxlY2xpZW50OlQ8N10vZCMzM1wpKzc7LG1iSlhNLVdd";

    private Context context;
    private AsyncHttpClient asyncHttpClient = new AsyncHttpClient();
    //private final List<RequestHandle> requestHandles = new LinkedList<RequestHandle>();

    public void checkUserData() {
        if (AppData.getInstance().isMale() && AppData.getInstance().selfUserData == null) {
            executeDownloadUserMeasurements();
        } else {
            executeDownloadHistogramDataFromGroup(SliceRange.SliceRangeAll);
        }
    }

    public void getDeviceDimension() {
    	/*
    	RequestParams params = new RequestParams();
    	params.put(AppData.KEY_DEVICE_MODEL, AppData.getInstance().getDeviceMode());
    	params.put(AppData.KEY_DEVICE_MANU, AppData.getInstance().getDeviceManufacturer());
        
    	asyncHttpClient.get(context, context.getString(R.string.server_link) + "/api/modeldimensions/", params, new BaseJsonHttpResponseHandler<JSONObject>() {

			@Override
			public void onSuccess(int statusCode, Header[] headers,
					String rawJsonResponse, JSONObject response) {
				// TODO Auto-generated method stub
				Log.d(TAG + "getDeviceDimension", statusCode + rawJsonResponse);
			}

			@Override
			public void onFailure(int statusCode, Header[] headers,
					Throwable throwable, String rawJsonData,
					JSONObject errorResponse) {
				// TODO Auto-generated method stub
				Log.d(TAG + "getDeviceDimension", "error ==== " + rawJsonData);
			}
			
			@Override
			protected JSONObject parseResponse(String rawJsonData,
					boolean isFailure) throws Throwable {
				// TODO Auto-generated method stub
				return null;
			}
		});
*/
    	try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/modeldimensions/",
                    null,
                    new StringEntity(getJsonStringForGetDeviceDimension(), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            
                            Log.d(TAG + "getDeviceDimension", statusCode + rawJsonResponse);
                            
                            try {
                            	JSONObject info = response.getJSONObject("info");
                            	JSONObject size = info.getJSONObject("size");
                            	
								AppData.getInstance().setDeviceWidthHeight((float) size.optDouble("width"),
										(float) size.optDouble("height"));
							} catch (JSONException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d(TAG + "getDeviceDimension", statusCode + rawJsonData);
                      
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            //TODO this should be checked
                            return new JSONObject(rawJsonData);
                        }
                       
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    	
    }
    
    
    public void executeDownloadUserMeasurements() {
        try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/getmeasurements/",
                    new Header[]{new BasicHeader(AppData.X_SESSION_ID, AppData.getInstance().getAuthToken())},
                    new StringEntity(getJsonStringForGetUserMeasurementsRequest(), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            String authToken = "";
                            for (Header header : headers) {
                                if (header.getName().equalsIgnoreCase(AppData.HTTP_X_SESSION_ID)) {
                                    authToken = header.getValue();
                                }
                            }
                            String errorMsg = response.optString(AppData.KEY_ERROR_MSG, "");
                            String errorCode = response.optString(AppData.KEY_ERROR_CODE, "");
                            if (!TextUtils.isEmpty(errorCode)) {
                                DialogHelper.getErrorDialog(context, errorMsg, null).show();
                                AppData.getInstance().selfUserDataObservable.setChanged();
                                AppData.getInstance().selfUserDataObservable.notifyObservers(false);
                            } else {
                                if (!TextUtils.isEmpty(authToken)) {
                                    AppData.getInstance().saveAuthToken(authToken);
                                }
                                
                                try {
                                	JSONObject objYou = new JSONObject(rawJsonResponse);
                                	JSONArray arry = objYou.getJSONArray("measurements");
                                	AppData.getInstance().saveSelfUserData(getSelfUserDataFromJson(arry.toString()));
                                } catch (Exception e) {}
                                
                                AppData.getInstance().selfUserDataObservable.setChanged();
                                AppData.getInstance().selfUserDataObservable.notifyObservers(true);
                            }
                            Log.d(TAG + "executeDownloadUserMeasurements", "success " + statusCode + rawJsonResponse);
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d(TAG + "executeDownloadUserMeasurements", "fail " + statusCode + rawJsonData);
                            
//                            try {
//                            	JSONObject objYou = new JSONObject(loadJSONFromAsset("json/YOU_json.txt"));
//                            	JSONArray arry = objYou.getJSONArray("YOU");
//                            	AppData.getInstance().saveSelfUserData(getSelfUserDataFromJson(arry.toString()));
//                            } catch (Exception e) {
//                            	e.printStackTrace();
//                            }

                            AppData.getInstance().selfUserDataObservable.setChanged();
                            AppData.getInstance().selfUserDataObservable.notifyObservers(false);

                            try {
                                String errorMsg = errorResponse.optString(AppData.KEY_ERROR_MSG, "");
                                String errorCode = errorResponse.optString(AppData.KEY_ERROR_CODE, "");
                                
                                if (errorCode.equals("11001")) {
                                	DialogHelper.getErrorDialog(context, errorMsg + "\n" + "error=" + errorCode + " job_id=" + AppData.getInstance().getJobId()  , null).show();
                                }
                                
                            } catch (Exception e) {e.printStackTrace();}
                      
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            //TODO this should be checked
                            return new JSONObject(rawJsonData);
                        }

                        @Override
                        public void onFinish() {
                            executeDownloadHistogramDataFromGroup(SliceRange.SliceRangeAll);
                            super.onFinish();
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            AppData.getInstance().selfUserDataObservable.setChanged();
            AppData.getInstance().selfUserDataObservable.notifyObservers(false);
        }
    }

    public void executeAnalysePhotos(String refShot, String frontShot, String sideShot, float width, float height) {
        try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/analysephotos/",
                    new Header[]{new BasicHeader(AppData.X_SESSION_ID, AppData.getInstance().getAuthToken())},
                    new StringEntity(getJsonStringForAnalysePhotosRequest(refShot, frontShot, sideShot, width, height), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            String authToken = "";
                            for (Header header : headers) {
                                if (header.getName().equalsIgnoreCase(AppData.HTTP_X_SESSION_ID)) {
                                    authToken = header.getValue();
                                }
                            }
                            
                            String errorMsg = response.optString(AppData.KEY_ERROR_MSG, "");
                            String errorCode = response.optString(AppData.KEY_ERROR_CODE, "");
                            if (!TextUtils.isEmpty(errorCode)) {
                                AppData.getInstance().analyPhotoObservable.setChanged();
                                AppData.getInstance().analyPhotoObservable.notifyObservers(response);
                                
                            } else {
                                if (!TextUtils.isEmpty(authToken)) {
                                    AppData.getInstance().saveAuthToken(authToken);
                                }
                                
                                AppData.getInstance().setJobId(getJobIDFromJson(rawJsonResponse));
//                                AppData.getInstance().saveSelfUserData(getSelfUserDataFromJson(rawJsonResponse));
                                
                                
                                AppData.getInstance().analyPhotoObservable.setChanged();
                                AppData.getInstance().analyPhotoObservable.notifyObservers(response);
                            }
                            Log.d(TAG + "executeAnalysePhotos Success", statusCode + rawJsonResponse);
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d(TAG + "executeAnalysePhotos Fail", statusCode + rawJsonData);
                            
                            if (errorResponse == null) {
                            	DialogHelper.getErrorDialog(context, "Error", null).show();
                            	
                            	AppData.getInstance().analyPhotoObservable.setChanged();
                                AppData.getInstance().analyPhotoObservable.notifyObservers(errorResponse);
                                
                                return;
                            }
                            
                            String errorMsg = errorResponse.optString(AppData.KEY_ERROR_MSG, "");
                            String errorCode = errorResponse.optString(AppData.KEY_ERROR_CODE, "");
                            if (!TextUtils.isEmpty(errorCode)) {
                            	DialogHelper.getErrorDialog(context, errorMsg, null).show();
                            	
                                AppData.getInstance().analyPhotoObservable.setChanged();
                                AppData.getInstance().analyPhotoObservable.notifyObservers(errorResponse);
                            } else {
                                DialogHelper.getErrorDialog(context, context.getString(R.string.room_for_improvements), null).show();
                                
                                AppData.getInstance().analyPhotoObservable.setChanged();
                                AppData.getInstance().analyPhotoObservable.notifyObservers(errorResponse);
                            }
                            
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            //TODO this should be checked
                            return new JSONObject(rawJsonData);
                        }

                        @Override
                        public void onFinish() {
//                            executeDownloadAllHistogramData();
                            super.onFinish();
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private String getJobIDFromJson(String responseString) {
        String jobID = "";
        try {
        	JSONObject jsonObj = new JSONObject(responseString);
            
        	jobID = jsonObj.getString("job_id");
            
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jobID;
    }

    
    private SelfUserData getSelfUserDataFromJson(String responseString) {
        SelfUserData selfUserData = null;
        try {
            JSONArray jsonArray = new JSONArray(responseString);
            selfUserData = new SelfUserData(jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return selfUserData;
    }
    private JSONObject getUsersDataFromJson(String responseString) {
        JSONObject usersData = null;
        try {
        	
        	usersData = new JSONObject(responseString);
        	
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return usersData;
    }
    
    String group = "all";
    public void executeDownloadHistogramDataFromGroup(SliceRange range) {
        try {
        	group = "all";
        	if (range == SliceRange.SliceRange200) {
        		group = "200";
        	} else if (range == SliceRange.SliceRange20) {
        		group = "20";
        	}
        	
        	asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/gethistogram" + group + "/",
                    new Header[]{new BasicHeader(AppData.X_SESSION_ID, AppData.getInstance().getAuthToken())},
                    new StringEntity(getJsonStringForDownloadHistogramRequest(range), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            String authToken = "";
                            for (Header header : headers) {
                                if (header.getName().equalsIgnoreCase(AppData.HTTP_X_SESSION_ID)) {
                                    authToken = header.getValue();
                                }
                            }
                            if (!TextUtils.isEmpty(authToken)) {
                                AppData.getInstance().saveAuthToken(authToken);
                            }
                            Log.d(TAG + "executeDownloadAllHistogramData", "success" + statusCode + rawJsonResponse);
//                            AppData.getInstance().writeToFile(rawJsonResponse);
                            
                            AppData.getInstance().saveUsersData(getUsersDataFromJson(rawJsonResponse));
                            
                            AppData.getInstance().histogramsObservable.setChanged();
                            AppData.getInstance().histogramsObservable.notifyObservers(true);
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                        	
                        	Log.d(TAG + "executeDownloadAllHistogramData", "fail" + statusCode + rawJsonData);
                        	
                        	if (group.equalsIgnoreCase("20") && errorResponse != null) {
                        		try {
                        			int error_code = errorResponse.getInt("error_code");
                        			if (error_code == 40001) {
                        				AppData.getInstance().histogramsObservable.setGroup(group);
                        				AppData.getInstance().histogramsObservable.setMessage(errorResponse.getString("error_msg"));
                        			}
                        		} catch (Exception e) {
                        			
                        		}
                        	}
                        	else {
                        		DialogHelper.getErrorDialog(context, context.getString(R.string.something_wasnt_right), null).show();	
                        	}
                            
                            AppData.getInstance().histogramsObservable.setChanged();
                            AppData.getInstance().histogramsObservable.notifyObservers(false);
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            return new JSONObject(rawJsonData);
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            AppData.getInstance().histogramsObservable.setChanged();
            AppData.getInstance().histogramsObservable.notifyObservers(false);
        }
    }

    public void setSubscription(String token) {
        try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/verifyiapreceipt/",
                    new Header[]{new BasicHeader("Authorization", BASIC_AUTH_VALUE)},
                    new StringEntity(getJsonStringForSubscription(token), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                        	Log.d(TAG + "executeCreateUserRequest", statusCode + rawJsonResponse);
                        	
                        	DialogHelper.getConfirmationDialog(context,
                        			"Success",
                        			"",
                        			"OK",
                        			null,
                        			null).show();
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d(TAG + "executeCreateUserRequest", statusCode + rawJsonData);
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            return new JSONObject(rawJsonData);
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }
    
    private String getJsonStringForSubscription(String token) {
        JSONObject jsonObject = new JSONObject();
        try {
        	jsonObject.put(AppData.KEY_UUID, AppData.getInstance().getUUID());
        	jsonObject.put(AppData.KEY_RECEIPT, token);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }
    
    
    public void checkUser() {
        if (!TextUtils.isEmpty(AppData.getInstance().getUUID())) {
            executeAuthorizeUserRequest();
        } else {
            executeCreateUserRequest();
        }
    }

    public void executeCreateUserRequest() {
        try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/createuser/",
                    new Header[]{new BasicHeader("Authorization", BASIC_AUTH_VALUE)},
                    new StringEntity(getJsonStringForCreateUserRequest(), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            String authToken = "";
                            for (Header header : headers) {
                                if (header.getName().equalsIgnoreCase(AppData.HTTP_X_SESSION_ID)) {
                                    authToken = header.getValue();
                                }
                            }
                            AppData.getInstance().saveAuthData(response.optString("user_uuid", ""), authToken);
                            Log.d(TAG + "executeCreateUserRequest", statusCode + rawJsonResponse);
                            AppData.getInstance().authObservable.setChanged();
                            AppData.getInstance().authObservable.notifyObservers(true);
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d(TAG + "executeCreateUserRequest", statusCode + rawJsonData);
                            AppData.getInstance().authObservable.setChanged();
                            AppData.getInstance().authObservable.notifyObservers(false);
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            return new JSONObject(rawJsonData);
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            AppData.getInstance().authObservable.setChanged();
            AppData.getInstance().authObservable.notifyObservers(false);
        }
    }

    public void executeAuthorizeUserRequest() {
        try {
            asyncHttpClient.post(context, context.getString(R.string.server_link) + "/api/authorizeuser/",
                    new Header[]{new BasicHeader("Authorization", BASIC_AUTH_VALUE)},
                    new StringEntity(getJsonStringForAuthorizeUserRequest(), "utf-8"),
                    "application/json", new BaseJsonHttpResponseHandler<JSONObject>() {
                        @Override
                        public void onSuccess(int statusCode, Header[] headers, String rawJsonResponse, JSONObject response) {
                            String authToken = "";
                            for (Header header : headers) {
                                if (header.getName().equalsIgnoreCase(AppData.HTTP_X_SESSION_ID)) {
                                    authToken = header.getValue();
                                }
                            }
                            JSONObject userSettings = response.optJSONObject(AppData.KEY_USER_SETTINGS);
                            boolean isMale = userSettings.optBoolean("isMale");//.equalsIgnoreCase("true");
                            AppData.getInstance().saveAuthData(response.optString(AppData.KEY_UUID, ""), authToken, isMale);
                            Log.d("executeAuthorizeUserRequest", statusCode + rawJsonResponse);
                            //Toast.makeText(context, statusCode + rawJsonResponse, Toast.LENGTH_SHORT).show();
                            
                            AppData.getInstance().authObservable.setChanged();
                            AppData.getInstance().authObservable.notifyObservers(true);
                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable throwable, String rawJsonData, JSONObject errorResponse) {
                            Log.d("executeAuthorizeUserRequest", statusCode + rawJsonData);
                            AppData.getInstance().handler.post(new Runnable() {
                                @Override
                                public void run() {
                                    DialogHelper.getErrorDialog(context, context.getString(R.string.something_wasnt_right), null).show();
                                }
                            });
                            //Toast.makeText(context, statusCode + rawJsonData, Toast.LENGTH_SHORT).show();
                        }

                        @Override
                        protected JSONObject parseResponse(String rawJsonData, boolean isFailure) throws Throwable {
                            return new JSONObject(rawJsonData);
                        }
                    });
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private String getJsonStringForCreateUserRequest() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_IS_MALE, AppData.getInstance().isMale());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    private String getJsonStringForAuthorizeUserRequest() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_UUID, AppData.getInstance().getUUID());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    private String getJsonStringForGetDeviceDimension() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_DEVICE_MODEL, AppData.getInstance().getDeviceMode());
            jsonObject.put(AppData.KEY_DEVICE_MANU, AppData.getInstance().getDeviceManufacturer());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        System.out.println(jsonObject.toString());
        
        return jsonObject.toString();
    }
    
    private String getJsonStringForGetUserMeasurementsRequest() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_UUID, AppData.getInstance().getUUID());
            
            String jobId = AppData.getInstance().getJobId();
            if (jobId != null) {
                jsonObject.put(AppData.KEY_JOB_ID, jobId);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        System.out.println(jsonObject.toString());
        
        return jsonObject.toString();
    }

    private String getJsonStringForAnalysePhotosRequest(String refShot, String frontShot, String sideShot, float width, float height) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_UUID, AppData.getInstance().getUUID());
            jsonObject.put(AppData.KEY_MODEL, AppData.getInstance().getDeviceModelName());
            Location currentLocation = AppData.getInstance().getCurrentLocation();
            JSONArray locationArray = new JSONArray();
            locationArray.put(currentLocation.getLatitude());
            locationArray.put(currentLocation.getLongitude());
            jsonObject.put(AppData.KEY_LOCATION, locationArray);
            
            System.out.println(jsonObject);
            
            jsonObject.put(AppData.KEY_IMAGE_REF, refShot);
            jsonObject.put(AppData.KEY_IMAGE_FRONT, frontShot);
            jsonObject.put(AppData.KEY_IMAGE_SIDE, sideShot);
            
            jsonObject.put(AppData.KEY_WIDTH, width);
            jsonObject.put(AppData.KEY_HEIGHT, height);
            
            System.out.println(jsonObject);
            
        } catch (JSONException e) {
            e.printStackTrace();
        }
        
        
        
        return jsonObject.toString();
    }

    private String getJsonStringForDownloadHistogramRequest(SliceRange range) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(AppData.KEY_UUID, AppData.getInstance().getUUID());
            
        	if (range == SliceRange.SliceRange200 || range == SliceRange.SliceRange20) {
                Location currentLocation = AppData.getInstance().getCurrentLocation();
                JSONArray locationArray = new JSONArray();
                locationArray.put(currentLocation.getLatitude());
                locationArray.put(currentLocation.getLongitude());
                jsonObject.put(AppData.KEY_LOCATION, locationArray);
        	} 
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    private static RequestManager instance;

    public void init(Context context) {
        this.context = context;
    }

    public static RequestManager getInstance() {
        if (instance == null) {
            instance = new RequestManager();
        }
        return instance;
    }

    private RequestManager() {
    }
    
    
    public String loadJSONFromAsset(String fileName) {
        String json = null;
        try {

            InputStream is = context.getAssets().open(fileName);

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
}
