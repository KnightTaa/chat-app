import 'package:chat_app/modal/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods{
final FirebaseAuth _auth =  FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount =  await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential =  GoogleAuthProvider.getCredential(idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken);

  final AuthResult authResult =  await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(currentUser.uid == user.uid);
}

User _userFromFirebaseUser(FirebaseUser user){
  return user != null ? User(userId: user.uid) : null;
}

Future signInWithEmailAndPassword(String email, String password) async {
  try{
      AuthResult result =  await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser =  result.user;
      return _userFromFirebaseUser(firebaseUser);
  }catch(e){
      print(e.toString());
  }
}

Future signUpWithEmailAndPassword(String email, String password) async {
  try{
    AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    FirebaseUser firebaseUser =  result.user;
    return _userFromFirebaseUser(firebaseUser);
  }catch(e){
    print(e.toString());
  }
}

Future resetPass(String email) async{
  try{
    return await _auth.sendPasswordResetEmail(email: email);
  }catch(e){
    print(e.toString());
  }
}

Future signOut() async {
  try{
    return await _auth.signOut();
  }catch(e){
    print(e.toString());
  }
}

}