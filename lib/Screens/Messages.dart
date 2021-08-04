import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsup/Models/Message.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:intl/intl.dart';
import 'package:whatsup/Screens/ContactList.dart';

import 'package:whatsup/Screens/chat.dart';
import 'package:whatsup/Services/Firebase.dart';

class Messages extends StatefulWidget {
  final String id;

  const Messages({Key key, this.id}) : super(key: key);
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Person> friends = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Icon(Icons.message,),onPressed: () => Get.to(() => ContactListPage(id: widget.id,)),),
      body: body());
  }

  Widget body() {
    return Container(
      color: Colors.white,
      child: StreamBuilder(
          stream: Firebase().getChatFriends(widget.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            if (snapshot.data.docs.length == 0)
              return Center(
                child: Text("nf".tr),
              );
            return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),

                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  Person person =
                      Person.producingDoc(snapshot.data.docs[index]);
                  return getuser(person.id);
                });
          }),
    );
  }

  Widget tile(Person person) {
    return StreamBuilder(
        stream: Firebase().getLastMessages(widget.id),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return SizedBox(height: 0,);
          if(snapshot.data.docs.length == 0) return Center(child: Text("No last message"));
          return ListView.separated(
            separatorBuilder: (ctx, i) {
              return Divider(color: Colors.grey);
            },
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.all(0),
            itemCount: 1,
            itemBuilder: (context, index) {
              Message message = Message.producingDoc(snapshot.data.docs[0]);
              String _currentTime =
                  DateFormat('kk:mm').format(message.time.toDate());
              return tilee(person, message, _currentTime);
            },
          );
        });
  }

  Widget getuser(String id) {
    return FutureBuilder(
      future: Firebase().getUser(id),
      builder: (context, snapshot) {
        Person person = snapshot.data;
        if (!snapshot.hasData)
          return SizedBox(height: 0,);
        return tile(person);
      },
    );
  }

  Widget tilee(Person receiver, Message message, String time) {
    return ListTile(
      onTap: () => Get.to(Chat(
        boxowner: receiver,
        owner: widget.id,
      )),
      tileColor: Colors.white,
      leading: CircleAvatar(
        radius: 35,
        backgroundImage: receiver.photo != null
            ? NetworkImage(receiver.photo)
            : AssetImage("assets/nah.png"),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 5),
        child: Text(
          receiver.username,
          style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
      trailing: Text(
        time != null ? time : "",
        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
      ),
      subtitle: message.url == null ? Text(
        message != null
            ? message.receiverId == receiver.id
                ? "Me: " + message.text
                : "${receiver.username}: " + message.text
            : "",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ) : Text("im".tr)
    );
  }
}



