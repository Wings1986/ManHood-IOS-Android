package com.VVTeam.ManHood.View;


import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.json.JSONException;

import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.DataModel.HistogramBin;
import com.VVTeam.ManHood.DataModel.PolarPlotData;
import com.VVTeam.ManHood.View.HistogramCallBack.HistogramSelectionState;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.MeasureSpec;
import android.widget.LinearLayout;

@SuppressLint("DrawAllocation")
public class PolarPlot extends LinearLayout {
	
	public List<PolarPlotData> data;	

	public PolarPlot(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public PolarPlot(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public PolarPlot(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
	 
	    int width = MeasureSpec.getSize(widthMeasureSpec);
	    int height = MeasureSpec.getSize(heightMeasureSpec);
	    int mScale = 1;
	 
	    if (width > (int)(mScale * height + 0.5)) {
	        width = (int)(mScale * height + 0.5);
	    } else {
	        height = (int)(width / mScale + 0.5);
	    }
	 
	    super.onMeasure(
	            MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
	            MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
	    );
	}
	
	private void initView(Context context)
	{

	}
	
	public void setData(List<PolarPlotData> _data) {
		
		data = _data;
		
		Collections.sort(data, new Comparator<PolarPlotData>() {

			@Override
			public int compare(PolarPlotData lhs, PolarPlotData rhs) {
				// TODO Auto-generated method stub
				return lhs.ID - rhs.ID;
			}
		});
		
		invalidate();
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		
		
		if (data != null) {
			
			for (int i = 0 ; i < data.size() ; i ++) {
				PolarPlotData item = data.get(i);
				
				PointF pos = posFromData(item);
				
				Bitmap bmp = item.image;
				
				canvas.drawBitmap(bmp, pos.x -bmp.getWidth()/2, pos.y-bmp.getHeight()/2, null);
				
			}
		}

		super.onDraw(canvas);
	}
	
	private PointF posFromData(PolarPlotData data) {
	    float ratio = 175.0f;
	    
	    PointF point = new PointF((float)(Math.sin(Math.toRadians(data.point.y)) * Math.cos(Math.toRadians(data.point.x)) * ratio + getWidth()/2),
	    		(float) (Math.sin(Math.toRadians(data.point.y)) * Math.sin(Math.toRadians(data.point.x)) * ratio + getWidth()/2));

	    return point;
	    
	}
}
