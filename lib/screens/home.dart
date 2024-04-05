import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ic_scanner/components/sample_card.dart';
import 'package:ic_scanner/data/sample.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  List<Sample> samples = [];

  static final List<Tab> _tabs = <Tab>[
    const Tab(
      text: "Pending",
      icon: Icon(Icons.pending_actions_rounded),
    ),
    const Tab(
      text: "Identified",
      icon: Icon(Icons.location_searching_rounded),
    )
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    initLocalStorage();
  }

  Future<void> initLocalStorage() async {
    Uri myUri = Uri.parse("/home/ferrox/Pictures/New Folder (2)/normal4.jpg");
    File image = File.fromUri(myUri);
    Uint8List bytes = await image.readAsBytes();

    setState(() {
      samples.add(Sample(label: "Super eyes", bytes: bytes, results: [
        Result(
            classification: Classification.hypermature,
            x: 128,
            y: 128,
            width: 328,
            height: 264)
      ]));
      samples.add(Sample(label: "Super eyes1", bytes: bytes, results: [
        Result(
            classification: Classification.normal,
            x: 128,
            y: 128,
            width: 328,
            height: 264)
      ]));
      samples.add(
          Sample(label: "Super eyes2", bytes: bytes, inferring: true, results: [
        Result(
            classification: Classification.mature,
            x: 128,
            y: 128,
            width: 328,
            height: 264),
        Result(
            classification: Classification.incipient,
            x: 180,
            y: 96,
            width: 328,
            height: 264)
      ]));
      samples.add(Sample(label: "Super eyes2", bytes: bytes, results: [
        Result(
            classification: Classification.incipient,
            x: 128,
            y: 128,
            width: 328,
            height: 264)
      ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IC Scanner"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          dividerHeight: 0,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1,
            ),
            itemCount: samples.length,
            itemBuilder: (context, index) {
              return SampleCard(sample: samples[index]);
            },
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1,
            ),
            itemCount: samples.length,
            itemBuilder: (context, index) {
              return SampleCard(sample: samples[index]);
            },
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(
                Icons.upload_rounded,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(
                Icons.camera,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.error,
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
