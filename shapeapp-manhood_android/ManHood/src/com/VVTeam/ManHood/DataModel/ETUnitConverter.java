package com.VVTeam.ManHood.DataModel;

import android.graphics.Bitmap;
import android.graphics.PointF;

public class ETUnitConverter {

	public static final int ConverterUnitTypeCM = 0;
	public static final int ConverterUnitTypeINCH = 1;
	
	
	public final static String unitMetric   	 = "cm";
	public final static String unitImperial   	 = "in";
	
	public static float convertCMValue(float value, int unitType) {
	    switch (unitType) {
	        case ConverterUnitTypeCM: return value;
	        case ConverterUnitTypeINCH: return value / 2.54f;
	        default: return value;
	    }
	}

	public static String nameForUnitType(int unitType) {
	    switch (unitType) {
	        case ConverterUnitTypeCM: return "CM";
	        case ConverterUnitTypeINCH: return "IN";
	        default: return "";
	    }
	}

	public static int typeFromString(String string) {
	    if (string.equalsIgnoreCase(unitImperial)) {
	        return ConverterUnitTypeINCH;
	    } else if (string.equalsIgnoreCase(unitMetric)) {
	        return ConverterUnitTypeCM;
	    } else {
	        return ConverterUnitTypeCM;
	    }
	}
	
	public static String fractionForValue(float input) {
	    
		int fractions = (int)Math.round((input - (int)input) / (1.0 / 16.0));
	     
	    if(fractions == 0 || fractions == 16) {
	        
	        return  String.format("%d", Math.round(input));
	        
	    } else if(fractions == 2) {
	        
	        return "1/8";
	        
	    } else if(fractions == 4) {
	        
	        return "1/4";
	        
	    } else if(fractions == 5) {
	        
	        return "1/3";
	        
	    } else if(fractions == 6) {
	        
	        return "3/8";
	        
	    } else if(fractions == 8) {
	        
	        return "1/2";
	        
	    } else if(fractions == 10) {
	        
	        return "5/8";
	        
	    } else if(fractions == 11) {
	        
	        return "2/3";
	        
	    } else if(fractions == 12) {
	        
	        return "3/4";
	        
	    } else if(fractions == 14) {
	        
	        return "7/8";
	        
	    } else {
	        
	        return String.format("%d/16", (int)fractions);
	        
	    }
	}
}
