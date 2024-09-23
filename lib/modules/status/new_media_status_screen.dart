import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/shared/components.dart';
import 'package:file_picker/file_picker.dart';

class NewMediaStatusScreen extends StatefulWidget {
  final PlatformFile mediaUrl;

  const NewMediaStatusScreen({super.key, required this.mediaUrl});

  @override
  State<NewMediaStatusScreen> createState() => _NewMediaStatusScreenState();
}

class _NewMediaStatusScreenState extends State<NewMediaStatusScreen> {
  final TextEditingController mediaStatusController = TextEditingController();
  bool isTyping = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if(state is AppUploadFileSuccessState)
          {
            navigateAndFinish(context, const HomeScreen());
            return;
          }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          // Adjust the layout when the keyboard opens
          body: WillPopScope(
            onWillPop: ()async{
              navigateAndFinish(context, const HomeScreen());
              return true;
            },
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Theme.of(context).canvasColor),
                            child: IconButton(
                              onPressed: () {
                                navigateAndFinish(context, const HomeScreen());
                              },
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).primaryColor,
                                size: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Make the photo scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.6, // 60% of screen height
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(widget.mediaUrl.path!)),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              style: TextStyle(color: Theme.of(context).primaryColor),
                              cursorColor: Theme.of(context).primaryColor,
                              controller: mediaStatusController,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'Can\'t be empty!';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Caption...',
                                hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).canvasColor,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10.0),
                              Container(
                                width: 45.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).canvasColor,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    await AppCubit.get(context).uploadFileToFirebase(
                                        isMediaMessage: false,
                                        receiverId: '',
                                        fileToUpload: widget.mediaUrl,
                                        descriptionMediaStatus:
                                            mediaStatusController.text);
                                    mediaStatusController.clear();
                                  },
                                  icon: state is! AppUploadFileLoadingState ? Icon(
                                    Icons.send,
                                    color: Theme.of(context).primaryColor,
                                  ) : CircularProgressIndicator(color: Theme.of(context).primaryColor,),
                                ),
                              ),
                            ],
                          ),
                        ],
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
