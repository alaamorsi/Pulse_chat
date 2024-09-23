import 'package:flutter/material.dart';
import 'package:talk_up/modules/chat/chat_details_screen.dart';
import 'package:talk_up/shared/components.dart';

class ViewContactScreen extends StatelessWidget {
  final String name;
  final String image;
  final String about;
  final String receiverId;
  final bool isImage;
  const ViewContactScreen({super.key, required this.name, required this.image, required this.receiverId, required this.isImage, required this.about});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: defaultAppBar(
        arrowBackFunction: (){
          navigateTo(context, ChatDetailsScreen(name: name, image: image, receiverId: receiverId, about: about,));
        },
        theme: theme,
        title: name,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 180.0,
                  height: 180.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.canvasColor
                  ),
                  child: isImage ? Container(
                    width: 180.0,
                    height: 180.0,
                    margin: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                          image: NetworkImage(image),
                    ),
                  ),
                                  ): Icon(Icons.person,size: 100.0,color: theme.secondaryHeaderColor,),
                )],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Center(
                child: Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21.0,
                  color: theme.secondaryHeaderColor),
            )),
            const SizedBox(height: 10.0,),
            Container(
              width: double.infinity,
              height: 3.0,
              color: theme.canvasColor,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text('About',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: theme.secondaryHeaderColor),),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(about,style: TextStyle(fontSize: 21.0,color: theme.secondaryHeaderColor),)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
