package com.VVTeam.ManHood.Fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import com.VVTeam.ManHood.Activity.HelpActivity;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 08.09.14.
 */
public class HelpFragment extends Fragment {

    private RelativeLayout faqRelative;
    private RelativeLayout measurementTakingGuideRelative;

    public static HelpFragment newInstance() {
        HelpFragment fragment = new HelpFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initViews(view);
    }

    private void initViews(View view) {
        faqRelative = (RelativeLayout) view.findViewById(R.id.fragment_help_faq_relative);
        measurementTakingGuideRelative = (RelativeLayout) view.findViewById(R.id.fragment_help_measurements_taking_guide_relative);
        faqRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((HelpActivity) getActivity()).openGenericTextViewFragment(true, R.string.faq_text);
            }
        });
        measurementTakingGuideRelative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((HelpActivity) getActivity()).openGuideActivity();
            }
        });
    }

//    @Override
//    public void setUserVisibleHint(boolean isVisibleToUser) {
//        super.setUserVisibleHint(isVisibleToUser);
//        if (isVisibleToUser) {
//            // Do your Work
//        	getActivity().getActionBar().show();
//        } else {
//            // Do your Work
//        }
//    }
//    
//    @Override
//    public void onResume() {
//        super.onResume();
//        if (!getActivity().getActionBar().isShowing()) 
//        {
//            getActivity().getActionBar().show();
//        }
//    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_help, container, false);
    }

}
