import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'constants.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // aliasing http package
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Photo Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> photoUrls = []; // Stores photo URLs from server
  Set<String> selectedPhotos = {}; // Stores URLs of selected photos

  Future<void> pickImage() async {
    if (kIsWeb) {
      await pickImageWeb();
      return;
    }

    await pickImageMobile();
  }

  Future<void> pickImageMobile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("This${pickedFile.path}");
      // Upload image and update photoUrls on success
      String uploadedUrl = await uploadImage(pickedFile.path);
      setState(() {
        photoUrls.add(uploadedUrl);
      });
    }
  }

  Future<void> pickImageWeb() async {
    var picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked == null) return;
    // Convert the file to bytes
    var bytes = picked.files.first.bytes;
    if (bytes == null) return;
    // Upload image and update photoUrls on success
    String uploadedUrl =
        await uploadImageFromBytes(picked.files.first.name, bytes);
    setState(() {
      photoUrls.add(uploadedUrl);
    });
  }

  Future<void> fetchPhotos() async {
    final response = await http
        .get(Uri.parse(baseUrl)); // Replace with your actual API endpoint
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        for (var item in data) {
          String photoName = item['imageName'];
          List<String> parts = photoName.split('.');
          photoUrls
              .add('$baseUrl/photo?name=${parts[0]}&extension=${parts[1]}');
        }
      });
    } else {
      // Handle unsuccessful response (Throw Exception)
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Photo Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: selectedPhotos.isEmpty ? null : deleteSelectedPhotos,
            // Hide delete icon if no photos are selected
            color: selectedPhotos.isEmpty ? Colors.white : Colors.red,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: photoUrls.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoView(
                        imageProvider:
                            CachedNetworkImageProvider(photoUrls[index]),
                      ),
                    ),
                  ),
                  onLongPress: () => setState(() {
                    if (selectedPhotos.contains(photoUrls[index])) {
                      selectedPhotos.remove(photoUrls[index]);
                    } else {
                      selectedPhotos.add(photoUrls[index]);
                    }
                  }),
                  child: Stack(children: [
                    CachedNetworkImage(
                      imageUrl: photoUrls[index],
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    // Visually differentiate selected photos (optional)
                    if (selectedPhotos.contains(photoUrls[index]))
                      Container(
                        color:
                            Colors.black26, // Example for selected background
                      ),
                  ]),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton.extended(
                  onPressed: () => pickImage(),
                  label: const Text('Pick Image'),
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Replace with your actual upload logic using http package
  Future<String> uploadImage(String imagePath) async {
    // ... Upload logic and return uploaded image URL
    // return 'https://img.freepik.com/free-photo/colorful-design-with-spiral-design_188544-9588.jpg';
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    var multipartFile = await http.MultipartFile.fromPath('photo', imagePath);
    request.files.add(multipartFile);
    var response = await request.send();

    // Handle the response (failure)
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }

    var data = jsonDecode(await response.stream.bytesToString());
    List<String> parts = data['imageName'].split('.');

    return '$baseUrl/photo?name=${parts[0]}&extension=${parts[1]}';
  }

  Future<String> uploadImageFromBytes(
      String filename, List<int> imageBytes) async {
    // ... Upload logic and return uploaded image URL
    // return 'https://img.freepik.com/free-photo/colorful-design-with-spiral-design_188544-9588.jpg';
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    var multipartFile =
        http.MultipartFile.fromBytes('photo', imageBytes, filename: filename);
    request.files.add(multipartFile);
    var response = await request.send();

    // Handle the response (failure)
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }

    var data = jsonDecode(await response.stream.bytesToString());
    List<String> parts = data['imageName'].split('.');

    return '$baseUrl/photo?name=${parts[0]}&extension=${parts[1]}';
  }

  Future<void> deleteSelectedPhotos() async {
    if (selectedPhotos.isEmpty) return; // Handle empty selection

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text(
            'Are you sure you want to delete ${selectedPhotos.length} photos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed) {
      // Perform deletion logic on selected photos
      for (final photoUrl in selectedPhotos.toList()) {
        // Making the url to delete the photo
        int lastSlash = photoUrl.lastIndexOf('/');
        int lastQuestionMark = photoUrl.lastIndexOf('?');
        String deleteUrl = photoUrl.substring(0, lastSlash) +
            photoUrl.substring(lastQuestionMark);

        // Make API call to your Spring Boot API to delete the photo
        final response = await http
            .delete(Uri.parse(deleteUrl)); // Replace with your actual endpoint
        if (response.statusCode == 200) {
          setState(() {
            photoUrls.remove(photoUrl);
            selectedPhotos.remove(photoUrl);
          });
        } else {
          // Handle unsuccessful response (Throw Exception)
          throw Exception('Failed to delete photo: ${response.statusCode}');
        }
      }
    }
  }
}
