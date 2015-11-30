package com.VVTeam.ManHood.Adapter;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import com.VVTeam.ManHood.UIModel.GuideItemModel;
import com.VVTeam.ManHood.R;

import java.util.List;

/**
 * Created by blase on 29.08.14.
 */
public class GuidePagerAdapter extends PagerAdapter {
    private Context context;
    public List<GuideItemModel> objects;

    private static LayoutInflater inflater;

    public GuidePagerAdapter(Context context, List<GuideItemModel> objects) {
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
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }

    @Override
    public Object instantiateItem(ViewGroup container, final int position) {
        View view = inflater.inflate(R.layout.child_guide_view_pager, null, false);
        if (position < getCount()) {
            ImageView img = (ImageView) view.findViewById(R.id.child_guide_view_pager_image_view);
            img.setImageResource(objects.get(position).getImageResourceId());
            if (objects.get(position).getOnClickListener() != null) {
                img.setOnClickListener(objects.get(position).getOnClickListener());
            }

            TextView titleTextView = (TextView) view.findViewById(R.id.child_guide_view_pager_title_text_view);
            titleTextView.setText(objects.get(position).getTitle());

            TextView descriptionTextView = (TextView) view.findViewById(R.id.child_guide_view_pager_description_text_view);
            descriptionTextView.setText(objects.get(position).getDescription());
        }
        container.addView(view);
        return view;
    }

    @Override
    public boolean isViewFromObject(View view, Object o) {
        return view == o;
    }
}
