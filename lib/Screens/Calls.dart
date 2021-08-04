import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:whatsup/Models/Call.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Screens/ContactList.dart';
import 'package:whatsup/Services/Firebase.dart';

class Calls extends StatefulWidget {
  final String id;

  const Calls({Key key, this.id}) : super(key: key);
  @override
  _CallsState createState() => _CallsState();
}

class _CallsState extends State<Calls> {
  bool selected = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.teal,
            child: Icon(
              Icons.add_call,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(ContactListPage(id: widget.id,));
            },
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () async {
              await Firebase()
                  .deleteCalls(widget.id)
                  .whenComplete(() => Get.snackbar(
                        "deleting".tr,
                        "all_delete".tr,
                        backgroundColor: Colors.red.shade800,
                colorText: Colors.white                      ));
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: Firebase().getCalls(widget.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return SizedBox(
                height: 0,
              );
            if (snapshot.data.docs.length == 0)
              return Center(
                child: Text("call_box".tr),
              );
            return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Call c = Call.producingDoc(snapshot.data.docs[index]);

                return FutureBuilder(
                  future: widget.id == c.caller
                      ? Firebase().getUser(c.opener)
                      : Firebase().getUser(c.caller),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return SizedBox(
                        height: 0,
                      );
                    Person person = snapshot.data;
                    String _currentTime =
                        DateFormat('kk:mm').format(c.time.toDate());
                    String type = c.type;
                    String whocaller;
                    widget.id == c.caller
                        ? whocaller = 'me'
                        : whocaller = 'oppo';
                    return tile(_currentTime, person, type, whocaller);
                  },
                );
              },
            );
          }),
    );
  }

  Widget tile(String time, Person person, String type, whocaller) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListTile(
        onLongPress: () {
          setState(() {
            selected = true;
          });
        },
        leading: selected == false
            ? CircleAvatar(
                radius: 30,
                backgroundImage: person.photo != null
                    ? NetworkImage(person.photo)
                    : AssetImage("assets/nah.png"),
              )
            : IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  setState(() {
                    selected = false;
                  });
                },
              ),
        title: Text(
          person.username,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                whocaller == 'me' ? Icons.call_made : Icons.call_received,
                color: Colors.green,
                size: 15,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                time,
              )
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            type == "audio" ? Icons.call : Icons.videocam,
            color: Colors.grey.shade600,
            size: 22,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
