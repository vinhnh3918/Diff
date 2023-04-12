
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MyApp());
}

class AssetData {
  final String id;
  final String name;
  final double priceUsd;

  AssetData({required this.id, required this.name, required this.priceUsd});

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      id: json['id'],
      name: json['name'],
      priceUsd: json['priceUsd'] != null ? double.parse(json['priceUsd']) : 0.0,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const AssetScreen(),
    );
  }
}

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});
  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  List<AssetData> _assets = [];
  final int _limit = 15;
  int _offset = 0;
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    _offset = 0;
    final response = await http.get(Uri.parse('https://api.coincap.io/v2/assets?limit=$_limit'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        _assets = data.map<AssetData>((json) => AssetData.fromJson(json)).toList();
      });
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  Future<void> _loadMoreAssets() async {
    _offset += _limit;
    final response = await http.get(Uri.parse('https://api.coincap.io/v2/assets?limit=$_limit&offset=$_offset'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        _assets.addAll(data.map<AssetData>((json) => AssetData.fromJson(json)).toList());
      });
      _refreshController.loadComplete();
    } else {
      _refreshController.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropMaterialHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator();
            } else {
              body = const SizedBox();
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        onRefresh: _loadAssets,
        onLoading: _loadMoreAssets,
        child: ListView.builder(
          itemCount: _assets.length,
          itemBuilder: (context, index) {
            final asset = _assets[index];
            return ListTile(
              title: Text('$index. ${asset.name}'),
              subtitle: Text('\$${asset.priceUsd.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}

