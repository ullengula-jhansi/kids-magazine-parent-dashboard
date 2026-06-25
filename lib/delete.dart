import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String userEmail = '';
  String errorText = '';

  Future<void> _reauthenticateWithGoogle() async {
    try {

      User? user = _auth.currentUser;

      if (user != null) {
        // Check if the user signed in with Google
        bool isGoogleSignIn = user.providerData.any((info) => info.providerId == 'google.com');

        if (isGoogleSignIn) {
          // Use Google Sign-In to reauthenticate
          GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
          GoogleSignInAuthentication googleSignInAuth = await googleSignInAccount!.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuth.accessToken,
            idToken: googleSignInAuth.idToken,
          );

          // Reauthenticate the user with Google credentials
          await user.reauthenticateWithCredential(credential);

        } else {

          print('User did not sign in with Google');

        }
      }
    } catch (e) {

      print('Error reauthenticating user with Google: $e');

    }
  }

  Future<void> _deleteAccount(String userEmail) async {
    try {

      await _reauthenticateWithGoogle();
      User? user = _auth.currentUser;
      if (user != null && user.email == userEmail) {
        // Delete the user account
        await user.delete();

        // Sign out the user
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, "/");

      } else {
        // Handle the case where the provided email does not match the current user's email
        print('Provided email does not match the current user"s email');
      }
    } catch (e) {
      print('Error deleting account: $e');
      // Handle errors, show a message to the user, etc.
    }
  }

  Future<void> _showEmailConfirmationDialog() async {
    String emailInput = '';
    errorText = ''; // Clear the error text when showing the dialog

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      emailInput = value;
                    },
                    decoration: InputDecoration(labelText: 'Enter your Gmail:'),
                  ),
                  if (errorText.isNotEmpty)
                    Text(
                      errorText,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    User? currentUser = _auth.currentUser;

                    if (currentUser != null && emailInput == currentUser.email) {
                      // Call the function to delete the account with email confirmation
                      await _deleteAccount(emailInput);

                    } else {
                      // Handle the case where the entered email does not match the current user's email
                      setState(() {
                        errorText = "Entered email does not match the current user's email";
                      });
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00073e),
        title: Text(
          "Delete Account",
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: 'Amaranth',
            color:Color(0xFFFFC857),
          ),
        ),
      ),
      backgroundColor: Color(0xFFFFC857),
      body: Container(

        // color: Color(0xFFFFC857),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // No need for explicit reauthentication form, as Google credentials are used
            Text(
              'Are you sure you want to delete your account...?',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,

            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Call the function to delete the account
                //await _deleteAccount(userEmail);
                await _showEmailConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Confirm Delete',style:TextStyle(color:Color(0xFFFFC857),)),
            ),
          ],
        ),
      ),
    );
  }
}