package com.VVTeam.ManHood.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.Switch;
import android.widget.TextView;
import com.VVTeam.ManHood.UIModel.Settings.ArrowSettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.SettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.SwitchSettingsItem;
import com.VVTeam.ManHood.UIModel.Settings.TextSettingsItem;
import com.VVTeam.ManHood.R;

import java.util.List;

/**
 * Created by blase on 29.08.14.
 */
public class SettingsListAdapter extends BaseAdapter {

    private Context context;
    public List<SettingsItem> objects;

    private static LayoutInflater inflater;

    static class ViewHolder {
        TextView title;
        ImageView arrowRight;
        TextView settingText;
        Switch switchView;
    }

    public SettingsListAdapter(Context context, List<SettingsItem> objects) {
        this.context = context;
        this.objects = objects;
        if (inflater == null) {
            inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        }
    }

    @Override
    public int getCount() {
        if (objects == null) {
            return 0;
        }
        return objects.size();
    }

    @Override
    public Object getItem(int position) {
        return objects.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            holder = new ViewHolder();
            convertView = inflater.inflate(R.layout.child_settings_list, null, false);
            holder.title = (TextView) convertView.findViewById(R.id.child_settings_list_title_text_view);
            holder.arrowRight = (ImageView) convertView.findViewById(R.id.child_settings_list_arrow_image_view);
            holder.settingText = (TextView) convertView.findViewById(R.id.child_settings_list_setting_text_view);
            holder.switchView = (Switch) convertView.findViewById(R.id.child_settings_list_switch_view);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        holder.title.setText(objects.get(position).getTitle());

        holder.settingText.setVisibility(View.GONE);
        holder.arrowRight.setVisibility(View.GONE);
        holder.switchView.setVisibility(View.GONE);

        if (objects.get(position) instanceof TextSettingsItem) {
            holder.settingText.setVisibility(View.VISIBLE);
            holder.settingText.setText(((TextSettingsItem) objects.get(position)).getTextSettingType().toString());
        } else if (objects.get(position) instanceof ArrowSettingsItem) {
            holder.arrowRight.setVisibility(View.VISIBLE);
        } else if (objects.get(position) instanceof SwitchSettingsItem) {
            holder.switchView.setVisibility(View.VISIBLE);
            holder.switchView.setChecked(((SwitchSettingsItem) objects.get(position)).isOn());
            holder.switchView.setOnCheckedChangeListener(((SwitchSettingsItem) objects.get(position)).getOnCheckedChangeListener());
        }

        return convertView;
    }
}
