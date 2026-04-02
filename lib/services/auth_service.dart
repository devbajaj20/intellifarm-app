import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= EMAIL =================

  static Future<bool> isEmailRegistered(String email) async {
    final methods =
    await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  static Future<void> signupWithEmail(
      String email, String password) async {
    final exists = await isEmailRegistered(email);
    if (exists) {
      throw 'auth/email-already-registered';
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await saveUser(
      uid: cred.user!.uid,
      email: email,
      provider: 'email',
    );
  }

  static Future<void> loginWithEmail(
      String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= GOOGLE LOGIN (SIMPLE) =================

  static Future<UserCredential?> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);

    final GoogleSignInAccount? googleUser =
    await googleSignIn.signIn();

    // User cancelled Google picker
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // ================= PHONE =================

  static Future<bool> isPhoneRegistered(String phone) async {
    final query = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  static Future<String> sendOTP(String phone) async {
    final Completer<String> completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (_) {},

      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            e.message ?? 'auth/otp-failed',
          );
        }
      },

      codeSent: (String vid, int? _) {
        if (!completer.isCompleted) {
          completer.complete(vid);
        }
      },

      codeAutoRetrievalTimeout: (String vid) {
        if (!completer.isCompleted) {
          completer.complete(vid);
        }
      },
    );

    return completer.future;
  }

  static Future<void> signupWithPhone(
      String verificationId,
      String otp,
      String phone,
      ) async {
    final exists = await isPhoneRegistered(phone);
    if (exists) {
      throw 'auth/phone-already-registered';
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final userCred =
    await _auth.signInWithCredential(credential);

    await saveUser(
      uid: userCred.user!.uid,
      phone: phone,
      provider: 'phone',
    );
  }

  static Future<void> loginWithPhone(
      String verificationId,
      String otp,
      ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);
  }

  // ================= PASSWORD RESET =================

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'auth/email-not-registered';
        case 'invalid-email':
          throw 'auth/invalid-email';
        case 'operation-not-allowed':
          throw 'auth/password-reset-not-allowed';
        default:
          throw 'auth/reset-failed';
      }
    }
  }

  // ================= COMMON =================

  static Future<void> saveUser({
    required String uid,
    String? email,
    String? phone,
    required String provider,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'phone': phone,
      'provider': provider,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
