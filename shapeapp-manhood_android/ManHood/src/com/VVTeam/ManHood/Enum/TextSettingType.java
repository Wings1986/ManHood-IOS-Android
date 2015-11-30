package com.VVTeam.ManHood.Enum;

/**
 * Created by blase on 30.08.14.
 */
public enum TextSettingType {

    IN("in"), CM("cm");

    private String title;

    private TextSettingType(String title) {
        this.title = title;
    }

    public static TextSettingType fromString(String title) {
        if (title.equalsIgnoreCase("in")) {
            return IN;
        } else if (title.equalsIgnoreCase("cm")) {
            return CM;
        }
        return IN;
    }

    @Override
    public String toString() {
        return title;
    }
}
