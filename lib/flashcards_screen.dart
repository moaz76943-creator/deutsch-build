import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<dynamic> vocabulary = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAndExtractPack();
  }

  Future<void> fetchAndExtractPack() async {
    const url = 'https://cdn.jsdelivr.net/gh/moaz76943-creator/-offline-packs-store@main/packs/de_vocab_a1.pack.gz';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = gzip.decode(response.bodyBytes);
        final jsonString = utf8.decode(decodedData);
        final dynamic decodedJson = json.decode(jsonString);

        if (decodedJson is Map<String, dynamic> && decodedJson['items'] is List) {
          setState(() {
            vocabulary = decodedJson['items'] as List<dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'تنسيق البيانات غير صحيح داخل الحزمة';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل الحزمة: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في الاتصال: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: vocabulary.length,
          itemBuilder: (context, index) {
            final dynamic item = vocabulary[index];
            final String imageName = (item is Map && item['image'] != null)
                ? item['image'].toString()
                : '';
            final String imageUrl =
                'https://cdn.jsdelivr.net/gh/moaz76943-creator/-offline-packs-store@main/images/$imageName';
            final String wordText = (item is Map && item['word'] != null)
                ? item['word'].toString()
                : '';

            return Center(
              child: Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  height: MediaQuery.of(context).size.height * 0.70,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        flex: 1,
                        child: Text(
                          wordText,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
