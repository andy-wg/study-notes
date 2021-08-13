import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/pubsub_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(title: Text('ion flutter examples')),
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                  onPressed: () {
                    Get.to(PubSubTestView(), transition: Transition.rightToLeft);
                  },
                  child: Text('Pub/Sub (ion-sfu)')),
            ],
          )));
}
