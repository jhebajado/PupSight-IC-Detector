import 'package:flutter/material.dart';
import 'package:ic_scanner/components/sample_card.dart';
import 'package:ic_scanner/data/storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final storage = Storage();

    final identified = storage.getIdentified();
    final pendings = storage.getPendings();

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
      body: ListenableBuilder(
          listenable: storage,
          builder: (context, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: pendings.length,
                  itemBuilder: (context, index) {
                    return SampleCard(sample: pendings[index]);
                  },
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: identified.length,
                  itemBuilder: (context, index) {
                    return SampleCard(sample: identified[index]);
                  },
                )
              ],
            );
          }),
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
