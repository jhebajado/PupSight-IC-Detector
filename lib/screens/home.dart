import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/components/sample_card.dart';
import 'package:ic_scanner/data/storage.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final storage = Storage();
  bool deleteMode = false;

  static final List<Tab> _tabs = <Tab>[
    const Tab(
      text: "Pending",
      icon: Icon(PhosphorIconsFill.imagesSquare),
    ),
    const Tab(
      text: "Identified",
      icon: Icon(PhosphorIconsFill.target),
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
    final identified = storage.getIdentified();
    final pendings = storage.getPendings();

    return Scaffold(
      appBar: AppBar(
        title: const Text("IC Scanner"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(PhosphorIconsFill.binoculars))
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
                    return SampleCard(
                        sample: pendings[index],
                        showDelete: deleteMode,
                        deleteSample: () {
                          setState(() {
                            storage.deleteSample(pendings[index].id);
                          });
                        });
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
                    return SampleCard(
                        sample: identified[index],
                        showDelete: deleteMode,
                        deleteSample: () {
                          setState(() {
                            storage.deleteSample(pendings[index].id);
                          });
                        });
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
              onPressed: handleOpenImage,
              child: const Icon(
                PhosphorIconsFill.fileArrowUp,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(
                PhosphorIconsFill.aperture,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  deleteMode = !deleteMode;
                });
              },
              backgroundColor: deleteMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.error,
              child: Icon(
                deleteMode
                    ? PhosphorIconsFill.prohibit
                    : PhosphorIconsFill.trash,
                color: deleteMode
                    ? Theme.of(context).colorScheme.error
                    : Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleOpenImage() {
    FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.image,
        allowedExtensions: ["jpg", "png"]).then((result) {
      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        setState(() {
          storage.addSample(file.name, file.bytes!);
        });

        _tabController.animateTo(0);
      }
    });
  }
}
