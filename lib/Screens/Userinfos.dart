import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Services/Firebase.dart';
import 'package:whatsup/Services/Storage.dart';
import 'package:whatsup/Widgets/Styles.dart';

class Userinfos extends StatefulWidget {
  final String user;
  Userinfos({Key key, this.user}) : super(key: key);

  @override
  _UserinfosState createState() => _UserinfosState();
}

class _UserinfosState extends State<Userinfos> {
  TextEditingController controller = TextEditingController();
  var formKey = GlobalKey<FormState>();
  String name, about;
  List<bool> isSelected3 = [false, false];

  File file;
  String phone;
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("profile".tr,
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        body: FutureBuilder<Object>(
            future: Firebase().getUser(widget.user),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              Person owner = snapshot.data;
              return body(owner);
            }));
  }

  Widget body(Person owner) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    option(context);
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: file == null
                        ? NetworkImage(owner.photo)
                        : FileImage(file),
                    backgroundColor: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                tile(Icons.person, "name".tr, name != null ? name : owner.username,
                    true, context, controller, true),
                SizedBox(
                  height: 15,
                ),
                tile(Icons.info_outline, "about".tr, about != null ? about : owner.about, true, context,
                    controller, false),
                SizedBox(
                  height: 15,
                ),
                tile(Icons.phone, "phone".tr, owner.number, false, context,
                    controller, false),
                SizedBox(height: 15,),
                loading == false
                    ? ElevatedButton.icon(
                        onPressed: () {
                          finish(owner);
                        },
                        icon: Icon(Icons.navigate_next_rounded),
                        label: Text("save".tr))
                    : Center(child: CircularProgressIndicator())
              ],
            ),
          ),
        ));
  }

  bottomsheet(
      BuildContext context, TextEditingController controller, bool text) {
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
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 15),
                  child: Text(
                    text == true ? "eyn".tr : "ways".tr,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      text == true
                          ? Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: "wout".tr,
                                  ),
                                  cursorColor: Colors.teal,
                                  maxLength: 15,
                                  onChanged: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  }),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: "about".tr,
                                  ),
                                  cursorColor: Colors.teal,
                                  maxLength: 50,
                                  onChanged: (value) {
                                    setState(() {
                                      about = value;
                                    });
                                  }),
                            ),
                      IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 28,
                          ),
                          onPressed: null)
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (text == true) {
                            setState(() {
                              name = null;
                            });
                          } else {
                            setState(() {
                              about = null;
                            });
                          }
                          controller.clear();
                          Get.back();
                        },
                        child: Text(
                          "cancel".tr,
                          style: TextStyle(color: Colors.teal.shade600),
                        )),
                    TextButton(
                        onPressed: () {
                          formKey.currentState.save();
                          controller.clear();
                          Get.back();
                        },
                        child: Text(
                          "save".tr,
                          style: TextStyle(color: Colors.teal.shade600),
                        )),
                  ],
                )
              ],
            )));
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

  Widget tile(IconData icon, String main, info, bool show, BuildContext context,
      TextEditingController controller, bool text) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.teal.shade800,
      ),
      trailing: show
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              onPressed: () {
                bottomsheet(context, controller, text);
              },
            )
          : SizedBox(
              height: 0,
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            main,
            style: Styles().editmain(),
          ),
          SizedBox(
            height: 4,
          ),
          Text(info, style: Styles().editinfo())
        ],
      ),
    );
  }

  void finish(Person owner) async {
    setState(() {
      loading = true;
    });
  if(file != null){
    String photoUrl;
     photoUrl = await StorageService().profilephotos(file);
    Firebase().updateUser(
        id: widget.user, username: name != null ? name : owner.username, about: about != null ? about : owner.about, photo: photoUrl );
  }else {Firebase().updateUser(
        id: widget.user, username: name != null ? name : owner.username, about: about != null ? about : owner.about,photo: owner.photo);}
    
    if (mounted) {
      setState(() {
        loading = false;
      });
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
