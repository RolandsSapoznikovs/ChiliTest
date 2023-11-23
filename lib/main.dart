import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy Search',
      home: GiphySearch(),
    );
  }
}

class GiphySearch extends StatefulWidget {
  @override
  _GiphySearchState createState() => _GiphySearchState();
}

class _GiphySearchState extends State<GiphySearch> {
  final apiKey = 'OKMZ2LOG2XURohiRjpfNXvotf4wTbhrG';
  final apiUrl = 'https://api.giphy.com/v1/gifs/search';

  TextEditingController _searchController = TextEditingController();
  //Results are displayed in a list
  List<dynamic> _gifs = [];
  int _offset = 0;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  //Listen when reach bottom and request pagnition
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final query = _searchController.text.trim();
      _searchGifs(query);
    }
  }

  Future<void> _searchGifs(String query, {int limit = 10}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
      '$apiUrl?api_key=$apiKey&q="$query"&limit=$limit&offset=$_offset',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _gifs.addAll(data);
        _offset += limit;
        _isLoading = false;
      });
    } else {
      print('Error fetching data: ${response.statusCode}');
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ChiliTest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    // Implement "live search" with a delay
                    Future.delayed(Duration(milliseconds: 300), () {
                      setState(() {
                        _gifs.clear();
                        _offset = 0;
                        _searchGifs(query);
                      });
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for GIFs',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildGifList(),
    );
  }

  Widget _buildGifList() {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _gifs.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _gifs.length) {
            return Center(child: CircularProgressIndicator());
          }

          final gif = _gifs[index];
          final imageUrl = gif['images']['fixed_height']['url'];

          return Card(
            child: Image.network(imageUrl),
          );
        },
      ),
    );
  }
}
