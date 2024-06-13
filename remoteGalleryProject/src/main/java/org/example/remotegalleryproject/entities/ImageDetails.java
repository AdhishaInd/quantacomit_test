package org.example.remotegalleryproject.entities;

public class ImageDetails {
    private String imageName;

    private String fileExtension;

    public String getImageName() {
        return this.imageName;
    }

    public String getFileExtension() {
        return this.fileExtension;
    }

    public ImageDetails(String name, String extension) {
        imageName = name;
        fileExtension = extension;
    }

    public void setImageName(String name) {
        this.imageName = name;
    }

    public void setFileExtension(String extension) {
        this.fileExtension = extension;
    }
}
