import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  final File image;

  CreatePostScreen({this.image});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState(image: image);
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  _CreatePostScreenState({this.image});

  final _formKey = GlobalKey<FormState>();

  final File image;
  final picker = ImagePicker();
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://wasteagram-2f80d.appspot.com');

  int quantity = 0;

  LocationData locationData;
  var locationService = Location();

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    try {
      var _serviceEnabled = await locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await locationService.requestService();
        if (!_serviceEnabled) {
          print('Failed to enable service. Returning.');
          return;
        }
      }

      var _permissionGranted = await locationService.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await locationService.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print('Location service permission not granted. Returning.');
        }
      }

      locationData = await locationService.getLocation();
    } on PlatformException catch (e) {
      print('Error: ${e.toString()}, code: ${e.code}');
      locationData = null;
    }
    locationData = await locationService.getLocation();
    setState(() {});
  }

  //https://www.c-sharpcorner.com/article/upload-image-file-to-firebase-storage-using-flutter/
  Future uploadFile() async {
    DateTime date = DateTime.now();
    String _path = 'images/$date.png';
    print("Uploading image...");
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(_path);
    StorageUploadTask uploadTask = _storage.ref().child(_path).putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      Firestore.instance.collection('posts').add({
        'date': date,
        'imageURL': fileURL,
        'quantity': quantity,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude
      });
    });
  }

  Widget loadImage() {
    if (image == null) {
      return (CircularProgressIndicator());
    }
    return (Image.file(image));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wasteagram"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  loadImage(),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Semantics(
                            label: "Number of items that were wasted",
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'How many items were wasted',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a number';
                                }
                                setState(() {
                                  quantity = int.parse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      label: "Upload button",
                      child: FlatButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (image != null) {
                              uploadFile();
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          "Upload some waste",
                        ),
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
