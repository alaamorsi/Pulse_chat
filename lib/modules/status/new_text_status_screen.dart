import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/shared/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewTextStatusScreen extends StatefulWidget {
  const NewTextStatusScreen({super.key});

  @override
  State<NewTextStatusScreen> createState() => _NewTextStatusScreenState();
}

class _NewTextStatusScreenState extends State<NewTextStatusScreen> {
  Color backgroundColor = Colors.red; // Initial background color
  bool isTyping = false;
  TextEditingController statusController = TextEditingController();

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor =
            backgroundColor; // Store selected color temporarily
        return AlertDialog(
          title: const Text('Pick a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: backgroundColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  backgroundColor = selectedColor; // Update background color
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.cyan,
    Colors.teal,
    Colors.blueGrey,
    Colors.blueGrey.shade800,
    Colors.brown,
    Colors.grey,
  ];
  int colorIndex = 0;

  void changeColor() {
    setState(() {
      colorIndex++;
      if (colorIndex == 11) {
        colorIndex = 0;
      }
      backgroundColor = colors[colorIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if(state is AppAddStatusSuccessState)
          {
            AppCubit.get(context).getAllStatuses();
            navigateAndFinish(context, const HomeScreen());
            return;
          }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: ()async{
            AppCubit.get(context).getAllStatuses();
            navigateAndFinish(context, const HomeScreen());
            return true;
          },
          child: SafeArea(
            child: Scaffold(
              body: Container(
                color: backgroundColor,
                // Set the background color
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(15.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black45),
                              child: IconButton(
                                  onPressed: () {
                                    navigateAndFinish(context, const HomeScreen());
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 35.0,
                                  )),
                            ),
                            const Spacer(),
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black45),
                              child: IconButton(
                                  onPressed: changeColor,
                                  icon: const Icon(
                                    Icons.color_lens_outlined,
                                    color: Colors.white,
                                    size: 35.0,
                                  )),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: TextFormField(
                              controller: statusController,
                              cursorColor: Colors.white,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21.0,
                                  fontWeight: FontWeight.bold),
                              maxLines: null,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Type a status',
                                  hintStyle: TextStyle(
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor)),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'Can\'t be empty';
                                }
                                return null;
                              },
                              onChanged: (String? value) {
                                setState(() {
                                  isTyping = value!.isNotEmpty;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isTyping)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: state is! AppAddStatusLoadingState
                              ? IconButton(
                                  onPressed: () async {
                                    await AppCubit.get(context).addStatus(
                                        status: statusController.text,
                                        color: backgroundColor,
                                        name: AppCubit.get(context).user!.name,
                                        uId: AppCubit.get(context).user!.uId,
                                        image: AppCubit.get(context).user!.image);
                                    setState(() {
                                      isTyping = false;
                                      statusController.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: backgroundColor,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  color: backgroundColor,
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
