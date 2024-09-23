import 'package:flutter/material.dart';
import 'package:talk_up/model/user_model.dart';
import 'package:talk_up/modules/authentication/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talk_up/shared/constant.dart';

class AuthenticationCubit extends Cubit<AuthenticationStates> {
  AuthenticationCubit() : super(AuthenticationInitialState());

  static AuthenticationCubit get(context) => BlocProvider.of(context);

  //Change password visibility
  IconData suffix = Icons.visibility_off_outlined;
  bool isPassword = true;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(AuthenticationChangePasswordVisibilityState());
  }

  //Google
  Future<UserCredential> signInWithGoogle() async {
    emit(AuthenticationLoginWithGoogleLoadingState());
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create a credential using the Google authentication tokens
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Sign in with the credential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user is already registered in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      // User not registered, create a new user in Firestore
      userCreate(
        name: gUser.displayName ?? '~', // Use displayName or default to '~'
        email: gUser.email,
        uId: userCredential.user!.uid,
        image: gUser.photoUrl ??
            '', // Save the user's profile picture if available
      );
    }
    emit(AuthenticationLoginWithGoogleSuccessState(
        uId: userCredential.user!.uid));
    return userCredential;
  }

  // Register
  void userRegister({
    required String email,
    required String password,
    String name = '~',
  }) {
    emit(AuthenticationRegisterLoadingState());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      userCreate(name: name, email: email, uId: value.user!.uid);
    }).catchError((error) {
      emit(AuthenticationRegisterErrorState());
    });
  }

  // Create user
  void userCreate({
    required String name,
    required String email,
    String image = '',
    required String uId,
  }) {
    UserDataModel userDataModel = UserDataModel(
        name: name, email: email, image: image, uId: uId, about: '');
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(userDataModel.toMap())
        .then((value) {
      emit(AuthenticationCreateUserSuccessState());
    }).catchError((error) {
      emit(AuthenticationCreateUserErrorState());
    });
  }

  // Log in
  void userLogin({
    required String email,
    required String password,
  }) {
    emit(AuthenticationLoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        await CacheHelper.saveData(key: 'uId', value: value.user!.uid);
        emit(AuthenticationLoginSuccessState(uId: value.user!.uid));
      } else {
        emit(AuthenticationLoginEmailNotVerifiedErrorState());
      }
    }).catchError((error) {
      emit(AuthenticationLoginErrorState(error: error.toString()));
    });
  }

  //Send password reset code
  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthenticationSendResetPasswordLoadingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
      emit(AuthenticationSendResetPasswordSuccessState());
    } catch (e) {
      print('Failed to send password reset email: $e');
      emit(AuthenticationSendResetPasswordErrorState());
    }
  }
}
