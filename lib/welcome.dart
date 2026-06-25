import 'package:flutter/material.dart';
import 'package:kids_magazine/select.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }
  bool _isFirstLaunch = true;
  Future<void> _checkFirstLaunch() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;


    setState(() {
      _isFirstLaunch = isFirstLaunch;
    });
  }

  void _showWelcomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFC857), // Background color
          title: Text(
            "Welcome!!",
            style: TextStyle(
              fontFamily: 'Amaranth', // Font family
              color: Color(0xFF181621), // Text color
            ),
          ),
          content: Text(
            "Features (without login):\n"
                "- The app offers a collection of stories available in four different languages.\n"
                "- Users can listen to stories using the audio feature, which provides narration of the stories. Additionally, there is transliteration of story text as well.\n"
                "- To customize their listening experience, users can control the playback speed and volume of the audio.\n\n"
                "Additional Features (with login):\n"
                "- With a registered account, users gain access to additional functionalities, including the ability to upload their own stories to the app.\n"
                "- User's story will be reviewed after uploading.\n"
                "- Users can contact for further information in this mail: irlabiit0@gmail.com",
            style: TextStyle(
              fontFamily: 'Amaranth', // Font family
              color: Color(0xFF181621), // Text color
            ),
            textAlign: TextAlign.justify, // Justify alignment
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectLanguage()),
                );
              },
              child: Text(
                "Close",
                style: TextStyle(
                  fontFamily: 'Amaranth', // Font family
                  color: Color(0xFF181621), // Text color
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.65,
          color: Color(0xFFFFC857),
          child: ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/welcome.jpg"),
                    ))),
            // color: Color(0xFF181621)
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.36,
              color: Color(0xFFFFC857),
              child: Column(
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: Text(
                      "Welcome !!",
                      style: TextStyle(
                        fontSize: 30.0,
                        decoration: TextDecoration.none,
                        fontFamily: 'Amaranth',
                        color: Color(0xFF181621),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Text(
                      "Soar through a magnificent world of dreams",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        decoration: TextDecoration.none,
                        fontFamily: 'JosefinSans',
                        color: Color(0xFF181621),
                      ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(41.0, 12.0, 41.0, 9.0),
                      elevation: 20.0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),

                      foregroundColor: Colors.black, // Background color
                      //disabledForegroundColor: Colors.black,// text color // DO IT PROPERLY
                    ),



                    onPressed: () {
                      // _showWelcomeDialog(context);
                      if (_isFirstLaunch) {
                        _showWelcomeDialog(context);
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setBool('isFirstLaunch', false);
                        });
                        _isFirstLaunch = false;
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => SelectLanguage()),
                        // );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SelectLanguage()),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        "HERE WE GO!",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Amaranth',
                          color: Color(0xFF181621),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}