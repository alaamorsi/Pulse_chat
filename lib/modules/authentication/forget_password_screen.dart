import 'package:flutter/material.dart';
import 'package:talk_up/modules/authentication/Login_screen.dart';
import 'package:talk_up/modules/authentication/cubit/cubit.dart';
import 'package:talk_up/modules/authentication/cubit/states.dart';
import 'package:talk_up/shared/components.dart';
import 'package:talk_up/shared/components/my_button.dart';
import 'package:talk_up/shared/components/my_text_form_field.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var cubit = AuthenticationCubit.get(context);
    return BlocConsumer<AuthenticationCubit, AuthenticationStates>(
      listener: (context, state) {
        if (state is AuthenticationSendResetPasswordSuccessState) {
          showToast(text: 'Check box!', state: ToastStates.SUCCESS);
          navigateAndFinish(context, LoginScreen());
          return;
        }
      },
      builder: (context, state) {
        return WillPopScope(
            onWillPop: ()async{
              navigateAndFinish(context, LoginScreen());
              return true;
              },
          child: Scaffold(
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              navigateAndFinish(context, LoginScreen());
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              size: 35.0,
                              color: theme.canvasColor,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            'Pulse',
                            style: TextStyle(
                                fontSize: 42.0,
                                fontWeight: FontWeight.w900,
                                color: theme.canvasColor),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight / 7,
                      ),
                      Center(
                          child: Text(
                        'Forget password',
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor),
                      )),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Text(
                        'Write your email and we will send verification message inbox!',
                        style: TextStyle(
                            fontSize: 16.0, color: theme.secondaryHeaderColor),
                      ),
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
                        height: 25.0,
                      ),
                      MyButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            cubit.sendPasswordResetEmail(emailController.text);
                          }
                        },
                        widget: state
                                is! AuthenticationSendResetPasswordLoadingState
                            ? Text(
                                'Send',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Theme.of(context).primaryColor),
                              )
                            : CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
