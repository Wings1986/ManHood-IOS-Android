package com.VVTeam.ManHood.DataModel;

import android.graphics.Bitmap;
import android.graphics.PointF;

public class PolarPlotData {

	public int ID;
	public Bitmap image;
	public PointF point;
	
	
	public PolarPlotData(int _id, Bitmap _bmp, PointF _point) {
		// TODO Auto-generated constructor stub
		ID = _id;
		image = _bmp;
		point = _point;
	}
	
}
