package com.VVTeam.ManHood.UIModel.Settings;

import com.VVTeam.ManHood.Enum.TextSettingType;

/**
 * Created by blase on 30.08.14.
 */
public class TextSettingsItem extends SettingsItem {

    protected TextSettingType textSettingType;

    public TextSettingsItem(String title, TextSettingType textSettingType) {
        this.title = title;
        this.textSettingType = textSettingType;
    }

    @Override
    public String getTitle() {
        return title;
    }

    public TextSettingType getTextSettingType() {
        return textSettingType;
    }

    public void setTextSettingType(TextSettingType textSettingType) {
        this.textSettingType = textSettingType;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        TextSettingsItem that = (TextSettingsItem) o;

        if (textSettingType != that.textSettingType) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return textSettingType != null ? textSettingType.hashCode() : 0;
    }
}
