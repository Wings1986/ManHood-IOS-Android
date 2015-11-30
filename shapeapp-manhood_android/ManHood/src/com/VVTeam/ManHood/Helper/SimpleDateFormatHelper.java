package com.VVTeam.ManHood.Helper;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Viacheslav Vaniukov on 30/01/14.
 */
public class SimpleDateFormatHelper {

    private static SimpleDateFormat selfUserMeasurementsDateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm");
    private static SimpleDateFormat forPictureFileDateFormat = new SimpleDateFormat("dd_MM_yyyy_HH:mm:ss");

    public static long parseSelfUserMeasurementsDateTime(String selfUserMeasurementsDateString) {
        try {
            return selfUserMeasurementsDateFormat.parse(selfUserMeasurementsDateString).getTime();
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static String generateSelfMeasurementsTimeStringWithDate(Date date) {
        return selfUserMeasurementsDateFormat.format(date);
    }

    public static String generatePictureFileDateFromatStringWithCurrentDate() {
        return forPictureFileDateFormat.format(new Date());
    }
}
