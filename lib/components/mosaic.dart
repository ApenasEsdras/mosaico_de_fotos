// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:screenshot/screenshot.dart';

class Mosaic extends StatefulWidget {
  final List<File> images;
  final ScreenshotController screenshotController;

  const Mosaic({
    super.key,
    required this.images,
    required this.screenshotController,
  });

  @override
  State<Mosaic> createState() => _MosaicState();
}

class _MosaicState extends State<Mosaic> {
  int manualCrossAxisCount = 2;
  final int defaultColumns = 2;
  bool selectionMode = false;
  Set<int> selectedIndices = {};

  void _removeSelectedImages() {
    if (selectedIndices.isEmpty) return;

    final removedFiles =
        selectedIndices.map((index) => widget.images[index]).toList();
    setState(() {
      final sortedIndices =
          selectedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (var index in sortedIndices) {
        widget.images.removeAt(index);
      }
      selectedIndices.clear();
      selectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${removedFiles.length} ${removedFiles.length == 1 ? 'foto removida' : 'fotos removidas'}",
        ),
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              widget.images.addAll(removedFiles);
            });
          },
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
        if (selectedIndices.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedIndices.add(index);
        selectionMode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Center(child: Text("Tire fotos para adicionar ao mosaico"));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 0.0;
    final crossAxisCount = manualCrossAxisCount;
    final totalSpacing = (crossAxisCount - 1) * spacing;
    final itemWidth = (screenWidth - totalSpacing) / crossAxisCount;

    return Column(
      children: [
        if (selectionMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedIndices.length} selecionada(s)',
                  style: const TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: _removeSelectedImages,
                      tooltip: 'Remover selecionadas',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          selectedIndices.clear();
                          selectionMode = false;
                        });
                      },
                      tooltip: 'Cancelar seleção',
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: Screenshot(
            controller: widget.screenshotController,
            child: MasonryGridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final file = widget.images[index];
                return GestureDetector(
                  onLongPress: () {
                    _toggleSelection(index);
                  },
                  onTap: () {
                    if (selectionMode) {
                      _toggleSelection(index);
                    } else {
                      _openPhotoView(context, file);
                    }
                  },
                  child: Stack(
                    children: [
                      FutureBuilder<Size>(
                        future: _getImageSize(file),
                        builder: (context, snapshot) {
                          double height = itemWidth;
                          if (snapshot.hasData) {
                            final size = snapshot.data!;
                            height = itemWidth * (size.height / size.width);
                          }
                          return SizedBox(
                            width: itemWidth,
                            height: height,
                            child: Image.file(file, fit: BoxFit.cover),
                          );
                        },
                      ),
                      if (selectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  selectedIndices.contains(index)
                                      ? Colors.blueAccent
                                      : Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Icon(
                              selectedIndices.contains(index)
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              color:
                                  selectedIndices.contains(index)
                                      ? Colors.white
                                      : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text("Grade"),
              Expanded(
                child: Slider(
                  value: manualCrossAxisCount.toDouble(),
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: manualCrossAxisCount.toString(),
                  onChanged: (val) {
                    setState(() {
                      manualCrossAxisCount = val.round();
                    });
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    manualCrossAxisCount = defaultColumns;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text("Redefinir ($defaultColumns)"),
              ),
              if (!selectionMode)
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      selectionMode = true;
                    });
                  },
                  tooltip: 'Selecionar fotos',
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _openPhotoView(BuildContext context, File file) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (_, __, ___) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: PhotoView(
                  imageProvider: FileImage(file),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  enableRotation: true,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<Size> _getImageSize(File file) async {
    final decoded = await decodeImageFromList(await file.readAsBytes());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
