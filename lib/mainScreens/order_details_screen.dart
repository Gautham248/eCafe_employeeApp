import 'package:canteen_management_employee/mainScreens/home_screen.dart';
import 'package:canteen_management_employee/mainScreens/parcel_picking_screen.dart';
import 'package:canteen_management_employee/mainScreens/shipment_screen.dart';
import 'package:canteen_management_employee/models/address.dart';
import 'package:canteen_management_employee/splashScreen/splash_screen.dart';
import 'package:canteen_management_employee/widgets/shipment_address_design.dart';
import 'package:canteen_management_employee/widgets/status_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:canteen_management_employee/global/global.dart';
// import 'package:canteen_management_user/models/address.dart';
import 'package:canteen_management_employee/widgets/progress_bar.dart';
// import 'package:canteen_management_user/widgets/shipment_address_design.dart';

import 'package:intl/intl.dart';


class OrderDetailsScreen extends StatefulWidget
{
  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}




class _OrderDetailsScreenState extends State<OrderDetailsScreen>
{
  String orderByUser = "";
  String orderStatus = "";
  String sellerId = "";

  getOrderInfo()
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID).get().then((DocumentSnapshot)
    {
      orderStatus = DocumentSnapshot.data()!["status"].toString();
      orderByUser = DocumentSnapshot.data()!["orderBy"].toString();
      sellerId=DocumentSnapshot.data()!["sellerUID"].toString();
    });
  }

  @override
  void initState() {
    super.initState();

    getOrderInfo();
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (c, snapshot)
          {
            Map? dataMap;
            if(snapshot.hasData)
            {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
              child: Column(
                children: [
                  StatusBanner(
                    status: dataMap!["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "₹  " + dataMap["totalAmount"].toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Order Id = " + widget.orderID!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Order at: " +
                          DateFormat("dd MMMM, yyyy - hh:mm aa")
                              .format(DateTime.fromMillisecondsSinceEpoch(int.parse(dataMap["orderTime"]))),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const Divider(thickness: 4,),
                  orderStatus == "ended"
                      ? Image.asset("images/success.jpg")
                      : Image.asset("images/confirm_pick.png"),
                  const Divider(thickness: 4,),


                  orderStatus == "ended"
                      ? Container()
                      : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: InkWell(
                        onTap: ()
                        {
                         // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                           confirmedParcelShipment(context, widget.orderID! , sellerId!, orderByUser!);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan,
                                  Colors.amber,
                                ],
                                begin:  FractionalOffset(0.0, 0.0),
                                end:  FractionalOffset(1.0, 0.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp,
                              )
                          ),
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: const Center(
                            child: Text(
                              "Confirm - To Deliver this Parcel",
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: InkWell(
                        onTap: ()
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan,
                                  Colors.amber,
                                ],
                                begin:  FractionalOffset(0.0, 0.0),
                                end:  FractionalOffset(1.0, 0.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp,
                              )
                          ),
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: const Center(
                            child: Text(
                              "Go Back",
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  // FutureBuilder<DocumentSnapshot>(
                  //   future: FirebaseFirestore.instance
                  //       .collection("users")
                  //       .doc(sharedPreferences!.getString("uid"))
                  //       .collection("userAddress")
                  //       .doc(dataMap["addressID"])
                  //       .get(),
                  //   builder: (c, snapshot)
                  //   {
                  //     return snapshot.hasData
                  //         ? ShipmentAddressDesign(
                  //             model: Address.fromJson(
                  //               snapshot.data!.data()! as Map<String, dynamic>
                  //             ),
                  //           )
                  //         : Center(child: circularProgress(),);
                  //   },
                  // ),
                ],
              ),
            )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}


confirmedParcelShipment(BuildContext context, String getOrderID, String sellerId, String purchaserId)
{
  FirebaseFirestore.instance
      .collection("orders")
      .doc(getOrderID)
      .update({
    "riderUID": sharedPreferences!.getString("uid"),
    "riderName": sharedPreferences!.getString("name"),
    "status": "picking",
    // "lat": position!.latitude,
    // "lng": position!.longitude,
    // "address": completeAddress,
  });

  //send rider to shipmentScreen
  Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
    purchaserId: purchaserId,
    // purchaserAddress: model!.fullAddress,
    // purchaserLat: model!.lat,
    // purchaserLng: model!.lng,
    sellerId: sellerId,
    getOrderID: getOrderID,
  )));
}

