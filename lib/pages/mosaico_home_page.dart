// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosaico_teste/components/mosaic.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class MosaicoPage extends StatefulWidget {
  const MosaicoPage({super.key});

  @override
  State<MosaicoPage> createState() => _MosaicoPageState();
}

class _MosaicoPageState extends State<MosaicoPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  Future<void> _saveMosaicAsPDF() async {
    try {
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) return;

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/mosaico_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF salvo em: $path')));

      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mosaico Fotos PDF')),
      body: Column(
        children: [
          Expanded(
            child: Mosaic(
              images: _images,
              screenshotController: screenshotController,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Tirar Foto"),
                ),
                ElevatedButton.icon(
                  onPressed: _images.isEmpty ? null : _saveMosaicAsPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Salvar em PDF"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
