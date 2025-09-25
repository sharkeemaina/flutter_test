import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Hit {
  final String previewURL;
  final String user;
  final String tags;

  Hit({required this.previewURL, required this.user, required this.tags});

  factory Hit.fromJson(Map<String, dynamic> json) {
    return Hit(
      previewURL: json['previewURL'],
      user: json['user'],
      tags: json['tags'],
    );
  }
}

class AppImageProvider with ChangeNotifier {
  List<Hit> images = [];
  bool isLoading = false;
  String? error;

  final String apiKey = '52435548-a1009af908e4692c4a0ddd4c6'; // Replace with your Pixabay API key
  final String baseUrl = 'https://pixabay.com/api/';

  Future<void> fetchTrendingImages() async {
    await fetchImages('popular');
  }

  Future<void> fetchImages(String query) async {
    isLoading = true;
    error = null;
    images = [];
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl?key=$apiKey&q=$query&image_type=photo&per_page=50&order=popular&safesearch=true');
      final response = await http.get(uri);
      print('RateLimit-Limit: ${response.headers['x-ratelimit-limit']}');
      print('RateLimit-Remaining: ${response.headers['x-ratelimit-remaining']}');
      print('RateLimit-Reset: ${response.headers['x-ratelimit-reset']}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        images = (data['hits'] as List).map((e) => Hit.fromJson(e)).toList();
      } else {
        error = 'Failed to load images: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}