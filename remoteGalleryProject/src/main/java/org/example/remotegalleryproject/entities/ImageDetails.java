package org.example.remotegalleryproject.entities;

public class ImageDetails {
    private String imageName;

    public String getImageName() {
        return this.imageName;
    }

    public ImageDetails(String name) {
        imageName = name;
    }

    public void setImageName(String name) {
        this.imageName = name;
    }

}
