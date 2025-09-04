import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/api/api.dart';
import 'package:news_app/screen/detail_screen.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  String _selectedCategory = '';

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _filteredNews = [];
  bool isLoading = false;

  Future<void> fetchNews(String type) async {
    setState(() {
      isLoading = true;
    });

    final data = await Api().getApi(type: type);
    setState(() {
      _allNews = data;
      _filteredNews = data;
      isLoading = false;
    });
  }

  applySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNews = _allNews;
      });
    } else {
      setState(() {
        _filteredNews = _allNews.where((item) {
          final title = item['title'].toString().toLowerCase();
          final snippet = item['contenySnippet'].toString().toLowerCase();
          final search = query.toLowerCase();
          return title.contains(search) || snippet.contains(search);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews(_selectedCategory);
    _searchController.addListener(() {
      applySearch(_searchController.text);
    });
  }

  Widget categoryButton(String label, String type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategory == type
            ? Colors.redAccent
            : Colors.white,
        foregroundColor: _selectedCategory == type
            ? Colors.white
            : Colors.redAccent,
        textStyle: TextStyle(
          fontWeight: _selectedCategory == type
              ? FontWeight.w800
              : FontWeight.w400,
        ),
        elevation: _selectedCategory == type ? 0 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedCategory = type;
        });
        fetchNews(type);
      },
      child: Text(label),
    );
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Hottest ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'News.',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hint: Text('seach news...'),
                    prefixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        applySearch(_searchController.text);
                      },
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      categoryButton('Semua', ''),
                      categoryButton('National', 'nasional'),
                      categoryButton('International', 'internasional'),
                      categoryButton('Ekonomi', 'ekonomi'),
                      categoryButton('Olahraga', 'olahraga'),
                      categoryButton('Teknologi', 'teknologi'),
                      categoryButton('hiburan', 'hiburan'),
                      categoryButton('Gaya-hidup', 'gaya-hidup'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredNews.isEmpty
                ? Center(child: Text('No News Found'))
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final item = _filteredNews[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(newsDetail: item),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x2020200D),
                                spreadRadius: 3,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(item['image']['small']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 220,
                                height: 120,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        maxLines: 3,

                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatDate(item['isoDate']),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: _filteredNews.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 20);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
