package com.VVTeam.ManHood.Widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

/**
 * Created by blase on 04.09.14.
 */
public class SlideRelativeLayout extends RelativeLayout {
    public SlideRelativeLayout(Context context) {
        super(context);
    }

    public SlideRelativeLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public SlideRelativeLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public float getXFraction() {
        final int width = getWidth();
        return getX() / ((width == 0) ? width : 0.0001f);
    }

    public void setXFraction(float xFraction) {
        final int width = getWidth();
        setX((width > 0) ? (xFraction * width) : -9999);
    }

    public float getYFraction() {
        final int height = getHeight();
        return getY() / ((height == 0) ? height : 0.0001f);
    }

    public void setYFraction(float yFraction) {
        final int height = getHeight();
        setY((height > 0) ? (yFraction * height) : -9999);
    }
}
