import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/modules/settings_screen.dart';
import 'package:talk_up/shared/components.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  int charCount = 0;
  final int maxChars = 100;
  bool enableEditName = false;

  FilePickerResult? result;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoading = false;
  String? downloadUrl;

  Future<void> pickFile(context) async {
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
        allowMultiple: false,
      );
      if (result != null) {
        fileName = result!.files.first.name;
        pickedFile = result!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
        await uploadFileToFirebase(context);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> uploadFileToFirebase(context) async {
    if (pickedFile == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$uId/files/${pickedFile!.name}');

      await storageRef.putFile(File(pickedFile!.path!));

      downloadUrl = await storageRef.getDownloadURL();
      await AppCubit.get(context).updateUserData(
          uId: AppCubit.get(context).user!.uId, image: downloadUrl);
      await AppCubit.get(context).getUserData();
      print('File uploaded successfully: $downloadUrl');
    } catch (e) {
      print('Failed to upload file: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    aboutController.addListener(() {
      setState(() {
        charCount = aboutController.text.length;
      });
    });
    // Initialize text fields from user data
    final user = AppCubit.get(context).user!;
    nameController.text = user.name;
    aboutController.text = user.about;
  }

  @override
  void dispose() {
    aboutController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: defaultAppBar(
            theme: theme,
            title: 'Personal Information',
            arrowBackFunction: () {
              cubit.getUserData();
              navigateTo(context, const SettingsScreen());
            },
          ),
          body: WillPopScope(
            onWillPop: () async {
              cubit.getUserData();
              navigateTo(context, const SettingsScreen());
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: LinearProgressIndicator(
                          color: theme.canvasColor,
                        ),
                      ),
                    Center(
                      child: Container(
                        width: screenWidth / 2,
                        height: screenHeight / 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth / 2,
                              height: screenHeight / 3,
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(cubit.user!.image),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () async {
                                  await pickFile(context);
                                },
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 45.0,
                                  color: theme.canvasColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth / 2 + 25.0,
                          child: TextFormField(
                            enabled: enableEditName,
                            controller: nameController,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: theme.secondaryHeaderColor,
                            ),
                            cursorColor: theme.canvasColor,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.secondaryHeaderColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (enableEditName) {
                                AppCubit.get(context).user!.name =
                                    nameController.text;
                              }
                              enableEditName = !enableEditName;
                            });
                          },
                          icon: Icon(
                            enableEditName ? Icons.check_circle : Icons.edit,
                            size: 30.0,
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryHeaderColor,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Stack(
                      children: [
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(maxChars),
                          ],
                          maxLines: null,
                          controller: aboutController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          cursorColor: theme.canvasColor,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: theme.secondaryHeaderColor,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write about yourself...',
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: theme.secondaryHeaderColor,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: theme.secondaryHeaderColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.secondaryHeaderColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$charCount',
                                style: TextStyle(
                                    fontSize: 14.0, color: theme.canvasColor),
                              ),
                              Text(
                                '/$maxChars characters',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: theme.secondaryHeaderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100.0),
                      child: Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            elevation: WidgetStateProperty.all(0.0),
                            backgroundColor:
                            WidgetStateProperty.all(theme.canvasColor),
                            fixedSize: WidgetStateProperty.all(
                                const Size.fromHeight(50.0)),
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await cubit.updateUserData(
                              uId: cubit.user!.uId,
                              name: nameController.text,
                              about: aboutController.text,
                            );
                            await cubit.getUserData();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
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
