import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsup/Models/Person.dart';
import 'package:whatsup/Screens/chat.dart';
import 'package:whatsup/Services/Firebase.dart';
import 'package:get/get.dart';

class ContactListPage extends StatefulWidget {
  final String id;

  const ContactListPage({Key key, this.id}) : super(key: key);
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  List<Person> phones = [];
  List<Person> detected = [];
  int amount = 0;

  @override
  void initState() {
    super.initState();
    _askPermissions(null);
    getAllUsers();
    refreshContacts();
    detect();
  }

  void detect() {
    for (int i = 0; i < _contacts.length; i++) {
      for (int y = 0; y < phones.length; y++) {
        if (_contacts[i].phones.first.value.replaceAll(RegExp(" "), "") ==
            phones[y].number) {
          detected.addIf(!detected.contains(phones[y]), phones[y]);
        }
      }
    }
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: false))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      _contacts = contacts;
      amount = contacts.length;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  void updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  Future<void> getAllUsers() async {
    List<Person> list = await Firebase().getAllUsers();
    setState(() {
      phones = list;
    });
  }

  _openContactForm() async {
    try {
      var contact =
          await ContactsService.openContactForm(iOSLocalizedLabels: false);
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName);
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sc'.tr,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(
                height: 0,
              ),
              Text(phones.length.toString() + ' ' + 'cs'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert_rounded),
              onPressed: () {},
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: phones != null
              ? ListView.builder(
                  itemCount: phones?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    // Contact c = _contacts?.elementAt(index);
                    Person person = phones?.elementAt(index);
                    if (person.id == widget.id)
                      return SizedBox(
                        height: 0,
                      );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /*Tiles().withcirclea(
                              icon: Icons.people_sharp,
                              text: "New group",
                              color: Colors.greenAccent.shade700,
                              iconcolor: Colors.white,
                              weight: FontWeight.w600),
                          Tiles().withcirclea(
                              icon: Icons.person_add,
                              text: "New contact",
                              color: Colors.greenAccent.shade700,
                              iconcolor: Colors.white,
                              weight: FontWeight.w600),*/
                        contact_tile(person),
                        /*    InkWell(
                            child: Tiles().withcirclea(
                                icon: Icons.share,
                                text: "Invite friends",
                                color: Colors.white,
                                iconcolor: Colors.grey,
                                weight: FontWeight.w400),
                          ),
                          Tiles().withcirclea(
                              icon: Icons.help,
                              text: "Contacts help",
                              color: Colors.white,
                              iconcolor: Colors.grey,
                              weight: FontWeight.w400),*/
                      ],
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }

  Widget contact_tile(Person person) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Get.to(Chat(boxowner: person, owner: widget.id));
        },
        /* leading: (contact.avatar != null && contact.avatar.length > 0)
            ? CircleAvatar(
                backgroundImage: MemoryImage(contact.avatar),
                radius: 20,
              )
            : CircleAvatar(radius: 20, child: Text(contact.initials())),*/
        leading: CircleAvatar(
          backgroundImage: NetworkImage(person.photo),
          radius: 35,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              person.username,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              person.about,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
