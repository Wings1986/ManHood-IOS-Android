package com.VVTeam.ManHood.Helper;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.graphics.Bitmap;
import android.graphics.drawable.ColorDrawable;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.VVTeam.ManHood.R;



public class DialogHelper {
    public static Dialog getConfirmationDialog(Context context, String title, String content,
    											String firstText, String secondText,
                                               final DialogCallBack callback) {
        if (context != null) {
            /*final Dialog dialog = new Dialog(context);
            dialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
            dialog.setContentView(R.layout.cancel_dialog);
            TextView titleTextView = (TextView) dialog.findViewById(R.id.title);
            TextView contentTextView = (TextView) dialog.findViewById(R.id.content);
            titleTextView.setText(title != null ? title : "");
            contentTextView.setText(content != null ? content : "");
            Button okButton = (Button) dialog.findViewById(R.id.dialog_ok_button);
            okButton.setOnClickListener(new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                dialog.dismiss();
                                                if (okButtonListener != null) {
                                                    okButtonListener.onClick(v);
                                                }
                                            }
                                        }
            );
            Button cancelButton = (Button) dialog.findViewById(R.id.dialog_cancel_button);
            cancelButton.setOnClickListener(new View.OnClickListener() {
                                                @Override
                                                public void onClick(View view) {
                                                    dialog.dismiss();
                                                }
                                            }
            );
            return dialog;*/
        	
        	final AlertDialog.Builder builder = new AlertDialog.Builder(context);
        	builder.setTitle(title);
            builder.setMessage(content);
            builder.setCancelable(true);
            builder.setNegativeButton(firstText, new OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					dialog.dismiss();
					
					if (callback != null) {
						callback.onClick(0);
					}
				}
			});
            
            if (secondText != null) {
                builder.setPositiveButton(secondText, new OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        if (callback != null) {
    						callback.onClick(1);
    					}
                    }
                });
            }
            
            AlertDialog alertDialog = builder.create();
            alertDialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
            return alertDialog;
        }
        return null;
    }

    public static Dialog getErrorDialog(Context context, String content,
                                        final Dialog.OnClickListener okButtonListener) {
        if (context == null) {
            return null;
        }
        final AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setMessage(content);
        builder.setCancelable(true);
        builder.setPositiveButton(context.getString(R.string.ok), new Dialog.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if (okButtonListener != null) {
                    okButtonListener.onClick(dialog, which);
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
        return alertDialog;
    }

    public static Dialog getFrontPictureTakingInfoDialog(Context context, String title, int drawableResourceId, String buttonText) {
        if (context == null) {
            return null;
        }
        final Dialog dialog = new Dialog(context);
        dialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(android.graphics.Color.TRANSPARENT));
        dialog.setContentView(R.layout.dialog_camera_info);
        TextView titleTextView = (TextView) dialog.findViewById(R.id.dialog_camera_info_title_text_view);
        ImageView contentImageView = (ImageView) dialog.findViewById(R.id.dialog_camera_info_context_image_view);
        Button bottomButton = (Button) dialog.findViewById(R.id.dialog_camera_info_bottom_button);

        titleTextView.setText(title);
        contentImageView.setImageResource(drawableResourceId);
        bottomButton.setText(buttonText);
        bottomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        return dialog;
    }

    public static Dialog getFrontPictureTakingInfoDialog(Context context, String title, Bitmap bitmap, String buttonText) {
        if (context == null) {
            return null;
        }
        final Dialog dialog = new Dialog(context);
        dialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(android.graphics.Color.TRANSPARENT));
        dialog.setContentView(R.layout.dialog_camera_info);
        TextView titleTextView = (TextView) dialog.findViewById(R.id.dialog_camera_info_title_text_view);
        ImageView contentImageView = (ImageView) dialog.findViewById(R.id.dialog_camera_info_context_image_view);
        Button bottomButton = (Button) dialog.findViewById(R.id.dialog_camera_info_bottom_button);

        titleTextView.setText(title);
        contentImageView.setImageBitmap(bitmap);
        bottomButton.setText(buttonText);
        bottomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });
        return dialog;
    }
}
