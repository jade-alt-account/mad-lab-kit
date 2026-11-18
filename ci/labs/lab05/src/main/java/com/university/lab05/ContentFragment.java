package com.university.lab05;

import android.content.Context;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

public class ContentFragment extends Fragment {

    // Action: Define the Interface
    public interface OnFragmentInteractionListener {
        void onButtonClicked(String data);
    }

    private OnFragmentInteractionListener mListener;

    // Action: Ensure the Host Activity Implements the Interface
    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_content, container, false);
        Button btn = view.findViewById(R.id.action_button);

        // Action: Trigger the Callback
        btn.setOnClickListener(v -> {
            if (mListener != null) {
                mListener.onButtonClicked("Data from Fragment!");
            }
        });
        return view;
    }
}
