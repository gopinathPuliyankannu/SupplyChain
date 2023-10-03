import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class LineageEvent {
  final String id;
  final String event;
  final Map<String, dynamic> eventDetail;
  final int timestamp;
  final String previous;

  LineageEvent({
    required this.id,
    required this.event,
    required this.eventDetail,
    required this.timestamp,
    required this.previous,
  });

  factory LineageEvent.fromJson(Map<String, dynamic> json) {
    return LineageEvent(
      id: json['id'] ?? "",
      event: json['event'],
      eventDetail: json['event-detail'],
      timestamp: json['timestamp'],
      previous: json['previous'] ?? "",
    );
  }

  String formatDate() {
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM.dd').format(dateTime);
  }

  String formatTime() {
    final DateTime dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat().add_jm().format(dateTime);
  }
}

class ProductDetails {
  final String sku;
  final String upc;
  final String description;
  final List<LineageEvent> lineage;

  ProductDetails({
    required this.sku,
    required this.upc,
    required this.description,
    required this.lineage,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    List<LineageEvent> events = List<LineageEvent>.from(
        json['lineage'].map((eventJson) => LineageEvent.fromJson(eventJson)));
    return ProductDetails(
      sku: json['sku'],
      upc: json['upc'],
      description: json['description'],
      lineage: events,
    );
  }
}

class qrlist extends StatefulWidget {
  final url;

  const qrlist({Key? key, required this.url}) : super(key: key);

  @override
  State<qrlist> createState() => _qrlistState();
}

class _qrlistState extends State<qrlist> with SingleTickerProviderStateMixin {
  ProductDetails? _productDetails;
  final eventDetails = [];
  bool Loader = true;

  @override
  void initState() {
    super.initState();
  }

  setLoader(status) {
    setState(() {
      Loader = status;
    });
  }

  Future<ProductDetails?> loadProductDetails() async {
    try {

      var uri = Uri.parse(widget.url);
      final urlEncode = Uri.parse('http://ec2-13-53-122-33.eu-north-1.compute.amazonaws.com/api/supplychain/0001111003023/${uri.queryParameters['param']}');
      // final urlEncode = Uri.parse(widget.url);
      // final urlEncode = Uri.parse(
      //     'http://ec2-13-53-122-33.eu-north-1.compute.amazonaws.com/api/supplychain/0001111003023/3');
      // Uri.parse('http://13.53.122.33/api/supplychain/0001111003023/2');
      print(urlEncode);
      final response = await get(urlEncode);
      debugPrint("response $response.body");
      final String jsonString = response.body;
      // await rootBundle.loadString('assets/images/static.json');
      print('Loaded JSON String: $jsonString');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('Decoded JSON Data: $jsonData');
      // setLoader(false);
      return ProductDetails.fromJson(jsonData);
    } catch (e) {
      setLoader(false);
      print("catch statement $e");
    }
    return null;
  }

  generageColumn(stringvalue, value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "${stringvalue.toString().toUpperCase()}:",
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Flexible(
              child: Text(
                defaultValue(value),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  RawMaterials(details, fields, id, previous) {
    return Container(
      child: Column(
        children: [
          generageColumn('id', id),
          for (int i = 0; i < fields.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "${fields[i].toString().toUpperCase()}:",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        defaultValue(details[fields[i]]),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          generageColumn('previous', previous),
        ],
      ),
    );
  }

  getValues(eventFields, value) {
    switch (value) {
      case 'flavor':
        return defaultValue(eventFields[value]['trype']);
      case 'preservative':
        return defaultValue(eventFields[value]['item']);
      default:
        return defaultValue(eventFields[value]['type']);
    }
  }

  ProcessingEvents(details, id, previous) {
    final fields = ['plant-id', 'slice-type', 'cooking-type'];
    final ingrediants = ['salt', 'flavor', 'oil', 'preservative'];

    return Container(
      child: Column(
        children: [
          generageColumn('id', id),
          for (int i = 0; i < fields.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "${fields[i].toString().toUpperCase()}:",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        details[fields[i]] == null
                            ? "NA"
                            : details[fields[i]].toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          for (int j = 0; j < ingrediants.length; j++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "${ingrediants[j].toString().toUpperCase()}:",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        getValues(
                            details['additional-ingredients'], ingrediants[j]),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          generageColumn('previous', previous),
        ],
      ),
    );
  }

  defaultValue(data) {
    return data == null || data == "<date>" || data == ""
        ? "NA"
        : data.toString();
  }

  preProcessing(details, id, previous) {
    final fields = ['plant-id'];
    final ingrediants = ['steps'];

    return Container(
      child: Column(
        children: [
          generageColumn('id', id),
          for (int i = 0; i < fields.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "${fields[i].toString().toUpperCase()}:",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        defaultValue(details[fields[i]]),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          for (int j = 0; j < details['steps'].length; j++)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        j == 0 ? "steps:".toString().toUpperCase() : "",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        defaultValue(details['steps'][j]),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          generageColumn('previous', previous),
        ],
      ),
    );
  }

  selectEventDetails(details, events, id, previous) {
    switch (events) {
      case "QC and Packaging":
        return RawMaterials(
            details,
            [
              'organic-farm',
              'lot-id',
              'packed-date',
              'expiry-date',
              "qc-authority",
              "qc-stamp-id",
              "qc-status"
            ],
            id,
            previous);
        break;
      case "Processing":
        return ProcessingEvents(details, id, previous);
        break;
      case "Pre-Processing":
        return preProcessing(details, id, previous);
        break;
      case "Harvesting":
        return RawMaterials(
            details,
            [
              'farm',
              'farm-owner',
              'farm-location',
              "certificate-authority",
              "certificate-expiry",
              "certification-no",
              "crop-variety",
              "harvesting-slot",
              "organic-farm"
            ],
            id,
            previous);
        break;
      default:
        return RawMaterials(
            details,
            ['from', 'to', 'transporter', "vehicle-id", "operated-by"],
            id,
            previous);
    }
  }

  // late final List<Item> items;
  @override
  Widget build(BuildContext context) {
    Future<void> _dialogBuilder(details, events, description, id, previous) {
      print("stirng $details");
      print("events $events");
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                          fontSize: 18.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        events,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                )),
              ),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 1.5,
                  margin: const EdgeInsets.only(top: 30.0),
                  child: selectEventDetails(details, events, id, previous),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                // style: TextButton.styleFrom(
                //   textStyle: Theme.of(context).textTheme.labelLarge,
                // ),
                child: const Center(
                    child: Text(
                  'Ok',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue),
                )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    addedIcons(totalCount, count, details, events, description, id, previous) {
      return InkWell(
        onTap: () {
          _dialogBuilder(details, events, description, id, previous);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:   Image.asset(
                  "assets/images/block_blue.png",
                  height: 50.0,width: 50.0
              ),
              // child: Container(
              //   width: 18.0,
              //   height: 18.0,
              //   decoration: BoxDecoration(
              //     // color: Colors.green.withOpacity(0.25), // border color
              //     shape: BoxShape.circle,
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.all(2), // border width
              //     child: Container( // or ClipRRect if you need to clip the content
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.blue, // inner circle color
              //       ),
              //       child: Container(), // inner content
              //     ),
              //   ),
              // ),
            ),
            totalCount != count + 1?
            const SizedBox(
            height: 100,
            child: VerticalDivider(
              thickness: 2,
              width: 20,
              color: Color.fromRGBO(187, 222, 251, 1) ,
              // color: Color.fromRGBO(0, 0, 0, 1) ,
            ),
          ) : const Text(' '),
            // SvgPicture.asset(
            //   "assets/images/blockchain.svg",
            //   height: 70,
            //   width: 50,
            // ),
            // totalCount != count + 1
            //     ? SvgPicture.asset(
            //         "assets/images/downArrow.svg",
            //         height: 50,
            //         width: 20,
            //       )
            //     : const Text(' '),
          ],
        ),
      );
    }

    Widget blockChain() {
      return SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<ProductDetails?>(
                future: loadProductDetails(),
                builder: (context, AsyncSnapshot<ProductDetails?> snapshot) {

                  if (snapshot.hasData) {
                    final product = snapshot.data;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                          top: 20, left: 8.0, bottom: 40.0, right: 8.0),
                          child: Text(product?.description ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          )),
                        ),
                        for (int i = 0; i < product!.lineage.length; i++)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25.0,top:15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      product.lineage[i].formatDate(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 12.0,color: Color(0xFF9AA2AD)),
                                    ),
                                    Text(
                                      product.lineage[i].formatTime(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(fontSize: 10.0,color: Color(0xFF9AA2AD)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0),
                                child: addedIcons(
                                    product.lineage.length,
                                    i,
                                    product.lineage[i].eventDetail,
                                    product.lineage[i].event,
                                    product.description,
                                    product.lineage[i].id,
                                    product.lineage[i].previous),
                              ),
                              Row(
                                children: [
                                  // Image.asset(
                                  //   "assets/images/${product.lineage[i].event}.png",
                                  //   height: 35.0,width: 35.0
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:15.0,top:15.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width/3,
                                      child: Text(
                                          defaultValue(product.lineage[i].event),
                                          maxLines: 3,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.normal,

                                          )),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        // product!.lineage[i]!.event
                        // Text(product!.lineage[i].event)
                      ],
                    );
                  }
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Center(
                            child: Loader
                                ? const CircularProgressIndicator()
                                : const Text(
                                    "No Item in the list",
                                    style: TextStyle(fontSize: 20.0),
                                  ))),
                  );
                })
          ],
        ),
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: const Center(
              child: Text(
            'EEB - Supply Chain Trace',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
        ),
        body: blockChain());
  }
}
