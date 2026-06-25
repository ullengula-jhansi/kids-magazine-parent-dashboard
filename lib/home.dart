import 'quiz_language_page.dart';
import 'quiz_level_page.dart';
import 'QuizStartPage.dart';
import 'quiz_page.dart';
import 'Quiz_type.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kids_magazine/BengaliStoryPage.dart';
import 'package:kids_magazine/register.dart';
import 'package:kids_magazine/select.dart';
import 'package:kids_magazine/uploadStory.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'admin.dart';
import 'my_uploads.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:kids_magazine/others.dart';
import 'parent_dashboard.dart';
import 'Varnamala.dart';
import 'Vowel_consonant.dart';

class HomePage extends StatefulWidget {
  final String _SelectedLanguage;

  HomePage(this._SelectedLanguage);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CollectionReference img = FirebaseFirestore.instance.collection('stories');

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey navKey = GlobalKey();
  final GlobalKey varnamalaKey = GlobalKey();
  final GlobalKey vowelConsonantKey = GlobalKey();
  bool isLoggedIn = false;

  @override
  void initState() {
    isLoggedIn = FirebaseAuth.instance.currentUser != null;

    if (!isLoggedIn) {
      Future.delayed(const Duration(seconds: 1), () {
        _showTutorialCoachmark();
      });
    }

    super.initState();
  }

  void _showTutorialCoachmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShown4') ?? false;

    if (!tutorialShown) {
      _initTarget();

      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
      );

      tutorialCoachMark!.show(context: context);

      // Save that tutorial has been shown
      prefs.setBool('tutorialShown4', true);
    }
  }

  void _initTarget() {
    targets = [

      TargetFocus(
        identify: "varnamala",
        keyTarget: varnamalaKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Click here to learn Varnamala (letters of the language)",
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          )
        ],
      ),

      TargetFocus(
        identify: "vowelConsonant",
        keyTarget: vowelConsonantKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Click here to learn vowel + consonant combinations (Barakhadi / Guninthaalu)",
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          )
        ],
      ),

      TargetFocus(
        identify: "login",
        keyTarget: navKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Click here to access navigation bar",
                onNext: () => controller.next(),
                onSkip: () => controller.skip(),
              );
            },
          )
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(widget._SelectedLanguage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 25, 4, 131),
        leading: IconButton(
          icon: Icon(
            key: navKey,
            Icons.menu,
            color: Color.fromARGB(255, 242, 193, 96),
            size: 30.0,
          ),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text(
          "StoryTime",
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: 'Amaranth',
            color: Color.fromARGB(255, 249, 208, 125),
          ),
        ),
      ),
      body: Container(
          color: Color.fromARGB(255, 249, 197, 94),
          child: Column(
            children: [
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ElevatedButton.icon(
                  key: varnamalaKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 25, 4, 131),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(Icons.menu_book, color: Colors.white),
                  label: Text(
                    "Learn Varnamala",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Amaranth',
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VarnamalaPage(language: widget._SelectedLanguage),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ElevatedButton.icon(
                  key: vowelConsonantKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 25, 4, 131),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book, color: Colors.white), // same icon as Varnamala
                  label: const Text(
                    "Vowel + Consonant",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Amaranth',
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VowelConsonantPage(language: widget._SelectedLanguage),
                      ),
                    );
                  },
                ),
              ),
              Flexible(
                child: RawScrollbar(
                  thumbColor: const Color.fromARGB(96, 10, 0, 24),
                  thickness: 4,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('stories')
                          .where("language",
                          isEqualTo: widget._SelectedLanguage)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<Widget> stories = snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          print(document['image']);
                          //if (document['image'] == null)
                          img.doc(document.id).update({
                            'image':
                            'https://firebasestorage.googleapis.com/v0/b/kids-magazine-c41d5.appspot.com/o/storyImages%2Fbulletin.jpeg?alt=media&token=4326548d-263a-4a19-b509-5a18477c3ce6'
                          });
                          if (document['status'] == 'approved')
                            return GestureDetector(
                              onTap: () {
                                if (widget._SelectedLanguage == "Bengali") {
                                  // Navigate to a different page for Bengali stories
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BengaliStory(document.id),
                                    ),
                                  );
                                } else {
                                  // Navigate to the existing story page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          otherStory(document.id),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Card(
                                  color: Color.fromARGB(255, 244, 235, 216),
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                    width: 180,
                                    height: 100,
                                    padding: const EdgeInsets.all(
                                        10.0), // Consistent inner padding
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        // Logo with half white and half black
                                        ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.black
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.srcATop,
                                          child: Icon(
                                            Icons.bookmark_rounded,
                                            size: 32.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                            10.0), // Spacing between logo and text
                                        // Text Column
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              // Title Text
                                              Text(
                                                document['title'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontFamily: 'JosefinSans',
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                  5.0), // Space between title and author
                                              // Author Row
                                              Row(
                                                children: [
                                                  Text(
                                                    "--",
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontFamily: 'JosefinSans',
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.0),
                                                  Flexible(
                                                    child: Text(
                                                      document['author'],
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontFamily:
                                                        'JosefinSans',
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          else {
                            return Container(
                              height: 0,
                            );
                          }
                        }).toList();
                        stories.add(Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 40,
                                  color: Color(0xFF181621),
                                ),
                                Text(
                                  "You're All Caught Up",
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              ],
                            )));
                        return new ListView(children: stories);
                      }),
                ),
              ),
            ],
          )),
    );
  }
}

class NavDrawer extends StatefulWidget {
  final String _SelectedLanguage;

  NavDrawer(this._SelectedLanguage);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey loginKey = GlobalKey();
  GlobalKey registerKey = GlobalKey();
  GlobalKey uploadkey = GlobalKey();

  @override
  void initState() {
    if (user == null) {
      Future.delayed(const Duration(seconds: 1), () {
        _showTutorialCoachmark();
      });
    } else if (user != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _showuploadTutorial();
      });
    }
    super.initState();
  }

  void _showTutorialCoachmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShownsidebar') ?? false;

    if (!tutorialShown) {
      _initTarget();
      tutorialCoachMark = TutorialCoachMark(targets: targets);
      tutorialCoachMark!.show(context: context);

      // Save in SharedPreferences that tutorial has been shown
      prefs.setBool('tutorialShownsidebar', true);
    }
  }

  void _showuploadTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorialShownupload') ?? false;

    if (!tutorialShown) {
      _initLoggedInTargets();
      tutorialCoachMark = TutorialCoachMark(targets: targets);
      tutorialCoachMark!.show(context: context);

      // Save in SharedPreferences that tutorial has been shown
      prefs.setBool('tutorialShownupload', true);
    }
  }

  void _initTarget() {
    targets = [
      TargetFocus(identify: "register", keyTarget: registerKey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                "click here to register. \nOnce you login you can Upload stories of your own!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            })
      ]),
      TargetFocus(identify: "login", keyTarget: loginKey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text:
                "Click here to login. \nOnce you login you can upload stories of your own!",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            })
      ]),
    ];
  }

  void _initLoggedInTargets() {
    // Define targets for logged-in users
    targets = [
      TargetFocus(
        identify: "upload",
        keyTarget: uploadkey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                text: "Upload stories from here",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),
      // Define other targets for logged-in users
    ];
  }

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    void signOut() {
      googleSignIn.signOut();
      Navigator.pop(context);
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    // final String email = googleUser.email;

    final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential _currentUser =
    await FirebaseAuth.instance.signInWithCredential(credential);

    if (_currentUser.additionalUserInfo!.isNewUser) {
      // The user is just created
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    } else {
      // The user is already there, so redirect to feed

      if (_currentUser.user!.email == 'irlabiit0@gmail.com' ||
          _currentUser.user!.email == 'nilendu.adhikary.cd.cse23@itbhu.ac.in') {
        //take to the admin side
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(widget._SelectedLanguage)),
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        color: Color(0xFFFFC857),
        child: ListView(
          padding: EdgeInsets.all(0.0),
          children: [
            DrawerHeader(
              child: Text(
                "Kids Magazine",
                style: TextStyle(
                    fontFamily: 'Amaranth',
                    fontSize: 30.0,
                    color: Color(0xFFFFC857),
                    fontWeight: FontWeight.w400),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/bg.jpg"),
                  )),
            ),
            Container(
              color: Color(0xFFFFC857),
              child: Column(
                children: [
                  if (user == null)
                    ListTile(
                      leading: Icon(
                        key: loginKey,
                        Icons.login,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        signInWithGoogle();
                      },
                    ),
                  if (user == null)
                    ListTile(
                      leading: Icon(
                        key: registerKey,
                        Icons.login_sharp,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        signInWithGoogle();
                      },
                    ),
                  if (user != null)
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Color(0xFF181621),
                    ),
                    title: Text(
                      'Change Language',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF181621),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectLanguage()),
                      );
                    },
                  ),
                  // quiz
                  if(user!=null)
                    ListTile(
                      leading: Icon(
                        Icons.quiz,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Quiz',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSelectionPage(
                              language: widget._SelectedLanguage,
                            ),
                          ),
                        );
                      },
                    ),

                  if(user!=null)
                    ListTile(
                      leading: Icon(
                        Icons.dashboard,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Parent Dashboard',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentDashboardGate(),
                          ),
                        );
                      },
                    ),
                  if (user != null)
                    ListTile(
                      leading: Icon(
                        key: uploadkey,
                        Icons.upload_rounded,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Upload Story',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UploadStory(widget._SelectedLanguage)),
                        );
                      },
                    ),
                  if (user != null &&
                      (user!.email == 'pkenny.mukeshbhai.cse19@itbhu.ac.in' ||
                          user!.email == "irlabiit0@gmail.com" ||
                          user!.email ==
                              'nilendu.adhikary.cd.cse23@itbhu.ac.in' ||
                          user!.email == "sachinkr546987@gmail.com" ))

                    ListTile(
                      leading: Icon(
                        Icons.upload_file,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'Uploaded Stories',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminPage()),
                        );
                      },
                    ),
                  if (user != null)
                    ListTile(
                      leading: Icon(
                        Icons.folder_rounded,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'My Uploads',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyUploads(user!.uid)),
                        );
                      },
                    ),
                  if (user != null)
                    ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () async {
                        // Show the confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete your Account?'),
                              content: const Text(
                                  '''If you select Delete, we will delete your account on our server.

Your app data will also be deleted, and you won't be able to retrieve it.

Since this is a security-sensitive operation, you will be asked to enter your correct email address before your account can be deleted.'''),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    // Call the function to delete the account here
                                    // For demonstration purposes, let's print a message
                                    print('Deleting the user account...');
                                    // You can replace the above line with the actual delete account logic
                                    Navigator.pushNamed(context, "/delete");
                                    // Sign out the user after deletion
                                    // FirebaseAuth.instance.signOut();
                                    // GoogleSignIn().signOut();
                                    //
                                    // // Close the confirmation dialog
                                    // Navigator.of(context).pop();

                                    // Optionally, you can navigate to another screen or perform other actions
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  if (user != null)
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Color(0xFF181621),
                      ),
                      title: Text(
                        'LogOut',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF181621),
                        ),
                      ),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, "/");
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

}