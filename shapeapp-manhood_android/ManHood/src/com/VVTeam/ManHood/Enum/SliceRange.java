package com.VVTeam.ManHood.Enum;


/**
 * Created by Denis on 29.01.15.
 */
public enum SliceRange {
    
	SliceRangeAll(0),
	SliceRange200(1),
	SliceRange20(2);
	
	private int _value;

	SliceRange(int Value) {
        this._value = Value;
    }

    public int getValue() {
        return _value;
    }

    public static SliceRange fromInt(int i) {
        for (SliceRange b : SliceRange.values()) {
            if (b.getValue() == i) { return b; }
        }
        return null;
    }
}
