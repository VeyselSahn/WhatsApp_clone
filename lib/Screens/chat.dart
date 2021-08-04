import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsup/Models/Message.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Services/Firebase.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:whatsup/Services/Storage.dart';

class Chat extends StatefulWidget {
  final Person boxowner;
  final String owner;

  const Chat({Key key, this.boxowner, this.owner}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _etChat = TextEditingController();
  String fillcontrol;
  File file;
  List<String> choices = <String>[
    'wc'.tr,
    'mld'.tr,
    'search'.tr,
    'mn'.tr,
    'cc'.tr
  ];

  @override
  void initState() {
    setState(() {});
    super.initState();
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  void dispose() {
    _etChat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.boxowner.photo),
              )
            ],
          ),
          leadingWidth: 88,
          brightness: Brightness.light,
          elevation: 0,
          title: Text(
            widget.boxowner.username,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          bottom: PreferredSize(
              child: Container(
                color: Colors.grey[100],
                height: 1.0,
              ),
              preferredSize: Size.fromHeight(1.0)),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.videocam), onPressed: () async{
              await Firebase().addCall(caller: widget.owner,opener: widget.boxowner.id,type: "video");
              Get.snackbar("Video Call","Not working now",backgroundColor: Colors.white,colorText: Colors.teal);
            }),
            IconButton(icon: Icon(Icons.phone), onPressed: () async{
              await Firebase().addCall(caller: widget.owner,opener: widget.boxowner.id,type: "audio");
              Get.snackbar("Audio Call", "Not working now",backgroundColor: Colors.teal.shade200,colorText: Colors.white);
            }),
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: file != null
            ? imagemessage()
            : Column(
                children: [messages(), input()],
              ));
  }

  Widget messages() {
    return Expanded(
      child: StreamBuilder(
          stream: Firebase().getMessages(widget.owner),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data.docs.length == 0)
              return Center(
                child: Text('eb'.tr,
              ));
            else {
              return ListView.builder(
                  shrinkWrap: true,
                  reverse: false,
                  clipBehavior: Clip.hardEdge,
                  itemCount: snapshot.data.docs.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    Message message =
                        Message.producingDoc(snapshot.data.docs[index]);
                    String _currentTime =
                        DateFormat('kk:mm').format(message.time.toDate());

                    if (message.url != null) {
                      if (message.ownerId == widget.boxowner.id)
                        return _buildImage(message.url, WrapAlignment.end);
                      else
                        return _buildImage(message.url, WrapAlignment.start);
                    } else {
                      if (message.ownerId == widget.boxowner.id &&
                          message.receiverId == widget.owner) {
                        return _buildChatSeller(message, _currentTime);
                      } else if (message.url == null &&
                          message.ownerId == widget.owner && message.receiverId == widget.boxowner.id) {
                        return _buildChatBuyer(message, true, _currentTime);
                      }else return null;
                    }
                  });
            }
          }),
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
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                imagemessage();
              },
            ),
            IconButton(
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

  Widget input() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              controller: _etChat,
              minLines: 1,
              maxLines: 4,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
              onChanged: (textValue) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.emoji_emotions_outlined,
                    color: Colors.grey.shade600),
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.control_point,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      InkWell(
                        onTap: () => option(context),
                        child: Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.grey.shade600,
                        ),
                      )
                    ],
                  ),
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: 'tam'.tr,
                focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.grey[200])),
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.grey[200]),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            child: GestureDetector(
              onTap: () {
                send();
              },
              child: ClipOval(
                child: Container(
                    color: Colors.teal,
                    padding: EdgeInsets.all(10),
                    child: Icon(_etChat.text != "" ? Icons.send : Icons.mic,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void send() {
    if (_etChat.text != "") {
      Firebase().addMessage(
          ownerId: widget.owner,
          text: _etChat.text,
          receiverId: widget.boxowner.id);
      Firebase()
          .addChatFriend(ownerId: widget.owner, receiverId: widget.boxowner.id);
      _etChat.clear();
    } else {
      return null;
    }
  }

  Future<void> imagemessage() async {
    String photoUrl = await StorageService().imagemessage(file);
    try {
      Firebase().addMessage(
          ownerId: widget.owner, receiverId: widget.boxowner.id, url: photoUrl);
      Firebase()
          .addChatFriend(ownerId: widget.owner, receiverId: widget.boxowner.id);
    } catch (e) {
      Get.snackbar("Error", "Error at add story");
    }
    setState(() {
      file = null;
    });
  }

  void choiceAction(String choice) {
    if (choice == 'Clear chat') {
      Firebase().deleteMessages(widget.owner, widget.boxowner.id);
      Get.back();
    } else {
      Get.back();
    }
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

  Widget _buildImage(String imageUrl, WrapAlignment alignment) {
    final double boxChatSize = MediaQuery.of(context).size.width / 1.3;
    final double boxImageSize = (MediaQuery.of(context).size.width / 6);
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: boxChatSize),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey[300]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(12),
                )),
            child: Container(
              width: boxImageSize,
              height: boxImageSize,
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBuyer(Message message, bool read, String time) {
    final double boxChatSize = MediaQuery.of(context).size.width / 1.3;
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: boxChatSize),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey[300]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(12),
                ),
                color: Colors.blue),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child:
                      Text(message.text, style: TextStyle(color: Colors.white)),
                ),
                Wrap(
                  children: [
                    SizedBox(width: 4),
                    Icon(Icons.done_all,
                        color: read == true ? Colors.white : Colors.grey,
                        size: 11),
                    SizedBox(width: 2),
                    Text(time,
                        style: TextStyle(color: Colors.white, fontSize: 9)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSeller(Message message, String time) {
    final double boxChatSize = MediaQuery.of(context).size.width / 1.3;
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Wrap(
        children: [
          Container(
              constraints: BoxConstraints(maxWidth: boxChatSize),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[300]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(5),
                  )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(message.text,
                        style: TextStyle(color: Colors.black)),
                  ),
                  Wrap(
                    children: [
                      SizedBox(width: 2),
                      Text(time,
                          style: TextStyle(color: Colors.grey, fontSize: 9)),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}
