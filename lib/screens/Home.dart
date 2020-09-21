import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasteagram/models/post.dart';
import 'package:intl/intl.dart';

import 'CreatePostScreen.dart';
import 'ViewPostScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int idx;
  String imageURL;
  List<Post> listOfPosts = [];
  int numPosts;
  File _image;
  final picker = ImagePicker();
  final template = DateFormat('EEE, MMM d, yyyy HH:mm:ss');

  @override
  initState() {
    super.initState();
    setState(() {});
  }

  //https://www.c-sharpcorner.com/article/upload-image-file-to-firebase-storage-using-flutter/
  Future chooseFile() async {
    await picker.getImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = File(image.path);
        print("Successfully retrieved image...");
      });
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostScreen(image: _image)),
    );
  }

  void gotoPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewPostScreen(post: listOfPosts[idx], imageURL: imageURL)),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      listOfPosts.clear();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Wasteagram - $numPosts"),
      ),
      body: Center(
        child: StreamBuilder(
          stream: Firestore.instance.collection('posts').snapshots(),
          builder: (content, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.documents.length == 0) {
                numPosts = 0;
                return CircularProgressIndicator();
              } else {
                numPosts = snapshot.data.documents.length;
              }
              listOfPosts.clear();
              for (int i = 0; i < numPosts; i++) {
                listOfPosts.add(new Post(
                    date: (snapshot.data.documents[i]['date'] as Timestamp)
                        .toDate(),
                    imageURL: snapshot.data.documents[i]['imageURL'],
                    quantity: snapshot.data.documents[i]['quantity'],
                    latitude: snapshot.data.documents[i]['latitude'],
                    longitude: snapshot.data.documents[i]['longitude']));
              }
              listOfPosts.sort((a, b) => b.date.compareTo(a.date));
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return Semantics(
                        label: "Waste post $index",
                        child: ListTile(
                            onTap: () {
                              setState(() {
                                idx = index;
                                imageURL = listOfPosts[index].imageURL;
                              });
                              gotoPost();
                            },
                            title: Text(
                              template.format(listOfPosts[index].date),
                              textScaleFactor: 1.2,
                            ),
                            trailing: Text(
                              listOfPosts[index].quantity.toString(),
                              textScaleFactor: 1.4,
                            )));
                  });
            } numPosts = 0;
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: Semantics(
        label: "New post",
        child: FloatingActionButton(
          onPressed: () {
            chooseFile();
          },
          tooltip: 'New post',
          child: Icon(Icons.camera_enhance),
        ),
      ),
    );
  }
}
