import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsup/Instant/main.dart';
import 'package:whatsup/Instant/models/story_model.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Services/Firebase.dart';
import 'package:whatsup/Services/Storage.dart';

class Instant extends StatefulWidget {
  final String owner;

  const Instant({Key key, this.owner}) : super(key: key);
  @override
  _InstantState createState() => _InstantState();
}

class _InstantState extends State<Instant> {
  File file;
  String cc;
  TextEditingController caption = TextEditingController();
  List<String> choices = <String>["Back to camera", "Back to status"];
  List<Person> phones = [];
  Person me;

  @override
  void initState() {
    super.initState();
    getso();
    getMe();
  }

  Future<void> getso() async {
    List<Person> list = await Firebase().getStoryOwners();
    if (mounted) {
      setState(() {
        phones = list;
      });
    }
  }

  Future<void> getMe() async {
    Person tempme = await Firebase().getUser(widget.owner);
    if (mounted) {
      setState(() {
        me = tempme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: "float",
                    child: Icon(Icons.edit, color: Colors.blueGrey.shade700),
                    backgroundColor: Colors.grey.shade200,
                    onPressed: () {},
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  FloatingActionButton(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      option(context);
                    },
                  )
                ],
              )
            : SizedBox(
                height: 0,
              ),
        body: file == null ? body() : bodyPart());
  }

  Widget body() {
    return ListView.separated(
      separatorBuilder: (ctx, i) {
        return Divider();
      },
      itemCount: phones?.length ?? 0,
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int index) {
        Person person = phones?.elementAt(index);
        return FutureBuilder(
          future: Firebase().getUser(person.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return SizedBox(height: 0,
              );
            Person temp = snapshot.data;

            if (index == 0) {
              return Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    onTap: () {

                    },
                    leading: CircleAvatar(
                      backgroundImage: me != null
                          ? NetworkImage(me.photo)
                          : AssetImage("assets/nah.png"),
                      radius: 30,
                    ),
                    title: Text("ms".tr),
                    subtitle: Text("ttas".tr),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade300,
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                      child: Text(
                        "ws".tr,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  tile(temp)
                ],
              );
            }
            return tile(temp);
          },
        );
      },
    );
  }

  Widget tile(Person temp) {
    return ListTile(
      onTap: () async {
        List<Story> items = await Firebase().getStories(temp.id);
        if (items != null) {
          Get.to(() => StoryScreen(stories: items,owner: temp,));
        }
      },
      leading: CircleAvatar(
        backgroundImage: temp != null
            ? NetworkImage(temp.photo)
            : AssetImage("assets/nah.png"),
        radius: 30,
      ),
      title: Text(temp.username),
      subtitle: Text("lams".tr),
    );
  }

  Widget bodyPart() {
    return Column(
      children: [
        Expanded(
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_outlined),
              onPressed: () {
                setState(() {
                  file = null;
                });
                Get.back();
              },
            ),IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                create();
              },
            ),IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                camera();
              },
            ),
          ],
        )
      ],
    );
  }



  Future<void> create() async {
    String photoUrl = await StorageService().instantphotos(file);
    try {
      Firebase().createStory(
          media: "image", owner: widget.owner, url: photoUrl);
      Firebase().addStoryOwner(id: widget.owner);
    } catch (e) {
      Get.snackbar("Error", "Error at add story");
    }
    setState(() {
      file = null;
    });
  }

  option(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    camera();
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.camera,
                    color: Colors.teal,
                  ),
                  title: Text(
                    "tap".tr,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
                ListTile(
                  onTap: () {
                    gallery();
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.image,
                    color: Colors.teal,
                  ),
                  title: Text(
                    "cog".tr,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ],
            )));
  }

  void choiceAction(String choice) {
    if (choice == 'Clear chat') {
      Get.back();
    } else {
      Get.back();
    }
  }

  void gallery() async {
    final _picker = ImagePicker();
    var image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    } else
      print("null");
  }

  void camera() async {
    final _picker = ImagePicker();
    var image =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 100);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    } else
      print("null");
  }
}
