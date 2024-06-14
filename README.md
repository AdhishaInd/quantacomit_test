# Assumptions
- No database used and files stored in server starage
- Image files are under 5 MB
# Instructions
- Flutter project folder is **remote_gallery_app** and Spring Boot project is **remoteGalleryProject**.
- Modify the base URL in remote_gallery_app\lib\constants.dart (localhost, 10.0.2.2 or any other)
- Build Spring project with Maven
# How to use
- Tap the inkwall on the gridview to full screen view.
- Long tap the inkwall to select it.
- Elavated button in the bottom right cornor is for picking images to upload.
- When you select at least one image delete at the rop right corner button will turn red.
- Press the delete button and confirm it in the alert for deleting single or multiple photos.
# Constraints
- Only one image can be picked at once
