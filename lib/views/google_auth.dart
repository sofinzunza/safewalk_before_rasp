import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // method to sign in using google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // start interactive authentication (must be triggered from user action)
      final GoogleSignInAccount account = await googleSignIn.authenticate();

      // get authentication tokens (note: current API exposes only idToken)
      final GoogleSignInAuthentication authTokens = account.authentication;

      final String? idToken = authTokens.idToken;

      if (idToken == null) {
        // couldn't get id token
        return false;
      }

      // create firebase credential with idToken
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      await auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('FirebaseAuthException in signInWithGoogle: ${e.toString()}');
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Error in signInWithGoogle: $e');
      return false;
    }
  }

  // method to sign out from both firebase and google
  Future<void> googleSignOut() async {
    await auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
