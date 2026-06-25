import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kids_magazine/story.dart';

class MyUploads extends StatefulWidget {
  final String userId;
  MyUploads(this.userId);

  @override
  _MyUploadsState createState() => _MyUploadsState();
}

class _MyUploadsState extends State<MyUploads> {
  CollectionReference img = FirebaseFirestore.instance.collection('stories');

  // ✅ DELETE FUNCTION
  Future<void> deleteStory(String docId) async {
    await FirebaseFirestore.instance
        .collection('stories')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00073e),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp,
              color: Color(0xFFFFC857)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Uploaded Stories",
          style: TextStyle(color: Color(0xFFFFC857)),
        ),
      ),

      body: Container(
        color: Color(0xFFFFC857),

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stories')
              .where("uid", isEqualTo: widget.userId)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Center(child: Text("No stories uploaded"));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var document = docs[index];

                if (document['status'] != 'approved') {
                  return SizedBox();
                }

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                  child: Card(
                    color: Color(0xFF181621),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Story(document.id),
                          ),
                        );
                      },

                      // ✅ IMAGE
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(document['image']),
                      ),

                      // ✅ TITLE + DELETE (NO OVERFLOW)
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              document['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color(0xFFFFC857)),
                            ),
                          ),

                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Delete Story?"),
                                  content: Text(
                                      "This action cannot be undone"),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text("Delete"),
                                      onPressed: () async {
                                        await deleteStory(
                                            document.id);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // ✅ AUTHOR
                      subtitle: Text(
                        document['author'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                        TextStyle(color: Color(0xFFFFC857)),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}