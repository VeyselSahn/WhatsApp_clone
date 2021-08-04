import 'package:flutter/material.dart';

class Tiles {
  Widget withcirclea({IconData icon,String text,Color color,iconcolor,FontWeight weight}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(
          icon,
          color: iconcolor,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 15,fontWeight: weight),
      ),
    );
  }

}
