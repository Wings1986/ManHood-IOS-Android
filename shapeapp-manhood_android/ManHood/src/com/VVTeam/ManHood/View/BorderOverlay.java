package com.VVTeam.ManHood.View;


import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;

import com.VVTeam.ManHood.AppData;
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
import android.os.Handler;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;

@SuppressLint("DrawAllocation")
public class BorderOverlay extends LinearLayout {
	
	public float mX;
	public float mY;
	public float mWidth;
	public float mHeight;
	
	public BorderOverlay(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public BorderOverlay(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public BorderOverlay(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	private void initView(Context context)
	{
		setWillNotDraw(false);
	}
	
	
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		
		System.out.println("BorderOverlayView onDraw");
		
		Paint paint = new Paint();
		paint.setColor(Color.WHITE);
		
		paint.setStrokeWidth(3);
		paint.setStyle(Paint.Style.STROKE);  
		
//		width = canvas.getWidth() * 50 / 100;
//		height = (int) (AppData.getInstance().getDeviceHeight() * width / AppData.getInstance().getDeviceWidth());
		mHeight = canvas.getWidth() * 80 / 100;
		mWidth =  (AppData.getInstance().getDeviceWidth() * mHeight / AppData.getInstance().getDeviceHeight());
		
		mX = (canvas.getWidth() - mWidth)/2;
		mY = (canvas.getHeight() - mHeight)/2;
		
		System.out.println("x = " + mX + " y = " + mY + " width = " + mWidth + " height = " + mHeight);
		canvas.drawRect(new RectF(mX, mY, mX + mWidth, mY + mHeight), paint);
		
		super.onDraw(canvas);
	}
	
	
}
