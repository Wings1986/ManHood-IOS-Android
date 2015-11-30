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
import android.os.Handler;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;

@SuppressLint("DrawAllocation")
public class Histogram extends LinearLayout {
	
	public enum ORIENT {
		LEFT,
		RIGHT,
		BOTTOM
	}
	
	ORIENT orient = ORIENT.BOTTOM;
	
	public List<HistogramBin> bins;
	
	public int highlightedBinIndex = -1;
	public String highlightedBinText;
	public int highlightedBinColor = Color.GREEN;
	public float value = 0.0f;
	
	public int secondHighlightedBinIndex = -1;
	public String secondHighlightedBinText;
	public int secondHighlightedBinColor = Color.parseColor("#4eb4e3");
	
	public boolean selecting = false;
	
	HistogramCallBack listener = null;
	
	boolean bClickable = true;
	
	public Histogram(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public Histogram(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	public Histogram(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
		initView(context);
	}

	private void initView(Context context)
	{

	}
	
	public void setCallBackListener(HistogramCallBack listener){
        this.listener=listener;
    }
	
	public void setOrientation(ORIENT _orient) {
		orient = _orient;
	}
	
	public void setClickable(boolean bClickable) {
		this.bClickable = bClickable;
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		
		Paint paint = new Paint();
		
		if (bins != null) {
			
			int width = getWidth();
			int height = getHeight();
			
			float maxValue = 0.0f;
			for (int i = 0; i < bins.size() ; i ++) {
				maxValue = maxValue > bins.get(i).binCount ? maxValue : bins.get(i).binCount; 
			}
			
			
			float lineWidth, lineHeight, x, y, step;
			
			for (int i = 0; i < bins.size() ; i ++) {
				if (i == highlightedBinIndex) {
					paint.setColor(highlightedBinColor);
				}
				else if (i == secondHighlightedBinIndex) {
					paint.setColor(secondHighlightedBinColor);
				}
				else {
					paint.setColor(Color.WHITE);
				}
				
				if (orient == ORIENT.BOTTOM) {
					step = (float) width / bins.size();
					
					lineWidth = step * 2 / 3;
					lineHeight = height * bins.get(i).binCount / maxValue;
					x = i * step;
					y = height - lineHeight;
					
					canvas.drawRect(new RectF(x, y, x+lineWidth, y+lineHeight), paint);
				}
				else if (orient == ORIENT.RIGHT) {
					step = (float) height / bins.size();
					
					lineWidth = width * bins.get(i).binCount / maxValue;
					lineHeight = step * 2 / 3;

					x = width - lineWidth;
					y = height - i * step;
					
					canvas.drawRect(new RectF(x, y-lineHeight, x+lineWidth, y), paint);
				}
				else if (orient == ORIENT.LEFT) {
					step = (float) height / bins.size();
					
					lineWidth = width * bins.get(i).binCount / maxValue;
					lineHeight = step * 2 / 3;

					x = 0;
					y = height - i * step;
					
					canvas.drawRect(new RectF(x, y-lineHeight, x+lineWidth, y), paint);
				}
			}

//			 final float testTextSize = 40f;
//			 paint.setTextSize(testTextSize);
//
//			 int xPos = (canvas.getWidth() / 2);
//			 int yPos = (int) ((canvas.getHeight() / 2) - ((paint.descent() + paint.ascent()) / 2)) ;
//			 paint.setTextAlign(Align.CENTER);
//
//			if (highlightedBinIndex != -1 && highlightedBinText != null) {
//				paint.setColor(highlightedBinColor);
//				canvas.drawText(highlightedBinText, xPos, yPos, paint);
//			}
//			if (secondHighlightedBinIndex != -1 && secondHighlightedBinText != null) {
//				paint.setColor(secondHighlightedBinColor);
//				 canvas.drawText(secondHighlightedBinText, xPos, yPos, paint);
//			}

		}

		super.onDraw(canvas);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// TODO Auto-generated method stub
		if (!bClickable)
			return false;
		
		if (event.getAction() == MotionEvent.ACTION_DOWN
				|| event.getAction() == MotionEvent.ACTION_MOVE) {
			selecting = true;
			int x = (int)event.getX();
			int y = (int)event.getY();
			PointF touchPoint = new PointF(x, y);
			listener.setValueSelectionChangedBlock(this, HistogramSelectionState.HistogramSelectionStateSelected, edgeValueForPoint(touchPoint), null);
		}
		else if (event.getAction() == MotionEvent.ACTION_UP) {
			selecting = false;
		    if ( listener != null ) {
		    	
		    	final Handler handler = new Handler();
		    	final Histogram owner = this;
		    	handler.postDelayed(new Runnable() {
		    	    @Override
		    	    public void run() {
		    	        // Do something after 2s = 2000ms
		    	    	listener.setValueSelectionChangedBlock(owner, HistogramSelectionState.HistogramSelectionStateNotSelected, 0.0f, null);        
		    	    }
		    	}, 2000);
		    	
		    }
		}		    
		return true;
//		return super.onTouchEvent(event);
	}
	
	private float edgeValueForPoint(PointF point) {
	    float minValue = minLeftBinEdge();
	    float maxValue = maxRightBinEdge();
	    
	    if (orient == ORIENT.BOTTOM) {
	    	float width = getWidth();
	    	return (maxValue - minValue) / width * point.x + (width * minValue) / width ;
	    }
	    else if (orient == ORIENT.LEFT
	    		|| orient == ORIENT.RIGHT) {
	    	float height = getHeight();
	    	return (maxValue - minValue) / height * (height - point.y) + (height * minValue) / height ;
	    }
	    	    
	    return 0.0f;
	}
	private float minLeftBinEdge() {
		try {
			return bins.get(0).leftEdge;
		} catch (Exception e) {
			e.printStackTrace();
		}
	    return 0.0f;
	}

	private float maxRightBinEdge() {
		try {
			return bins.get(bins.size()-1).leftEdge;
		} catch (Exception e) {
			e.printStackTrace();
		}
	    return 0.0f;
	}
	
	public void setBins(List<HistogramBin> _bins) {
		bins = _bins;
	}
	public void setHighlightedBinIndex(int _highlightedBinIndex) {
	    if ( (highlightedBinIndex >= bins.size() && highlightedBinIndex != -1) || highlightedBinIndex == _highlightedBinIndex  ) {
	        return;
	    }
	    
	    int oldHighlightIndex = highlightedBinIndex;
	    highlightedBinIndex = _highlightedBinIndex;
	    
//	    if ( highlightedBinIndex != -1 ) {
//	        [_binLayers[highlightedBinIndex] setFillColor:_highlightedBinColor.CGColor];
//	    }
	    
	    invalidate();
	}
	public void setSecondHighlightedBinIndex(int _secondHighlightedBinIndex) {
		
	    if ( secondHighlightedBinIndex >= bins.size() && secondHighlightedBinIndex != -1  ) {
	        return;
	    }
	    
	    int oldHighlightIndex = secondHighlightedBinIndex;
	    secondHighlightedBinIndex = _secondHighlightedBinIndex;
	    
//	    if ( secondHighlightedBinIndex != -1 ) {
//	        [_binLayers[_secondHighlightedBinIndex] setFillColor:_secondHighlightedBinColor.CGColor];
//	    }

//	    [self layoutBinLayersWithAnimation:HistogramAnimationSelection finishBlock:nil];
	    invalidate();
	}
}
