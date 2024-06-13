package org.example.remotegalleryproject.repositories;

import org.apache.commons.io.IOUtils;
import org.example.remotegalleryproject.entities.ImageDetails;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class GalleryRepository {
    public Iterable<ImageDetails> getImageList() throws IOException {
        List<ImageDetails> photoList = new ArrayList<>();

        try (DirectoryStream<Path> stream = Files.newDirectoryStream(Paths.get("src/main/resources/uploads/"))){
            for (Path path: stream) {
                if (!Files.isDirectory(path)) {
                    photoList.add(new ImageDetails(path.getFileName().toString(), ""));
                }
            }
        }

        return  photoList;
    }

    public ImageDetails saveImage(MultipartFile photo) throws IOException{
        byte[] bytes = photo.getBytes();
        Path filePath = Paths.get("src/main/resources/uploads/" + photo.getOriginalFilename());
        Files.createFile(Paths.get("src/main/resources/uploads/" + photo.getOriginalFilename()));
        Files.write(filePath, bytes);

        return new ImageDetails(photo.getOriginalFilename(), "");
    }

    public Iterable<ImageDetails> deleteFile(String filename) throws IOException{
        Path fileToDelete = Paths.get("src/main/resources/uploads/" + filename);
        System.out.println(fileToDelete);
        Files.delete(fileToDelete);

        return this.getImageList();
    }

    public byte[] loadPhoto(String filename) throws IOException{
//        try (InputStream in = getClass().getResourceAsStream("/uploads/" + filename)) {
//            assert in != null;
//            return IOUtils.toByteArray(in);
//        }
        Path path = Paths.get("src/main/resources/uploads/" + filename);
        return Files.readAllBytes(path);

    }
}
