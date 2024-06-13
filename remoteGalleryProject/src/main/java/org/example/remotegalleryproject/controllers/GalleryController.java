package org.example.remotegalleryproject.controllers;

import org.example.remotegalleryproject.entities.ImageDetails;
import org.example.remotegalleryproject.repositories.GalleryRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/gallery")
public class GalleryController {

    private final GalleryRepository galleryRepository = new GalleryRepository();

    @GetMapping()
    public Iterable<ImageDetails> getPhotoList() {
        try {
            return galleryRepository.getImageList();
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Fail to retrieve the photo list");
        }

    }

    @GetMapping(value = "/photo", produces = MediaType.IMAGE_JPEG_VALUE)
    public byte[] getImage(@RequestParam String name, @RequestParam String extension) {
        try {
            return galleryRepository.loadPhoto(name + '.' + extension);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Fail to retrieve the photo");
        }
    }

    @PostMapping("/upload")
    public ImageDetails uploadPhoto(MultipartFile photo) {
        try {
            return galleryRepository.saveImage(photo);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.EXPECTATION_FAILED, "Fail to upload the photo");
        }
    }

    @DeleteMapping()
    public Iterable<ImageDetails> deletePhoto(@RequestParam String name, @RequestParam String extension) {
        try {
            return galleryRepository.deleteFile(name + '.' + extension);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Fail to delete the photo");
        }
    }
}
