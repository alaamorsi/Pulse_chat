import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/modules/authentication/forget_password_screen.dart';
import 'package:talk_up/modules/authentication/register_screen.dart';
import 'package:talk_up/modules/authentication/cubit/cubit.dart';
import 'package:talk_up/modules/authentication/cubit/states.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:talk_up/shared/components.dart';
import 'package:talk_up/shared/components/my_button.dart';
import 'package:talk_up/shared/components/my_text_form_field.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AuthenticationCubit cubit = AuthenticationCubit.get(context);
    return BlocConsumer<AuthenticationCubit, AuthenticationStates>(
      listener: (context, state) {
        if (state is AuthenticationLoginSuccessState) {
          CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
            uId = state.uId;
            AppCubit.get(context).getUserData();
            AppCubit.get(context).getUsers();
            navigateAndFinish(context, const HomeScreen());

            return;
          }).catchError((error) {
            showToast(text: 'Login failed!', state: ToastStates.ERROR);
            return;
          });
        } else if (state is AuthenticationLoginEmailNotVerifiedErrorState) {
          showToast(
              text: 'Please, verify your email!', state: ToastStates.WARNING);
          return;
        } else if (state is AuthenticationLoginErrorState) {
          if (state.error.contains('incorrect')) {
            showToast(
                text: 'Email or password incorrect!', state: ToastStates.ERROR);
            return;
          } else {
            showToast(text: 'Something went wrong!', state: ToastStates.ERROR);
            return;
          }
        } else if (state is AuthenticationLoginWithGoogleSuccessState) {
          CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
            uId = state.uId;
            AppCubit.get(context).getUserData();
            AppCubit.get(context).getUsers();
            navigateAndFinish(context, const HomeScreen());

            return;
          }).catchError((error) {
            showToast(text: 'Login failed!', state: ToastStates.ERROR);
            return;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight / 20),
                    Text(
                      'Pulse',
                      style: TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.w900,
                          color: theme.canvasColor),
                    ),
                    SizedBox(
                      height: screenHeight / 7,
                    ),
                    Center(
                        child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor),
                    )),
                    const SizedBox(
                      height: 25.0,
                    ),
                    MyTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 25.0,
                        color: theme.secondaryHeaderColor,
                      ),
                      onValidate: (String? value) {
                        if (value!.isEmpty) {
                          return 'Can\'t be empty !';
                        }
                        if (!value.contains('@') && !value.contains('.') ||
                            value.length < 10) {
                          return 'Please, enter a valid email !';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    MyTextFormField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: cubit.isPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          cubit.changePasswordVisibility();
                        },
                        icon: Icon(
                          cubit.suffix,
                          size: 25.0,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.key,
                        size: 25.0,
                        color: theme.secondaryHeaderColor,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      onValidate: (String? value) {
                        if (value!.isEmpty) {
                          return 'Can\'t be empty !';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters !';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    MyButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          cubit.userLogin(
                              email: emailController.text,
                              password: passwordController.text);
                        }
                      },
                      widget: state is! AuthenticationLoginLoadingState
                          ? Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).primaryColor),
                            )
                          : CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40.0,
                          child: TextButton(
                              onPressed: () {
                                navigateTo(context, ForgetPasswordScreen());
                              },
                              child: Text(
                                'Forget password?',
                                style: TextStyle(
                                  fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).canvasColor,
                                ),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account yet?',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: theme.secondaryHeaderColor),
                        ),
                        TextButton(
                            onPressed: () {
                              navigateTo(context, RegisterScreen());
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: theme.canvasColor),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 2.0,
                            color: theme.secondaryHeaderColor,
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Or with',
                          style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: theme.canvasColor),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 2.0,
                            color: theme.secondaryHeaderColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Center(
                      child: Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(15.0),
                            backgroundColor:
                                WidgetStateProperty.all(theme.primaryColor),
                          ),
                          onPressed: () async {
                            await cubit.signInWithGoogle();
                          },
                          child: const SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: Image(
                                image: AssetImage('assets/images/google.png'),
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
