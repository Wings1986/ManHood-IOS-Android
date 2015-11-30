package com.VVTeam.ManHood.UIModel;

import android.view.View;

/**
 * Created by blase on 29.08.14.
 */
public class GuideItemModel {

    private int imageResourceId;
    private String title;
    private String description;
    private View.OnClickListener onClickListener;

    public GuideItemModel(int imageResourceId, String title, String description) {
        this(imageResourceId, title, description, null);
    }

    public GuideItemModel(int imageResourceId, String title, String description, View.OnClickListener onClickListener) {
        this.imageResourceId = imageResourceId;
        this.title = title;
        this.description = description;
        this.onClickListener = onClickListener;
    }

    public void setOnClickListener(View.OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    public int getImageResourceId() {
        return imageResourceId;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public View.OnClickListener getOnClickListener() {
        return onClickListener;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        GuideItemModel that = (GuideItemModel) o;

        if (imageResourceId != that.imageResourceId) return false;
        if (!description.equals(that.description)) return false;
        if (!onClickListener.equals(that.onClickListener)) return false;
        if (!title.equals(that.title)) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = imageResourceId;
        result = 31 * result + title.hashCode();
        result = 31 * result + description.hashCode();
        result = 31 * result + onClickListener.hashCode();
        return result;
    }
}
