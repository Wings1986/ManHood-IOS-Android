package com.VVTeam.ManHood.UIModel.Settings;

import android.widget.CompoundButton;

/**
 * Created by blase on 30.08.14.
 */
public class SwitchSettingsItem extends SettingsItem {

    protected boolean on;
    protected CompoundButton.OnCheckedChangeListener onCheckedChangeListener;

    public SwitchSettingsItem(String title, boolean isOn, CompoundButton.OnCheckedChangeListener onCheckedChangeListener) {
        this.title = title;
        this.on = isOn;
        this.onCheckedChangeListener = onCheckedChangeListener;
    }

    @Override
    public String getTitle() {
        return title;
    }

    public boolean isOn() {
        return on;
    }

    public void setOn(boolean on) {
        this.on = on;
    }

    public CompoundButton.OnCheckedChangeListener getOnCheckedChangeListener() {
        return onCheckedChangeListener;
    }
}
