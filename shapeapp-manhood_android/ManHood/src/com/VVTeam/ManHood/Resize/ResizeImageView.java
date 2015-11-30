package com.VVTeam.ManHood.Resize;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View.MeasureSpec;
import android.widget.ImageView;

public class ResizeImageView extends ImageView {

	public ResizeImageView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public ResizeImageView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	public ResizeImageView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
	 
	    int width = MeasureSpec.getSize(widthMeasureSpec);
	    int height = MeasureSpec.getSize(heightMeasureSpec);

	    height = width;
	    
//	    float mScale = width / 47.0f;
//	    height = (int) (height / mScale);
	    
	    super.onMeasure(
	            MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
	            MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
	    );
	}
}
