import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealshare/screens/home_screen.dart';
import 'package:dealshare/screens/redeem_screen.dart';
import 'package:dealshare/screens/saved_deals.dart';
import 'package:dealshare/services/ReceiptData.dart';
import 'package:dealshare/services/database.dart';
import 'package:dealshare/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List userDetails;
  String name = "...";
  String photoURL = "";
  DateTime since;
  String date = "...";
  String points = "...";
  List<ReceiptData> data = [];
  var counter = 0;
  String userClass = "...";


  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    getUserDetails();
    super.initState();
  }

  void getUserDetails() async {
    userDetails = await DatabaseService().getUserDetails();
    name = userDetails[0];
    since = userDetails[1];
    photoURL = userDetails[2];

    await DatabaseService().retrievePoint().then((value) => setState(() {
          points = value;
        }));

    await DatabaseService().retrieveTotalPoint().then((value) => setState(() {
      if (int.parse(value) < 1000) {
        userClass = "Beginner";
      }
      else if (int.parse(value) < 5000) {
        userClass = "Intermediate";
      }
      else {
        userClass = "Expert";
      }
    }));

    setState(() {
      userDetails = userDetails;
      name = name;
      photoURL = photoURL;
      since = since;
      date = formatter.format(since);
      points = points;
    });
  }

  void fetchData() {
    final User user = auth.currentUser;
    final uid = user.uid;
    FirebaseFirestore.instance
        .collection("UserData")
        .doc("$uid")
        .collection("uploaded_receipts")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        ReceiptData receiptdata = ReceiptData.fromMap(doc.data());
        setState(() {
          data.add(receiptdata);
          counter = counter + 1;
        });
      });
      print(counter);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: SizedBox(
          child: Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blueAccent, Colors.cyan])),
                  child: Container(
                    width: double.infinity,
                    height: 28 * SizeConfig.heightMultiplier,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: "$photoURL" != ""
                                ? NetworkImage(
                                    "$photoURL",
                                  )
                                : AssetImage("assets/profilepicture.png"),
                            radius: 8 * SizeConfig.widthMultiplier,
                          ),
                          SizedBox(
                            height: 1 * SizeConfig.heightMultiplier,
                          ),
                          Text(
                            "$name",
                            style: TextStyle(
                              fontSize: 1.7 * SizeConfig.heightMultiplier,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 0.8 * SizeConfig.heightMultiplier,
                          ),
                          Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 2.7 * SizeConfig.widthMultiplier,
                                vertical: 0.7 * SizeConfig.heightMultiplier),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.white,
                            elevation: 5.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1 * SizeConfig.widthMultiplier,
                                  vertical: 1.7 * SizeConfig.heightMultiplier),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Member Since",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              0.4 * SizeConfig.heightMultiplier,
                                        ),
                                        Text(
                                          "$date",
                                          style: TextStyle(
                                            //fontSize: 20.0,
                                            color: Colors.cyan,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "Current Points",
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              //fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                0.4 * SizeConfig.heightMultiplier,
                                          ),
                                          Text(
                                            "$points",
                                            style: TextStyle(
                                              //fontSize: 20.0,
                                              color: Colors.cyan,
                                            ),
                                          )
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Redeempage()),
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Class",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            //fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              0.4 * SizeConfig.heightMultiplier,
                                        ),
                                        Text(
                                          userClass,
                                          style: TextStyle(
                                            //fontSize: 20.0,
                                            color: Colors.cyan,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 2.4 * SizeConfig.heightMultiplier,
                    horizontal: 2.2 * SizeConfig.widthMultiplier),
                child: data.length>0?Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Text(
                      "My Activity",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontStyle: FontStyle.normal,
                        fontSize: 2.2 * SizeConfig.heightMultiplier,
                      ),
                    ),
                    SizedBox(
                      height: 0.8 * SizeConfig.heightMultiplier,
                    ),
                    SizedBox(
                      height: (MediaQuery.of(context).size.height) / 2,

                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: counter,
                        itemBuilder: (BuildContext context, int index) {
                          return SingleChildScrollView(
                            child: GestureDetector(
                              onTap: () {
                                String uploaded = data[index].uploaded;

                                showDialog(
                                    context: context,
                                    builder: (_) => AssetGiffyDialog(
                                      image: Image.network(
                                         data[index].url
                                      ),
                                      title: Text(
                                        'Redeemed on $uploaded',
                                        style: TextStyle(
                                            fontSize: 1.8*SizeConfig.textMultiplier, fontWeight: FontWeight.w600),
                                      ),
                                      description: Text(
                                        'Deal: '+data[index].title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 1.3*SizeConfig.textMultiplier,
                                        ),
                                      ),
                                      entryAnimation: EntryAnimation.BOTTOM_RIGHT,
                                      buttonCancelColor: Colors.cyan,
                                      buttonCancelText: Text("OK"),
                                      onlyCancelButton: true,
                                      // onOkButtonPressed: () {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(builder: (context) => AddReceipt()),
                                      //   );
                                      // },
                                    ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withAlpha(100), blurRadius: 10.0),
                                    ]),
                                height: 100,
                                child:
                                    Center(child: FittedBox(child: Text(data.length!=null?"Redeemed "+data[index].title:""))),

                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      ),
                    ),
                    SizedBox(height: 1.6 * SizeConfig.heightMultiplier),
                  ],
                ):FittedBox(child: Text("No recent activity , redeem a deal to earn extra points !")),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        backgroundColor: Colors.cyan,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.portrait),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (_selectedIndex) {
          switch (_selectedIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedDeals()),
              );
          }
        },
      ),
    );
  }
}
