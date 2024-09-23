abstract class AuthenticationStates {}

class AuthenticationInitialState extends AuthenticationStates {}

//Login
class AuthenticationLoginLoadingState extends AuthenticationStates {}

class AuthenticationLoginSuccessState extends AuthenticationStates {
  final String uId;

  AuthenticationLoginSuccessState({required this.uId});
}

class AuthenticationLoginErrorState extends AuthenticationStates {
  final String error;

  AuthenticationLoginErrorState({required this.error});
}

class AuthenticationLoginEmailNotVerifiedErrorState
    extends AuthenticationStates {}

//Change password visibility
class AuthenticationChangePasswordVisibilityState
    extends AuthenticationStates {}

//Login with googel
class AuthenticationLoginWithGoogleLoadingState extends AuthenticationStates {}

class AuthenticationLoginWithGoogleSuccessState extends AuthenticationStates {
  final String uId;

  AuthenticationLoginWithGoogleSuccessState({required this.uId});
}

class AuthenticationLoginWithGoogleErrorState extends AuthenticationStates {
  final String error;

  AuthenticationLoginWithGoogleErrorState({required this.error});
}

//Register
class AuthenticationRegisterLoadingState extends AuthenticationStates {}

class AuthenticationRegisterSuccessState extends AuthenticationStates {}

class AuthenticationRegisterErrorState extends AuthenticationStates {}

//Create user
class AuthenticationCreateUserLoadingState extends AuthenticationStates {}

class AuthenticationCreateUserSuccessState extends AuthenticationStates {}

class AuthenticationCreateUserErrorState extends AuthenticationStates {}

//Forget password
class AuthenticationSendResetPasswordLoadingState extends AuthenticationStates {}

class AuthenticationSendResetPasswordSuccessState extends AuthenticationStates {}

class AuthenticationSendResetPasswordErrorState extends AuthenticationStates {}
