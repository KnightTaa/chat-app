import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chatRoomsScreen.dart';
import 'googleChatRoomsScreen.dart';

class SignIn extends StatefulWidget {

  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods =  new AuthMethods();
  DatabaseMethods databaseMethods =  new DatabaseMethods();

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  bool isLoading = false;
  QuerySnapshot snapshotUserInfo;

  signIn(){
    if(formKey.currentState.validate()){

      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
      //HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);

      databaseMethods.getUserByUserEmail(emailTextEditingController.text)
          .then((val){
        snapshotUserInfo = val;
        HelperFunctions.saveUserNameSharedPreference(snapshotUserInfo.documents[0].data["name"]);
        //print("${snapshotUserInfo.documents[0].data["name"]} this is not good");
      });


      setState(() {
        isLoading = true;
      });
      authMethods.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text)
      .then((val){
        if(val != null){

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => ChatRoom()
          ));
        }
      });


    }
  }

  FirebaseUser user;

  /*void click(){
    authMethods.signInWithGoogle().then((FirebaseUser user){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom()));
    });

  }*/

  Widget googleLoginButton(){
    return OutlineButton(
      onPressed: (){
        authMethods.signInWithGoogle().then((result) {
          if (result != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return GoogleChatRoom();
                },
              ),
            );
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
      splashColor: Colors.grey,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage('assets/images/google_logo.png'), height: 35,),
          Padding(padding: EdgeInsets.only(left: 10), child: Text("Sign in with Google", style: mediumTextStyle(),),)
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(children: [
                    TextFormField(
                      validator: (val){
                        return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(val) ? null : "Please provide a valid email";
                      },
                      controller: emailTextEditingController,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("email"),
                    ),
                    TextFormField(
                      obscureText: true,
                      validator: (val) {
                        return val.length > 6
                            ? null
                            : "Enter Password 6+ characters";
                      },
                      controller: passwordTextEditingController,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("password"),
                    ),
                  ],),
                ),
                SizedBox(height: 8,),
                Container(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Forgot Password ?", style: simpleTextStyle(),),
                  ),
                ),
                SizedBox(height: 8,),
                GestureDetector(
                  onTap: (){
                    signIn();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff007EF4),
                          const Color(0xff2A75BC)
                        ]
                      ),
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text("Sign In", style: mediumTextStyle(),),
                  ),
                ),
                SizedBox(height: 16,),
                GestureDetector(
                  onTap: (){

                  },
                  child: Container(
                    child: googleLoginButton(),
                  ),
                ),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an Account? ", style: mediumTextStyle(),),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Register now", style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          decoration: TextDecoration.underline,
                        ),),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 50,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
