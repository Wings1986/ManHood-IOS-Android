package com.VVTeam.ManHood.Fragment;

import android.animation.Animator;
import android.animation.AnimatorInflater;
import android.app.Fragment;
import android.app.FragmentManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.Constants;
import com.VVTeam.ManHood.R;

/**
 * Created by blase on 04.09.14.
 */
public class GenericTextViewFragment extends Fragment {

    private TextView titleTextView;
    private RelativeLayout doneRelativeLayout;
    private TextView genericTextView;
    private int textResourceId;
    private boolean isShowOriActionBar = false;
    
    public static GenericTextViewFragment newInstance(int textResourceId) {
        GenericTextViewFragment fragment = new GenericTextViewFragment();
        Bundle args = new Bundle();
        args.putInt("text_resource_id", textResourceId);
        fragment.setArguments(args);
        return fragment;
    }
    public static GenericTextViewFragment newInstance(int textResourceId, boolean isShowedActionbar) {
        GenericTextViewFragment fragment = new GenericTextViewFragment();
        Bundle args = new Bundle();
        args.putInt("text_resource_id", textResourceId);
        args.putBoolean("isShowOriActionBar", isShowedActionbar);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initViews(view);
    }

    private void initViews(View view) {
        genericTextView = (TextView) view.findViewById(R.id.fragment_generic_text_view);
        titleTextView = (TextView) view.findViewById(R.id.fragment_generic_title_text_view);
        doneRelativeLayout = (RelativeLayout) view.findViewById(R.id.fragment_generic_done_relative_layout);
        doneRelativeLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                popFragmentFromBackStack();
            }
        });
        textResourceId = getArguments().getInt("text_resource_id", R.string.privacy_policy_text);
        genericTextView.setText(textResourceId);
        switch (textResourceId) {
            case R.string.privacy_policy_text:
                setTitle(R.string.privacy_caps);
                break;
            case R.string.terms_of_use_text:
                setTitle(R.string.terms_of_use_caps);
                break;
            case R.string.faq_text:
                setTitle(R.string.faqs_caps);
                break;
        }
        
        isShowOriActionBar = getArguments().getBoolean("isShowOriActionBar");
    }

    private void setTitle(int termsOfUse) {
        titleTextView.setText(getString(termsOfUse));
    }

    @Override
    public Animator onCreateAnimator(int transit, final boolean enter, int nextAnim) {
        final int animatorId = (enter) ? R.anim.translate_from_bottom_to_top : R.anim.translate_from_top_to_bottom;
        Animator animator = AnimatorInflater.loadAnimator(getActivity(), animatorId);
        animator.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
            	if (enter) {
            		   AppData.getInstance().handler.postDelayed(new Runnable() {
                           @Override
                           public void run() {
                               getActivity().getActionBar().hide();
                           }
                       }, 120);
            	}
            	else {
                	if (isShowOriActionBar) {
              	      AppData.getInstance().handler.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                getActivity().getActionBar().show();
                            }
                        }, 120);
              	}
            	}
            }

            @Override
            public void onAnimationEnd(Animator animation) {

            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        //animator.setInterpolator();

        /*animator.setAnimatiorListener(new Animation.AnimationListener() {

                                      public void onAnimationStart(Animation animation) {
                                      }

                                      public void onAnimationRepeat(Animation animation) {
                                      }

                                      public void onAnimationEnd(Animation animation) {
                                      }
                                  }
        );*/

        return animator;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_generic_text_view, container, false);
    }


    @Override
    public void onDestroy() {
//        getActivity().getActionBar().show();
        popFragmentFromBackStack();
        super.onDestroy();
    }

    private void popFragmentFromBackStack() {
        if (GenericTextViewFragment.this.isAdded()) {
            getFragmentManager().popBackStack(Constants.GENERIC_TEXT_VIEW_FRAGMENT, FragmentManager.POP_BACK_STACK_INCLUSIVE);
        }
    }
}
