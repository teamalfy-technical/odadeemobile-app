import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;





class NotificationsActionsManager {
  static NotificationsActionsManager? instance;
  late BuildContext _ctx;

  NotificationsActionsManager(BuildContext ctx) {
    _ctx = ctx;
  }
  static getInstance(BuildContext ctx) {
    instance ??= NotificationsActionsManager(ctx);

    return instance;
  }

  Future performActionOnly(String? action) => performAction(varag: {"action": action});

  Future performAction({required Map<String, dynamic> varag}) async {
    log("varag:$varag");
    final action = varag['type'] ?? 'none';
    final payload = varag['payload'] ?? null;
    log("payloadpayload:$payload");
    var decodedPayload;
    try{
        decodedPayload  = payload;
    }catch(e){
      log("error message:${e.toString()}");
    }


    debugPrint("Perform Action ==> $action");
    debugPrint("Perform Action decodedPayload ==> ${decodedPayload}");

    //Todo replace param varag with entity value from api



    switch (action) {
      case NotificationActions.registration:
      default:
        break;

    }
  }

}

class NotificationActions {
  static const registration = "registration";
}
class NotificationTypes {
  static const general = 'general';
}

