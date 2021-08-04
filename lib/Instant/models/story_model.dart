import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

enum MediaType {
  image,
  video,
}

class Story {
  final String url;
  final String media;
  final Duration duration;
  final String user;
  final String caption;


  const Story( {@required this.caption,
    @required this.url,
    @required this.media,
    @required this.duration,
    @required this.user,
  });

    factory Story.producingDoc(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Story(
      url: docData['url'],
      caption: docData['caption'],
      media: docData['media'],
      duration: docData['duration'],
      user: docData['owner']
    );
  }
}
