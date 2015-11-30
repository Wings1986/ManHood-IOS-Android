package com.VVTeam.ManHood.DataModel;

import android.graphics.PointF;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

public class UsersData {
	
	float MAXFLOAT = 0.05f; //0x1.fffffep+127f;
	
	ArrayList<Float> lengthBins;
	ArrayList<Float> lengthCounts;
	ArrayList<Float> girthBins;
	ArrayList<Float> girthCounts;
	ArrayList<Float> thicknessBins;
	ArrayList<Float> thicknessCounts;
	float averageLength;
	float averageGirth;
	float averageThickness;

	int usersCount;
	
    private JSONObject _usersData;
    private JSONObject _searchData;	


    
    public static JSONArray sort(JSONArray array, Comparator c){
        List<Object>    asList = new ArrayList(array.length());
        for (int i=0; i<array.length(); i++){
          asList.add(array.opt(i));
        }
        Collections.sort(asList, c);
        JSONArray  res = new JSONArray();
        for (Object o : asList){
          res.put(o);
        }
        return res;
    }
    
    
    public UsersData(JSONObject jsonObj) {
    	
    	_usersData = jsonObj;
    	
    	setupSearchData();
    }
    
    public void setupSearchData()
    {
    	_searchData = new JSONObject();
    	
    	try {
    		
			_searchData.put(JSONIndex.kJSONLengthKey, createSearchDataForUserDataIndex(JSONIndex.kJSONUserLengthIndex, JSONIndex.kJSONUserLengthPosIndex));
	    	_searchData.put(JSONIndex.kJSONGirthKey, createSearchDataForUserDataIndex(JSONIndex.kJSONUserGirthIndex, JSONIndex.kJSONUserGirthPosIndex));
	    	_searchData.put(JSONIndex.kJSONThicknessKey, createSearchDataForUserDataIndex(JSONIndex.kJSONUserThicknessIndex, JSONIndex.kJSONUserThicknessPosIndex));
		
    	} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

    }
    
    class SearchField {
    	float value = 0.0f;
    	String userId = "";
    	
    	public SearchField(float value, String userId) {
			// TODO Auto-generated constructor stub
    		this.value = value;
    		this.userId = userId;    				
		}
    }
    
    @SuppressWarnings("unchecked")
    public JSONArray createSearchDataForUserDataIndex(int index, int positionIndex) 
    {
    	try {
    		JSONArray searchData = new JSONArray();
//    		List<SearchField> searchList = new ArrayList<UsersData.SearchField>();
    		
    		
    		JSONObject objLookUp = _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey);
    		
    		Iterator<String> iterator = objLookUp.keys();
    		while(iterator.hasNext()){
    		    String userID = (String)iterator.next();
    		    
    		    JSONArray userData = objLookUp.getJSONArray(userID);

    		    JSONArray putObj = new JSONArray();
    		    
    		    putObj.put(JSONIndex.kSearchValueIndex, userData.get(index));
    		    putObj.put(JSONIndex.kSearchUserIDIndex, userID);
    		    
    		    searchData.put(putObj);
    		    
//    		    searchList.add(new SearchField(Float.parseFloat(userData.get(index).toString()), userID));
    		    
    		}
    	
//    		Collections.sort(searchList, new Comparator<SearchField>() {
//
//				@Override
//				public int compare(SearchField lhs, SearchField rhs) {
//					// TODO Auto-generated method stub
//					
//					return Float.compare(lhs.value, rhs.value);
//					
//				}
//			});
    		
//    		for (SearchField item : searchList) {
//    			 JSONArray putObj = new JSONArray();
//     		    
//     		    putObj.put(JSONIndex.kSearchValueIndex, item.value);
//     		    putObj.put(JSONIndex.kSearchUserIDIndex, item.userId);
//     		    
//     		    searchData.put(putObj);
//    		}
    		searchData = sort(searchData, new Comparator(){
    			   public int compare(Object a, Object b){
    			      JSONArray    ja = (JSONArray)a;
    			      JSONArray    jb = (JSONArray)b;
    			      
    			      try {
    			    	  float fa = Float.parseFloat(ja.get(JSONIndex.kSearchValueIndex).toString());
    			    	  float fb = Float.parseFloat(jb.get(JSONIndex.kSearchValueIndex).toString());
    			    	  return Float.compare(fa, fb);
    			      } catch (NumberFormatException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
    			      } catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
    			      }
    			      return 0;
    			   }
    			});
    			      
    		for (int i = 0 ; i < searchData.length(); i ++) {
    			String userId = searchData.getJSONArray(i).getString(JSONIndex.kSearchUserIDIndex);
    			
    			_usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userId).put(positionIndex, i);
    			
    		}
    		
    		return searchData;
    		
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}

    	return null;
    }
    
    public JSONArray searchUserDataForValue(float value, String key, boolean exact) {

    	JSONArray result = null;

    	try {
    	JSONArray allData = _searchData.getJSONArray(key);
        
        if ( exact ) {
            
        	JSONArray firstObj = allData.getJSONArray(0);
        	JSONArray lastObj = allData.getJSONArray(allData.length() - 1);
        	
            if ( value < firstObj.getDouble(JSONIndex.kSearchValueIndex) 
            		|| value > lastObj.getDouble(JSONIndex.kSearchValueIndex) ) {
                result = null;
            } else {
            	for (int i = 0 ; i < allData.length() ; i ++) {
            		JSONArray userData = allData.getJSONArray(i);
            		
            		if (userData.getDouble(JSONIndex.kSearchValueIndex) == value) {
            			result = userData;
            			break;
            		}
            	}
            }
            
        } else {
            float valueDiff = MAXFLOAT;
            
//            System.out.println("value = " + value);
//            System.out.println("alldata = " + allData.toString());
            
            for (int i = 0 ; i < allData.length() ; i ++) {
        		JSONArray userData = allData.getJSONArray(i);
        		float diff = (float) Math.abs((float)userData.getDouble(JSONIndex.kSearchValueIndex) - value);
        		if ( diff < valueDiff ) {
                    result = userData;
                    valueDiff = diff;
                }
        	}

        }
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
        return result;

    }

    public float lengthOfUserWithID(String userID) {
    	try {
    		return Float.parseFloat(_usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getString(JSONIndex.kJSONUserLengthIndex).toString());
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	catch (Exception e) {
			// TODO: handle exception
    		e.printStackTrace();
		}
    	return 0.0f;
    }

    public float girthOfUserWithID(String userID) {
    	try {
    		return Float.parseFloat(_usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getString(JSONIndex.kJSONUserGirthIndex).toString());
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	catch (Exception e) {
			// TODO: handle exception
    		e.printStackTrace();
		}
    	return 0.0f;
    }

    public float thicknessOfUserWithID(String userID) {
    	try {
    		return Float.parseFloat(_usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getString(JSONIndex.kJSONUserThicknessIndex).toString());
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	catch (Exception e) {
			// TODO: handle exception
    		e.printStackTrace();
		}
    	return 0.0f;
    }

    public PointF basePositionOfUserWithID(String userID) {
    	try {
    		return new PointF((float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleBaseIndex).getDouble(JSONIndex.kJSONUserCircleXIndex),
    				(float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleBaseIndex).getDouble(JSONIndex.kJSONUserCircleYIndex));
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return new PointF(0.0f, 0.0f);
//    	return null;
    }
    
    public PointF midPositionOfUserWithID(String userID) {
    	try {
    		return new PointF((float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleMidIndex).getDouble(JSONIndex.kJSONUserCircleXIndex),
    						  (float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleMidIndex).getDouble(JSONIndex.kJSONUserCircleYIndex));
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return new PointF(0.0f, 0.0f);
//    	return null;
    }

    public PointF upperPositionOfUserWithID(String userID) {
    	try {
    		return new PointF((float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleUpperIndex).getDouble(JSONIndex.kJSONUserCircleXIndex),
    						  (float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleUpperIndex).getDouble(JSONIndex.kJSONUserCircleYIndex));
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return new PointF(0.0f, 0.0f);
//    	return null;
    }
    
    public PointF tipPositionOfUserWithID(String userID) {
    	try {
    		return new PointF((float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleTipIndex).getDouble(JSONIndex.kJSONUserCircleXIndex),
    						  (float) _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getJSONArray(JSONIndex.kJSONUserCirclesIndex).getJSONArray(JSONIndex.kJSONUserCircleTipIndex).getDouble(JSONIndex.kJSONUserCircleYIndex));
    	}
    	catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return new PointF(0.0f, 0.0f);
//    	return null;
    }
    
    public String userIDWithNearestLength(float length) {
    	try {
    		return searchUserDataForValue(length, JSONIndex.kJSONLengthKey, false).getString(JSONIndex.kSearchUserIDIndex).toString();
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {
			// TODO: handle exception
		}
    	
    	return "";
    }
    public String userIDWithNearestGirth(float girth) {
    	try {
    		return searchUserDataForValue(girth, JSONIndex.kJSONGirthKey, false).getString(JSONIndex.kSearchUserIDIndex).toString();
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {
			// TODO: handle exception
		}
    	return "";
    }
    public String userIDWithNearestThickness(float thickness) {
    	try {
    		return searchUserDataForValue(thickness, JSONIndex.kJSONThicknessKey, false).getString(JSONIndex.kSearchUserIDIndex).toString();
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {
			// TODO: handle exception
		}
    	return "";
    }

    public int positionOfUserWithNearestLength(float length) {
    	try {
    		JSONArray arrayValue = searchUserDataForValue(length, JSONIndex.kJSONLengthKey, false);
        	if (arrayValue != null) {
        		JSONArray array = _searchData.getJSONArray(JSONIndex.kJSONLengthKey);
        		for (int i = 0; i < array.length() ; i ++) {
        			if (array.getJSONArray(i) == arrayValue) {
        				return i;
        			}
        		}
        	}
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return -1;
    }
    
    public int positionOfUserWithNearestGirth(float girth) {
    	try {
    		JSONArray arrayValue = searchUserDataForValue(girth, JSONIndex.kJSONGirthKey, false);
        	if (arrayValue != null) {
        		JSONArray array = _searchData.getJSONArray(JSONIndex.kJSONGirthKey);
        		for (int i = 0; i < array.length() ; i ++) {
        			if (array.getJSONArray(i) == arrayValue) {
        				return i;
        			}
        		}
        	}
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return -1;
    }
    
    public int positionOfUserWithNearestThickness(float thickness) {
    	try {
    		JSONArray arrayValue = searchUserDataForValue(thickness, JSONIndex.kJSONThicknessKey, false);
        	if (arrayValue != null) {
        		JSONArray array = _searchData.getJSONArray(JSONIndex.kJSONThicknessKey);
        		for (int i = 0; i < array.length() ; i ++) {
        			if (array.getJSONArray(i) == arrayValue) {
        				return i;
        			}
        		}
        	}
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	return -1;
    }

    public int userIDByLengthPosition(int position) {
        if (position >= usersCount) {
            return -1;
        } else {
        	try {
        		return _searchData.getJSONArray(JSONIndex.kJSONLengthKey).getJSONArray(position).getInt(JSONIndex.kSearchUserIDIndex);
        	} catch (JSONException e) {
        		e.printStackTrace();
        	}
        	return -1;
            
        }
    }
    
    public int userIDByGirthPosition(int position) {
        if (position >= usersCount) {
            return -1;
        } else {
        	try {
        		return _searchData.getJSONArray(JSONIndex.kJSONGirthKey).getJSONArray(position).getInt(JSONIndex.kSearchUserIDIndex);
        	} catch (JSONException e) {
        		e.printStackTrace();
        	}
        	return -1;
            
        }
    }
    
    public int userIDByThicknessPosition(int position) {
        if (position >= usersCount) {
            return -1;
        } else {
        	try {
        		return _searchData.getJSONArray(JSONIndex.kJSONThicknessKey).getJSONArray(position).getInt(JSONIndex.kSearchUserIDIndex);
        	} catch (JSONException e) {
        		e.printStackTrace();
        	}
        	return -1;
            
        }
    }
    
    public int positionByLengthOfUserWithID(String userID) {
    	try {
			
    		Object obj = _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).get(JSONIndex.kJSONUserLengthPosIndex);
    		
    		return Integer.parseInt(obj.toString());
    		
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return -1;
    }
    public int positionByGirthOfUserWithID(String userID) {
    	try {
    		
    		return _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getInt(JSONIndex.kJSONUserGirthPosIndex);
    		
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return -1;
    }
    public int positionByThicknessOfUserWithID(String userID) {
    	try {
    		
    		return _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).getJSONArray(userID).getInt(JSONIndex.kJSONUserThicknessPosIndex);
    		
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return -1;
    }
    
    @SuppressWarnings("unchecked")
    public int getUsersCount() {

    	int count = 0;

    	try {
        	
			Iterator<String> keys = _usersData.getJSONObject(JSONIndex.kJSONLookupUsersKey).keys();
        	
        	while (keys.hasNext()) {
        		String key = keys.next();
        		
        		count ++;        	    
        	}
        	
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {
    		e.printStackTrace();
		}
    	
    	return count;
    }
    public JSONArray getlengthBins() {
    	
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONLengthKey).getJSONArray(JSONIndex.kJSONBinKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public JSONArray getlengthCounts() {
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONLengthKey).getJSONArray(JSONIndex.kJSONCountKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public JSONArray getgirthBins() {
    	
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONGirthKey).getJSONArray(JSONIndex.kJSONBinKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public JSONArray getgirthCounts() {
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONGirthKey).getJSONArray(JSONIndex.kJSONCountKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public JSONArray getthicknessBins() {
    	
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONThicknessKey).getJSONArray(JSONIndex.kJSONBinKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public JSONArray getthicknessCounts() {
    	try {
    		return _usersData.getJSONObject(JSONIndex.kJSONThicknessKey).getJSONArray(JSONIndex.kJSONCountKey);
    	} catch (JSONException e) {
    		e.printStackTrace();
    	}
    	
    	return null;
    }
    public float getaverageLength() {
    	try {
    		JSONArray jsonObj = _usersData.getJSONArray(JSONIndex.kJSONAverageKey);
    		
    		return (float) jsonObj.getDouble(JSONIndex.kJSONUserLengthIndex);
    	    
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {

		}
    	
    	return 0.0f;
    }
    public float getaverageGirth() {
    	try {
    		JSONArray jsonObj = _usersData.getJSONArray(JSONIndex.kJSONAverageKey);
    		
    		return (float) jsonObj.getDouble(JSONIndex.kJSONUserGirthIndex);
    	    
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {

		}
    	
    	return 0.0f;
    }
    public float getaverageThickness() {
    	try {
    		JSONArray jsonObj = _usersData.getJSONArray(JSONIndex.kJSONAverageKey);
    		
    		return (float) jsonObj.getDouble(JSONIndex.kJSONUserThicknessIndex);
    	    
    	} catch (JSONException e) {
    		e.printStackTrace();
    	} catch (Exception e) {

		}
    	
    	return 0.0f;
    }
}
