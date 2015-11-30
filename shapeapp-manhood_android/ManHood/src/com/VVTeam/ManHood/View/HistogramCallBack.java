package com.VVTeam.ManHood.View;

import com.VVTeam.ManHood.DataModel.HistogramBin;

public interface HistogramCallBack {

	enum HistogramSelectionState {
	    HistogramSelectionStateSelected,
	    HistogramSelectionStateNotSelected,
	    HistogramSelectionStateDelayedFinish,
	} ;
	
	
	public void setValueSelectionChangedBlock(Histogram histo, HistogramSelectionState selectionState, float value, HistogramBin bin);
	
}
