import 'dart:async';
import 'dart:collection';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/components/sample_card.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:ic_scanner/data/storage.dart';
import 'package:ic_scanner/screens/camera.dart';
import 'package:ic_scanner/screens/cropper.dart';
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
  bool searchMode = false;

  late List<Sample> identified;
  late List<Sample> pendings;

  TextEditingController searchController = TextEditingController();

  HashSet<Classification> classFilters = HashSet();

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

    identified = storage.getIdentified();
    pendings = storage.getPendings();
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
                  setState(() {
                    _updateIdentified();
                    _updatePendings();
                  });
                },
              )
            : const Text("IC Scanner"),
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
      body: ListenableBuilder(
          listenable: storage,
          builder: (context, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                if (pendings.isNotEmpty)
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          scanSample: () {
                            final sampleId = pendings[index].id;

                            setState(() {
                              pendings[index].inferring = true;
                            });

                            storage.inferSample(sampleId).then((_) {
                              setState(() {
                                _updatePendings();
                                _updateIdentified();
                              });
                            });
                          },
                          deleteSample: () {
                            setState(() {
                              storage.deleteSample(pendings[index].id);
                              _updatePendings();
                            });
                          });
                    },
                  )
                else
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsFill.dog,
                          color: Colors.white70, size: 64),
                      Text(
                          "There is nothing here, \n looks like we need new dog pics",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, color: Colors.white70))
                    ],
                  ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                          spacing: 8,
                          children: Classification.values
                              .map((c) => FilterChip(
                                    label: Text(c.label),
                                    showCheckmark: true,
                                    selected: classFilters.contains(c),
                                    selectedColor: c.color,
                                    backgroundColor: c.color.withAlpha(128),

                                    // color: MaterialStatePropertyAll(c.color),
                                    onSelected: (isSelected) {
                                      setState(() {
                                        if (isSelected) {
                                          classFilters.add(c);
                                        } else {
                                          classFilters.remove(c);
                                        }

                                        _updateIdentified();
                                        _updatePendings();
                                      });
                                    },
                                  ))
                              .toList(growable: false)),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  storage.deleteSample(identified[index].id);
                                  _updateIdentified();
                                });
                              });
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 32,
          children: [
            FloatingActionButton(
              onPressed: handleOpenImage,
              child: const Icon(
                PhosphorIconsFill.fileArrowUp,
                color: Colors.white,
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraScreen(
                            refreshItems: () => {
                              setState(() {
                                _updatePendings();
                              })
                            },
                          )),
                );
              },
              child: const Icon(
                PhosphorIconsFill.aperture,
                color: Colors.white,
              ),
            ),
            FloatingActionButton(
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
            )
          ],
        ),
      ),
    );
  }

  void _updateIdentified() {
    identified = storage.getIdentified(
        keyword: searchController.value.text, classification: classFilters);
  }

  void _updatePendings() {
    pendings = storage.getPendings(keyword: searchController.value.text);
  }

  void handleOpenImage() {
    FilePicker.platform
        .pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    )
        .then((result) {
      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CropperScreen(
                    label: file.name,
                    image: file.bytes!,
                    refresh: () {
                      setState(() {
                        _updatePendings();
                      });
                    })),
          );
        });

        _tabController.animateTo(0);
      }
    });
  }
}
