import 'package:flutter/material.dart';

import './entry_edit.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Vyapar"),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: "Add new Entry",
                  icon: Icon(Icons.create),
                ),
                Tab(
                  text: "View Entries",
                  icon: Icon(Icons.list),
                ),
                Tab(text: "Update Entry", icon: Icon(Icons.update))
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              EntryEditPage(),
              Container(
                child: Center(
                  child: Text("Hii"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Hii"),
                ),
              )
            ],
          ),
        ));
  }
}
