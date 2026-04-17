import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RobotApp());
}

class RobotApp extends StatelessWidget {
  const RobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageScreen(),
    );
  }
}

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  List images = [];

  final String apiUrl =
      "https://q3kwr761t0.execute-api.ap-south-1.amazonaws.com/images";

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future fetchImages() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          images = json.decode(response.body);

          // Latest image first
          images = images.reversed.toList();
        });
      }
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  // Format timestamp
  String formatTimestamp(int timestamp) {
    DateTime dt =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return "${dt.day}-${dt.month}-${dt.year}  "
        "${dt.hour}:${dt.minute}:${dt.second}";
  }

  // View image in new tab
  void viewImage(String url) {
    html.window.open(url, "_blank");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Unknown Person Detection"),
        backgroundColor: Colors.blue,

        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchImages,
          )

        ],
      ),

      body: images.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : ListView.builder(
              itemCount: images.length,

              itemBuilder: (context, index) {

                final img = images[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,

                  child: Column(
                    children: [

                      // IMAGE
                      Image.network(
                        img["image_url"],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(height: 8),

                      // UNKNOWN LABEL
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        color: Colors.red,

                        child: const Text(
                          "⚠ Unknown Person Detected",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // TIME ONLY
                      Text(
                        "Time: ${formatTimestamp(img["timestamp"])}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // VIEW IMAGE BUTTON
                      ElevatedButton.icon(

                        onPressed: () {
                          viewImage(img["image_url"]);
                        },

                        icon: const Icon(Icons.visibility),

                        label: const Text("View Image"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 10),

                    ],
                  ),
                );
              },
            ),
    );
  }
}