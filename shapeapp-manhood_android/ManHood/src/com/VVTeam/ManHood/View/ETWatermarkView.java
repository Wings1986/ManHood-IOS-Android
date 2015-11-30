package com.VVTeam.ManHood.View;


import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;

import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.DataModel.HistogramBin;
import com.VVTeam.ManHood.View.HistogramCallBack.HistogramSelectionState;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;
import android.text.SpannableStringBuilder;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;

@SuppressLint("DrawAllocation")
public class ETWatermarkView extends LinearLayout {
	
	SpannableStringBuilder text;
	
	
	public ETWatermarkView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public ETWatermarkView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public ETWatermarkView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	private void initView(Context context)
	{
		 setWillNotDraw(false);
	}
	
	public void setText(SpannableStringBuilder text) {
		this.text = text;
		invalidate();
	}
	
	
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		
		Paint paint = new Paint();
		paint.setTextAlign(Align.CENTER);
		
		paint.setColor(Color.parseColor("#57666d")); 
		paint.setTextSize(80); 
		
		Rect bounds = new Rect();
		paint.getTextBounds("A", 0, "A".length(), bounds);
		
		int textSizeHeight = bounds.height();
		int textSizeWidth = bounds.width();
		
	    float marginWidth = 3.0f;
	    float marginHeight = 30.0f;
	    		
	    int lines = (int)(getHeight() / (textSizeHeight+marginHeight));
	    int columns = (int)(getWidth() / (textSizeWidth+marginWidth));
	    
	    for (int i = 0; i < lines; i++) {
	        
	        for (int j = 0; j < columns; j++) {
	        	int posx = (int) (j * (textSizeWidth + marginWidth) + (textSizeWidth + marginWidth)/2);
	        	int posy = (int) ((i+1) * (textSizeHeight + marginHeight));
	        	
	        	int count = i * columns + j;
	        	
	        	int s = count % this.text.length();
	        	
	        	String one = this.text.toString().substring(s, s + 1);
	        	
	        	canvas.drawText(one, posx, posy, paint);
	        	
	        }
	    }
	    
		super.onDraw(canvas);
	}
	
	
}