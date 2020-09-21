import 'package:flutter_test/flutter_test.dart';

import '../lib/models/post.dart';

void main() {
  test('Post constructor functions properly', () {
    final date = DateTime.now();
    final url = "swag";
    final quantity = 69;
    final latitude = 1.0;
    final longitude = 2.0;

    Post post = new Post(
        date: date,
        imageURL: url,
        quantity: quantity,
        latitude: latitude,
        longitude: longitude);

    expect(post.date, date);
  });
}
