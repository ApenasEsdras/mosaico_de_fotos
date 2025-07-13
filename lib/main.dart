import 'package:flutter/material.dart';
import 'package:mosaico_teste/pages/mosaico_home_page.dart';

void main() {
  runApp(const MosaicoApp());
}

class MosaicoApp extends StatelessWidget {
  const MosaicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mosaico Fotos PDF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system, // usa o modo do sistema (dark ou light)
      home: const MosaicoPage(),
    );
  }
}
