import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient('192.168.31.102', '');
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Screen1(),
        ),
      ),
    );
  }
}

class Screen1 extends StatefulWidget {
  
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  String _message = "";
  connectionMqtt()async{
    client.port = 1883;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnect;
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus.state}');
      client.disconnect();
    }
    final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      // .keepAliveFor(20)
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;


    //create subscribe
    const topic = 'cpe5camp/at99';
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          setState(() {
            _message = pt;
          });
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt-->');
      print('');
    });
  }
    void onConnected(){
    print("......................connected...............");  
  }

  void onDisconnect(){
    connectionMqtt();
  }

  final pubTopic = 'cpe5camp/at99/sftohw';
  sendsftohw(){
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello I am agree');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Distance \n$_message",
          style: TextStyle(
            fontSize: 40.0
          ),
        ),
        RaisedButton(
          onPressed: (){
            connectionMqtt();
          }
        ),
        FlatButton(
          onPressed: (){
            sendsftohw();
          }, 
          child: Container(
            alignment: Alignment.center,
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.all(Radius.circular(100),
              )
            ),
            child: Text(
              "Send",
               style: TextStyle(
                 fontSize: 50,
                 color: Colors.deepPurpleAccent
               ),
            ),
          )
        )
      ],
    );
  }
}