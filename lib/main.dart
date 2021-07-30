import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Formatter {
  final String contract_name;
  final String contract_address;
  final double quote_rate;

  Formatter({
    required this.contract_name,
    required this.contract_address,
    required this.quote_rate,
  });

  factory Formatter.fromJson(Map<String, dynamic> json) {
    return Formatter(
      contract_name: json['contract_name'],
      contract_address: json['contract_address'],
      quote_rate: json['quote_rate'],
    );
  }
}

Future<Formatter> fetchFormatter() async {
  final response = await http.get(Uri.parse(
      'https://api.covalenthq.com/v1/pricing/tickers/?tickers=wbtc&key=YourApiKeyHere'));

  if (response.statusCode == 200) {
    var deep = jsonDecode(response.body)['data'];
    var deeper = deep['items'];
    var wbtc = deeper[0];
    return Formatter.fromJson(wbtc);
  } else {
    throw Exception('No internet or something...');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Formatter> futureFormatter;

  @override
  void initState() {
    super.initState();
    futureFormatter = fetchFormatter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WBTC Price',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WBTC Price'),
        ),
        body: Center(
          child: FutureBuilder<Formatter>(
            future: futureFormatter,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  "contract name: " +
                      snapshot.data!.contract_name +
                      "\n" +
                      "contract address: " +
                      snapshot.data!.contract_address +
                      "\n" +
                      "price: " +
                      snapshot.data!.quote_rate.toString(),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
