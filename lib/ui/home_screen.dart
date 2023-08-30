import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quote/ui/save_screen.dart';
import '../utils/floating_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> quotes = [];
  PageController _pageController = PageController();
  List<bool> isLike = [];
  String formattedDate = '';
  String formattedDay = '';
  String _favoriteMessage = "";

  Future<void> fetchData() async {
    final url = Uri.parse('https://famous-quotes4.p.rapidapi.com/random');
    final headers = {
      'X-RapidAPI-Key': '9b19a8b5cbmshb9c10fb79cb1b95p1bcf23jsn986ea85109fb',
      'X-RapidAPI-Host': 'famous-quotes4.p.rapidapi.com',
    };
    final params = {
      'category': 'all',
      'count': '5',
    };

    try {
      final response = await http.get(url.replace(queryParameters: params),
          headers: headers);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<Map<String, dynamic>> newQuotes = [];
        for (var quote in responseData) {
          newQuotes.add({
            'text': quote['text'],
            'author': quote['author'],
          });
        }
        setState(() {
          isLike.clear();
          quotes = newQuotes;
          for (int i = 0; i < quotes.length; i++) {
            isLike.add(false);
          }
        });
      } else {
        setState(() {
          quotes = [
            {
              'text': 'Request failed with status: ${response.statusCode}',
              'author': 'Error',
            }
          ];
        });
      }
    } catch (error) {
      setState(() {
        quotes = [
          {
            'text': 'Error: $error',
            'author': 'Error',
          }
        ];
      });
    }
  }

  @override
  void initState() {
    updateDateAndDay();
    fetchData();
    super.initState();
  }

  void updateDateAndDay() {
    final now = DateTime.now();
    formattedDate = DateFormat('d MMMM, y').format(now);
    formattedDay = DateFormat('EEEE').format(now);
  }

  Future<void> _shareQuote(String quoteText, String author) async {
    String message = '"$quoteText" ~ $author';

    try {
      await FlutterShare.share(
        title: 'Quote of the Day',
        text: message,
        chooserTitle: 'Share via',
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
        centerTitle: true,
        title: Text("Quote Of The Day"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0, left: 16.0, right: 16.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDay,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: quotes.isEmpty 
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '“${quotes[index]['text']}”',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 15),
                            Text(
                              '~ ${quotes[index]['author']}',
                              style: TextStyle(
                                  fontSize: 18, fontStyle: FontStyle.italic),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () {
                                    _shareQuote(quotes[index]['text'],
                                        quotes[index]['author']);
                                  },
                                ),
                                AnimatedContainer(
                                  width: 60,
                                  height: 40,
                                  duration: Duration(milliseconds: 200),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: isLike[index]
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      toggleFavorite(index);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurple,
          onPressed: () async {
            final deletedQuote = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreenSaved(
                  onDelete: unfavoriteQuote,
                ),
              ),
            );
            if (deletedQuote != null) {
              // Unfavorite the deleted quote
              unfavoriteQuote(deletedQuote as Map<String, dynamic>);
            }
          },
          label: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('See Favourites'),
              Icon(Icons.arrow_forward_sharp),
            ],
          )),
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        xOffset: -90,
        yOffset: -556,
      ),
    );
  }

  void toggleFavorite(int index) {
    setState(() {
      isLike[index] = !isLike[index];
      if (isLike[index]) {
        _favoriteMessage = 'Added to favourites';
        storeFavoriteQuote(quotes[index]['text'], quotes[index]['author']);
      } else {
        _favoriteMessage = 'Removed from favourites';
        removeFavoriteQuote(quotes[index]['text'], quotes[index]['author']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_favoriteMessage)),
      );
    });
  }

  void unfavoriteQuote(Map<String, dynamic> deletedQuote) {
    final deletedText = deletedQuote['text'];
    final deletedAuthor = deletedQuote['author'];

    for (int i = 0; i < quotes.length; i++) {
      if (quotes[i]['text'] == deletedText &&
          quotes[i]['author'] == deletedAuthor) {
        setState(() {
          isLike[i] = false;
        });
        break;
      }
    }
  }

  Future<void> storeFavoriteQuote(String quoteText, String author) async {
    try {
      await FirebaseFirestore.instance.collection('favorite_quotes').add({
        'text': quoteText,
        'author': author,
      });
    } catch (error) {
      print('Error storing favorite quote: $error');
    }
  }

  Future<void> removeFavoriteQuote(String quoteText, String author) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('favorite_quotes')
          .where('text', isEqualTo: quoteText)
          .where('author', isEqualTo: author)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      print('Error removing favorite quote: $error');
    }
  }
}
