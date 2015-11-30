package com.VVTeam.ManHood.Fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.CompoundButton;
import android.widget.ListView;
import android.widget.RelativeLayout;
import com.VVTeam.ManHood.Activity.SettingsActivity;
import com.VVTeam.ManHood.Adapter.SettingsListAdapter;
import com.VVTeam.ManHood.AppData;
import com.VVTeam.ManHood.Enum.TextSettingType;
import com.VVTeam.ManHood.UIModel.Settings.ArrowSettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.SettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.SwitchSettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.TextSettingsItem;
import com.VVTeam.ManHood.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by blase on 29.08.14.
 */
public class SettingsFragment extends Fragment {

    private RelativeLayout histogramLayout;
    private ListView settingsListView;
    private SettingsListAdapter settingsListAdapter;
    private List<SettingsItem> settingsItemList;

    public static SettingsFragment newInstance() {
        SettingsFragment fragment = new SettingsFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initSettingsItemList();
        initViews(view);
    }

    private void initSettingsItemList() {
        settingsItemList = new ArrayList<SettingsItem>();
        settingsItemList.add(new SwitchSettingsItem(getString(R.string.hide_personal_data), AppData.getInstance().isHidePersonalData(), new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                AppData.getInstance().switchHidePersonalData();
            }
        }));
        settingsItemList.add(new TextSettingsItem(getString(R.string.units), AppData.getInstance().getUnitsType()));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.join_the_inner_circle)));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.give_feedback)));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.tell_a_friend)));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.help)));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.privacy)));
        settingsItemList.add(new ArrowSettingsItem(getString(R.string.terms_of_use)));
    }

    private void initViews(View view) {
        histogramLayout = (RelativeLayout) view.findViewById(R.id.fragment_settings_histogram_relative_layout);
        settingsListView = (ListView) view.findViewById(R.id.fragment_settings_list_view);
        settingsListAdapter = new SettingsListAdapter(getActivity(), settingsItemList);
        settingsListView.setAdapter(settingsListAdapter);
        histogramLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((SettingsActivity) getActivity()).navigateUp();
            }
        });

        settingsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                switch (position) {
                    case 0:
                        ((SwitchSettingsItem) settingsListAdapter.objects.get(position)).setOn(!((SwitchSettingsItem) settingsListAdapter.objects.get(position)).isOn());
                        AppData.getInstance().switchHidePersonalData();
                        break;
                    case 1:
                        TextSettingsItem textSettingsItem = ((TextSettingsItem) settingsListAdapter.objects.get(position));
                        TextSettingType textSettingType = textSettingsItem.getTextSettingType() == TextSettingType.IN ? TextSettingType.CM : TextSettingType.IN;
                        textSettingsItem.setTextSettingType(textSettingType);
                        AppData.getInstance().saveUnitsType(textSettingType);
                        break;
                    case 2:
                    	break;
                    case 3:
                        ((SettingsActivity) getActivity()).openSupportActivity();
                        break;
                    case 4:
                    	((SettingsActivity) getActivity()).openTellFriends();
                        break;
                    case 5:
                        ((SettingsActivity) getActivity()).openHelpActivity();
                        break;
                    case 6:
                        ((SettingsActivity) getActivity()).openGenericTextViewFragment(true, R.string.privacy_policy_text);
                        break;
                    case 7:
                        ((SettingsActivity) getActivity()).openGenericTextViewFragment(true, R.string.terms_of_use_text);
                        break;
                }
                settingsListAdapter.notifyDataSetChanged();
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        getActivity().getActionBar().hide();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_settings, container, false);
    }
}
