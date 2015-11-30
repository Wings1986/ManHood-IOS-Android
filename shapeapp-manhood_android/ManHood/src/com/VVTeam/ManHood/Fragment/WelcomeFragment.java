package com.VVTeam.ManHood.Fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import com.VVTeam.ManHood.Activity.MainActivity;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.R;
import com.VVTeam.ManHood.RequestManager;

/**
 * Created by blase on 27.08.14.
 */
public class WelcomeFragment extends Fragment {

    private ImageView guyImageView;
    private ImageView girlImageView;
    private TextView privacyPolicyTermsOfUseTextView;
    private Button enterButton;

    public static WelcomeFragment newInstance() {
        WelcomeFragment fragment = new WelcomeFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getActivity().getActionBar().hide();
        initViews(view);
    }

    private void initViews(View view) {
        guyImageView = (ImageView) view.findViewById(R.id.fragment_welcome_guy_image_view);
        girlImageView = (ImageView) view.findViewById(R.id.fragment_welcome_girl_image_view);
        enterButton = (Button) view.findViewById(R.id.fragment_welcome_enter_button);
        privacyPolicyTermsOfUseTextView = (TextView) view.findViewById(R.id.fragment_welcome_privacy_policy_text_view);
        SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder(getString(R.string.privacy_policy));
        spannableStringBuilder.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                ((MainActivity) getActivity()).openGenericTextViewFragment(true, R.string.terms_of_use_text);
                privacyPolicyTermsOfUseTextView.requestFocusFromTouch();
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setColor(getResources().getColor(R.color.text_link_color));
            }
        }, 31, 31 + 12, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannableStringBuilder.setSpan(new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                ((MainActivity) getActivity()).openGenericTextViewFragment(true, R.string.privacy_policy_text);
                privacyPolicyTermsOfUseTextView.requestFocusFromTouch();
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setColor(getResources().getColor(R.color.text_link_color));
            }
        }, 87, 87 + 14, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        privacyPolicyTermsOfUseTextView.setText(spannableStringBuilder, TextView.BufferType.SPANNABLE);

        privacyPolicyTermsOfUseTextView.setMovementMethod(LinkMovementMethod.getInstance());
        guyImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (enterButton != null && !enterButton.isEnabled()) {
                    enterButton.setEnabled(true);
                }
                girlImageView.setSelected(false);
                guyImageView.setSelected(true);
            }
        });
        girlImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (enterButton != null && !enterButton.isEnabled()) {
                    enterButton.setEnabled(true);
                }
                guyImageView.setSelected(false);
                girlImageView.setSelected(true);
            }
        });
        enterButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AppData.getInstance().saveGenderChoice(guyImageView.isSelected());
                //RequestManager.getInstance().executeCreateUserRequest();
                ((MainActivity) getActivity()).openHistogramFragment(false);
            }
        });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_welcome, container, false);
    }
}
