package com.university.lab04;

import android.os.Parcel;
import android.os.Parcelable;

public class UserProfile implements Parcelable {
    private String username;
    private int accessLevel;

    // Standard constructor
    public UserProfile(String username, int accessLevel) {
        this.username = username;
        this.accessLevel = accessLevel;
    }

    // Parcelable constructor (Reading from Parcel)
    protected UserProfile(Parcel in) {
        username = in.readString();
        accessLevel = in.readInt();
    }

    // Writing to Parcel
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(username);
        dest.writeInt(accessLevel);
    }

    @Override
    public int describeContents() { return 0; }

    // added for the test screen
    public String getUsername() { return username; }

    // Required Creator field
    public static final Creator<UserProfile> CREATOR = new Creator<UserProfile>() {
        @Override
        public UserProfile createFromParcel(Parcel in) {
            return new UserProfile(in);
        }
        @Override
        public UserProfile[] newArray(int size) {
            return new UserProfile[size];
        }
    };
}
