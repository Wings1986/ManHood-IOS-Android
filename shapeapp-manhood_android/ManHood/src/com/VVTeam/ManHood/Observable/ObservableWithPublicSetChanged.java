package com.VVTeam.ManHood.Observable;

import com.VVTeam.ManHood.Enum.ObservableType;

import java.util.Observable;

/**
 * Created by blase on 10.09.14.
 */
public class ObservableWithPublicSetChanged extends Observable {

    private ObservableType type;
    private String group = "";
    private String message = "";
    
    public ObservableWithPublicSetChanged(ObservableType type) {
        super();
        this.type = type;
    }

    public ObservableType getType() {
        return type;
    }
    public String getGroup() {
    	return group;
    }
    public void setGroup(String group) {
    	this.group = group;
    }
    public String getMessage() {
    	return message;
    }
    public void setMessage(String msg) {
    	this.message = msg;
    }
    
    
    @Override
    public void setChanged() {
        super.setChanged();
    }
}
