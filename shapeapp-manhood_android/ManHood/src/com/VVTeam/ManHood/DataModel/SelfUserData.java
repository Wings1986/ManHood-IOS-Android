package com.VVTeam.ManHood.DataModel;

import android.graphics.PointF;
import com.VVTeam.ManHood.Helper.SimpleDateFormatHelper;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.Date;

/**
 * Created by blase on 10.09.14.
 */
public class SelfUserData {
    private Float length;
    private Float girth;
    private Float thickness;

    private PointF basePoint;
    private PointF midPoint;
    private PointF upperPoint;
    private PointF tipPoint;

    private String device;
    private Date date;


    public SelfUserData(Float length, Float girth, Float thickness, PointF basePoint, PointF midPoint,
                        PointF upperPoint, PointF tipPoint, String device, Date date) {
        this.length = length;
        this.girth = girth;
        this.thickness = thickness;
        this.basePoint = basePoint;
        this.midPoint = midPoint;
        this.upperPoint = upperPoint;
        this.tipPoint = tipPoint;
        this.device = device;
        this.date = date;
    }

    public SelfUserData(JSONArray jsonArray) {
        try {
            this.length = Float.valueOf(jsonArray.get(JSONIndex.kJSONUserLengthIndex).toString()) ;
            this.girth = Float.valueOf(jsonArray.get(JSONIndex.kJSONUserGirthIndex).toString());
            this.thickness = Float.valueOf(jsonArray.get(JSONIndex.kJSONUserThicknessIndex).toString());
            JSONArray userCircle = jsonArray.getJSONArray(JSONIndex.kJSONUserCirclesIndex);
            JSONArray baseCircle = userCircle.getJSONArray(JSONIndex.kJSONUserCircleBaseIndex);
            this.basePoint = new PointF((float) baseCircle.getDouble(JSONIndex.kJSONUserCircleXIndex), (float) baseCircle.getDouble(JSONIndex.kJSONUserCircleYIndex));
            JSONArray midCircle = userCircle.getJSONArray(JSONIndex.kJSONUserCircleMidIndex);
            this.midPoint = new PointF((float) midCircle.getDouble(JSONIndex.kJSONUserCircleXIndex), (float) midCircle.getDouble(JSONIndex.kJSONUserCircleYIndex));
            JSONArray upperCircle = userCircle.getJSONArray(JSONIndex.kJSONUserCircleUpperIndex);
            this.upperPoint = new PointF((float) upperCircle.getDouble(JSONIndex.kJSONUserCircleXIndex), (float) upperCircle.getDouble(JSONIndex.kJSONUserCircleYIndex));
            JSONArray tipCircle = userCircle.getJSONArray(JSONIndex.kJSONUserCircleTipIndex);
            this.tipPoint = new PointF((float) tipCircle.getDouble(JSONIndex.kJSONUserCircleXIndex), (float) tipCircle.getDouble(JSONIndex.kJSONUserCircleYIndex));
            this.date = new Date(SimpleDateFormatHelper.parseSelfUserMeasurementsDateTime(jsonArray.getString(JSONIndex.JSON_USER_DATE_INDEX)));
            this.device = jsonArray.getString(JSONIndex.JSON_USER_DEVICE_INDEX);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public Float getLength() {
        return length;
    }

    public Float getGirth() {
        return girth;
    }

    public Float getThickness() {
        return thickness;
    }

    public PointF getBasePoint() {
        return basePoint;
    }

    public PointF getMidPoint() {
        return midPoint;
    }

    public PointF getUpperPoint() {
        return upperPoint;
    }

    public PointF getTipPoint() {
        return tipPoint;
    }

    public String getDevice() {
        return device;
    }

    public Date getDate() {
        return date;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        SelfUserData that = (SelfUserData) o;

        if (basePoint != null ? !basePoint.equals(that.basePoint) : that.basePoint != null) return false;
        if (date != null ? !date.equals(that.date) : that.date != null) return false;
        if (device != null ? !device.equals(that.device) : that.device != null) return false;
        if (girth != null ? !girth.equals(that.girth) : that.girth != null) return false;
        if (length != null ? !length.equals(that.length) : that.length != null) return false;
        if (midPoint != null ? !midPoint.equals(that.midPoint) : that.midPoint != null) return false;
        if (thickness != null ? !thickness.equals(that.thickness) : that.thickness != null) return false;
        if (tipPoint != null ? !tipPoint.equals(that.tipPoint) : that.tipPoint != null) return false;
        if (upperPoint != null ? !upperPoint.equals(that.upperPoint) : that.upperPoint != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = length != null ? length.hashCode() : 0;
        result = 31 * result + (girth != null ? girth.hashCode() : 0);
        result = 31 * result + (thickness != null ? thickness.hashCode() : 0);
        result = 31 * result + (basePoint != null ? basePoint.hashCode() : 0);
        result = 31 * result + (midPoint != null ? midPoint.hashCode() : 0);
        result = 31 * result + (upperPoint != null ? upperPoint.hashCode() : 0);
        result = 31 * result + (tipPoint != null ? tipPoint.hashCode() : 0);
        result = 31 * result + (device != null ? device.hashCode() : 0);
        result = 31 * result + (date != null ? date.hashCode() : 0);
        return result;
    }
}
