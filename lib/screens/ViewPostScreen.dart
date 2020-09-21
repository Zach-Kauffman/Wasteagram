import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wasteagram/models/post.dart';

class ViewPostScreen extends StatefulWidget {
  final Post post;
  final String imageURL;

  ViewPostScreen({this.post, this.imageURL});

  @override
  _ViewPostScreenState createState() =>
      _ViewPostScreenState(post: post, imageURL: imageURL);
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  final Post post;
  final String imageURL;
  final template = DateFormat('EEE, MMM d, yyyy HH:mm:ss');

  _ViewPostScreenState({this.post, this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wasteagram")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(template.format(post.date), textScaleFactor: 2.0),
          Stack(
            children: [
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: CircularProgressIndicator())),
              Center(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageURL,
                ),
              ),
            ],
          ),
          Text(
              post.quantity == 1
                  ? post.quantity.toString() + " item wasted"
                  : post.quantity.toString() + " items wasted",
              textScaleFactor: 2.5),
          Text(post.latitude.toString() + ", " + post.longitude.toString())
        ],
      ),
    );
  }
}
