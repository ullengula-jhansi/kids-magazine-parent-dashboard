import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_magazine/home.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'custom_transliterate.dart';

String title = '';
String story = '';
String author = '';

String? selectedLanguage;
final _formKey1 = GlobalKey<FormState>();

class ImageShow extends StatelessWidget {
  final String? name;
  final Function? delete;

  ImageShow({this.name, this.delete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (3.5 * MediaQuery.of(context).size.width) / 6,
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.only(left: 5.0),
      color: Colors.grey[300],
      child: Row(
        children: <Widget>[
          Icon(Icons.image),
          SizedBox(
            width: 3.0,
          ),
          /*Text(name.length > 18
              ? name.substring(0, 6) + '...' + name.substring(name.length - 5)
              : name),*/
          Text(name!),
          //SizedBox(width: 3.0,),
          new Spacer(),
          IconButton(
            padding: EdgeInsets.only(right: 2.0),
            onPressed: () => delete,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

//ignore: must_be_immutable
class UploadStory extends StatefulWidget {
  late UploadTask task;
  final String _SelectedLanguage;
  UploadStory(this._SelectedLanguage);

  @override
  _UploadStoryState createState() => _UploadStoryState();
}

class _UploadStoryState extends State<UploadStory> {
  FlutterTts flutterTts = FlutterTts();
  String fileType = '';
  File? file;
  String? fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  File? audioFile;
  String audioFileName = '';
  String audioFileUrl = '';

  // picking up story text file

  Future filePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      file = File(result.files.single.path!);

      fileName = path.basename(file!.path); // ✅ FIX

      await _uploadFile(file, fileName); // ✅ WAIT

      String content = await file!.readAsString();

      setState(() {
        story = content; // ✅ UI update
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Uploaded Successfully!"),
        ),
      );
    }
  }

  Future<void> _uploadFile(File? file, String? filename) async {
    File _file = File(file!.path);

    Reference storageReference =
    FirebaseStorage.instance.ref().child("story_files/$filename");

    UploadTask uploadTask = storageReference.putFile(_file);

    TaskSnapshot snapshot = await uploadTask;

    final String url = await snapshot.ref.getDownloadURL();

    print("URL is $url");

    String content = await file.readAsString();

    setState(() {
      story = content; // ✅ IMPORTANT
    });
  }

  Future audioFilePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'wma', 'ogg', 'm4a']);

    if (result != null) {
      audioFile = File(result.files.single.path.toString());
    }

    audioFileName = path.basename(audioFile!.path);
    setState(() {
      audioFileName = path.basename(audioFile!.path);
    });
    print(audioFileName);

    print(audioFileName.substring(
        audioFileName.length - 3, audioFileName.length));
    String extension =
        audioFileName.substring(audioFileName.length - 3, audioFileName.length);
    if (extension == "wav" ||
        extension == "mp3" ||
        extension == "m4a" ||
        extension == "wma") {
      await _uploadAudioFile(audioFile, audioFileName);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Uploaded Successfully! "),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Upload Failed! "),
              content: Text(
                  'Audio file must have the extension .mp3, .wav, .wma, .m4a'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  //uploading audio file to firebase

  Future<void> _uploadAudioFile(File? file, String? filename) async {
    File _file = File(file!.path.toString());
    Reference storageReference;
    storageReference =
        FirebaseStorage.instance.ref().child("audio_files/$filename");
    final UploadTask uploadTask = storageReference.putFile(_file);
    //bool isLoading = true;
    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = (await downloadUrl.ref.getDownloadURL());
    audioFileUrl = url;
    print("URL is $url");
  }

// Selecting language

  List<String> languages = [
    'Bengali',
    'Gujarati',
    'Telugu',
    'Marathi',
    'Hindi'
  ];

  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(languages);
  }

  List<DropdownMenuItem<String>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<String>> items = [];
    for (String listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<String>>? _dropdownMenuItems;

// Picking and uploading image to firebase storage

  File? _image;
  String? _uploadedImageURL;
  List<String> imagesInStory = [];

  Future uploadFile() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('storyImages/${path.basename(_image!.path)}}');
    UploadTask uploadTask = storageReference.putFile(_image!);
    TaskSnapshot snapshot = await uploadTask;
    _uploadedImageURL = await snapshot.ref.getDownloadURL();
    print('Image Uploaded');
  }

  User? user = FirebaseAuth.instance.currentUser;

// setting various fields in form
  Future<void> formProcessor() async {
    final database = FirebaseFirestore.instance.collection('stories');
    print('Original Story Text: $story');
    String transliteratedText =
        '';
    print(selectedLanguage);
    switch (selectedLanguage) {
      case 'Telugu':
        transliteratedText = transliterateTelugu(story);
        break;
      case 'Bengali':
        transliteratedText = transliterateBengali(story);
        break;
      case 'Gujarati':
        transliteratedText = transliterateGujarati(story);
        break;
      case 'Marathi':
        transliteratedText = transliterateMarathi(story);
        break; // Default to Devanagari
      case 'Hindi':
        transliteratedText = transliterateHindi(story);
        break;
    }
    print('transliterated: $transliteratedText');

    // Save the document with the transliterated text
    await database.doc().set({
      'title': title,
      'uid': user?.uid,
      'original_text': story,
      'transliterated_text': transliteratedText,
      'audio': audioFileUrl,
      'language': selectedLanguage,
      'image': _uploadedImageURL,
      'author': author,
      'status': 'approved',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00073e),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Color(0xFFFFC857),
              size: 25.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
          "Upload Story",
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: 'Amaranth',
            color: Color(0xFFFFC857),
          ),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(children: [
            Container(
              color: Color(0xFFFFC857),
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Title cannot be empty.";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Color(0xFF181621),
                          ),
                          labelText: 'Title',
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Author name cannot be empty.";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            author = value;
                          });
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Color(0xFF181621),
                          ),
                          labelText: 'Author',
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            story = value;
                          });
                        },
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Color(0xFF181621),
                          ),
                          labelText: 'Story Text',
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            borderSide: BorderSide(
                              color: Color(0xFF181621),
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            "Select Language",
                            style: TextStyle(
                              color: Color(0xFF181621),
                              fontSize: 20.0,
                              fontFamily: 'Amaranth',
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Container(
                            width: 130.0,
                            height: 50.0,
                            child: DropdownButtonFormField<String>(
                              hint: Container(
                                padding: EdgeInsets.symmetric(horizontal: 11),
                                child: Text(
                                  'Language',
                                  style: TextStyle(
                                    color: Color(0xFF181621),
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              isExpanded: true,
                              elevation: 10,
                              value: selectedLanguage,
                              items: _dropdownMenuItems,
                              onChanged: (value) async {
                                setState(() {
                                  selectedLanguage = value;
                                });
                                print('Selected Language: $value');
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10.0,
                          ),
                          Icon(
                            Icons.cloud_upload,
                            color: Color(0xFF181621),
                            size: 45.0,
                          ),
                          SizedBox(
                            width: 30.0,
                          ),
                          ElevatedButton(
                              child: Text(
                                'Upload Story Text File',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15.0,
                                ),
                              ),
                              onPressed: () => filePicker(context)),
                        ],
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (story.isNotEmpty) {
                            if (selectedLanguage != null) {
                              if (_formKey1.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Establishing Contact with the Server"),
                                    duration: Duration(milliseconds: 300),
                                  ),
                                );
                                // Scaffold.of(context).showSnackBar(SnackBar(
                                //     content: Text(
                                //         'Establishing Contact with the Server')));

                                // uploading audio file
                                if (audioFileUrl.length == 0)
                                  audioFileUrl = "none";
                                //createAudioFile();
                                await formProcessor();

                                ///////////////////////////////////////////////////////////////

                                // story = '';
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(widget._SelectedLanguage)),
                                );
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Alert! "),
                                      content: Text('Please Select a Language'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Upload Failed! "),
                                    content: Text(
                                        'Either paste story in the text field or Upload a text file of story'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 20.0,
                          padding: EdgeInsets.fromLTRB(30.0, 12.0, 30.0, 9.0),
                          foregroundColor: Color(0xFF181621),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 25.0,
                            fontFamily: 'Amaranth',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
