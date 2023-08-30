import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenSaved extends StatefulWidget {
  final Function(Map<String, dynamic>) onDelete;

  ScreenSaved({required this.onDelete});
  @override
  _ScreenSavedState createState() => _ScreenSavedState();
}

class _ScreenSavedState extends State<ScreenSaved> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourite Quotes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favorite_quotes')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            // Data retrieval successful
            final documents = snapshot.data!.docs;

            if (documents.isEmpty) {
              return Center(
                child: Text('No favourite quotes available'),
              );
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final data = documents[index].data() as Map<String, dynamic>;
                final text = data['text'];
                final author = data['author'];

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quote',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: () {
                            showOptions(context, documents[index]);
                          },
                        ),
                      ],
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Author ~ $author',
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                    Divider(
                      color: Colors.deepPurple,
                      thickness: 1,
                      indent: 46,
                      endIndent: 46,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void deleteQuote(DocumentSnapshot document) async {
    try {
      await document.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from Favorites')),
      );
      widget.onDelete(document.data() as Map<String, dynamic>);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting quote: $error')),
      );
    }
  }

  void showOptions(BuildContext context, DocumentSnapshot document) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                deleteQuote(document);
              },
            ),
          ],
        );
      },
    );
  }
}
