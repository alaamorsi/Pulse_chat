import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget widget;

  const MyButton({super.key, required this.onPressed, required this.widget});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Theme.of(context).canvasColor),
          fixedSize: WidgetStateProperty.all(const Size(double.infinity, 60.0)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(
                  width: 1.0, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        child: widget,
      ),
    );
  }
}
