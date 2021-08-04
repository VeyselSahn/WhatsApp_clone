import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Screens/Calls.dart';
import 'package:whatsup/Screens/Instant.dart';
import 'package:whatsup/Screens/Messages.dart';
import 'package:whatsup/Screens/Userinfos.dart';
import 'package:whatsup/Services/Auth.dart';
import 'package:whatsup/Services/Firebase.dart';

class Mainpage extends StatefulWidget {
  final String id;
  
  const Mainpage({Key key, this.id})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final List<String> listItems = [];
  var bar = 0;
  Person owner;
  List<String> choices = <String>[
    'new_group'.tr,
    'new_broad'.tr,
    'WhatsApp Web',
    'starred'.tr,
    'settings'.tr
  ];
  final List<String> _tabs = <String>[
    "chats".tr,
    "status".tr,
    "calls".tr,
  ];

  @override
  void initState() {
    super.initState();
    getOwner();
  }

  Future<void> getOwner() async {
    Person temp = await Firebase().getUser(widget.id);
    setState(() {
      owner = temp;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverSafeArea(
                  top: false,
                  sliver: SliverAppBar(
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
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
                    title: InkWell(
                      onLongPress: () =>
                        AuthService().signOut(),
                      child: const Text('WhatsUp')),
                    floating: true,
                    pinned: true,
                    snap: false,
                    primary: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      isScrollable: false,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      indicatorWeight: 3.5,
                      tabs: _tabs
                          .map((String name) => Tab(
                                text: name,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(children: [
            Messages(
              id: widget.id,
            ),
            Instant(owner: widget.id),
            Calls(id: widget.id,)
          ]),
        ),
      ),
    ));
  }

  void choiceAction(String choice) {
    if (choice == 'Settings' || choice == 'Ayarlar') {
      Get.to(Userinfos(user: widget.id));
    } else if (choice == 'Subscribe') {
      print('Subscribe');
    } else if (choice == 'Back') {
      print('Back');
    }
  }
}
