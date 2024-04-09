import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/api.dart';
import 'package:ic_scanner/components/sample_card.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:ic_scanner/screens/camera.dart';
import 'package:ic_scanner/screens/cropper.dart';
import 'package:ic_scanner/screens/preview.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  bool deleteMode = false;
  bool searchMode = false;

  late List<Sample> identified = List.empty();
  late List<Sample> pendings = List.empty();

  TextEditingController searchController = TextEditingController();

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

    getInferred(null).then((value) {
      setState(() {
        identified = value;
      });
    });

    getPendings(null).then((value) {
      setState(() {
        pendings = value;
      });
    });
  }

  void openPreview(Sample sample, VoidCallback deleteSample) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return SamplePreview(
        sample: sample,
        deleteSample: deleteSample,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchMode
            ? SearchBar(
                controller: searchController,
                hintText: "Search",
                onChanged: (_) {
                  _updateIdentified();
                  _updatePendings();
                },
              )
            : const Text("Pupsight"),
        centerTitle: true,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    searchMode = !searchMode;

                    if (!searchMode) {
                      setState(() {
                        searchController.clear();
                        _updatePendings();
                        _updateIdentified();
                      });
                    }
                  });
                },
                icon: Icon(searchMode
                    ? PhosphorIconsBold.prohibit
                    : PhosphorIconsFill.binoculars)),
          )
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
          if (pendings.isNotEmpty)
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
                    openPreview: () => openPreview(pendings[index], () {
                          deleteSample(pendings[index].id).whenComplete(() {
                            _updatePendings();
                            _updateIdentified();
                          });
                        }),
                    scanSample: () {
                      setState(() {
                        pendings[index].inferring = true;
                      });

                      inferSample(pendings[index].id).whenComplete(() {
                        _updatePendings();
                        _updateIdentified();
                      });
                    },
                    deleteSample: () {
                      deleteSample(pendings[index].id).whenComplete(() {
                        _updatePendings();
                        _updateIdentified();
                      });
                    });
              },
            )
          else
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsFill.dog, color: Colors.white70, size: 64),
                Text(
                    "There is nothing here, \n looks like we need new dog pics",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.white70))
              ],
            ),
          Column(
            children: [
              Expanded(
                child: GridView.builder(
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
                        openPreview: () => openPreview(identified[index], () {
                              deleteSample(identified[index].id)
                                  .whenComplete(() {
                                _updatePendings();
                                _updateIdentified();
                              });
                            }),
                        deleteSample: () {
                          deleteSample(identified[index].id).whenComplete(() {
                            _updatePendings();
                            _updateIdentified();
                          });
                        });
                  },
                ),
              ),
            ],
          )
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 32,
          children: [
            IconButton(
              onPressed: () => handleOpenImage(),
              icon: const Icon(
                PhosphorIconsFill.fileArrowUp,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraScreen(
                            refreshItems: () {
                              _updatePendings();
                            },
                          )),
                );
              },
              icon: const Icon(
                PhosphorIconsFill.aperture,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  deleteMode = !deleteMode;
                });
              },
              color: deleteMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.error,
              icon: Icon(
                deleteMode
                    ? PhosphorIconsFill.prohibit
                    : PhosphorIconsFill.trash,
                color: deleteMode
                    ? Theme.of(context).colorScheme.error
                    : Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateIdentified() {
    getInferred(searchController.value.text).then((value) {
      setState(() {
        identified = value;
      });
    });
  }

  void _updatePendings() {
    getPendings(searchController.value.text).then((value) {
      setState(() {
        pendings = value;
      });
    });
  }

  void handleOpenImage() {
    FilePicker.platform
        .pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    )
        .then((result) async {
      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropperScreen(
                image: file.bytes!,
                label: file.name,
                refresh: () {
                  _updatePendings();
                  _tabController.animateTo(0);
                }),
          ),
        );
      }
    });
  }
}
