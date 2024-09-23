import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/model/message_model.dart';
import 'package:talk_up/model/user_model.dart';
import 'package:talk_up/modules/chat/chat_details_screen.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:talk_up/shared/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: state is! AppGetUsersLoadingState? ListView.separated(
                        itemBuilder: (context, index) => buildChatItem(
                            theme, context, cubit.usersList[index]),
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 20.0,
                        ),
                        itemCount: cubit.usersList.length,
                      ) : Center(child: CircularProgressIndicator(color: theme.canvasColor,)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildChatItem(
    ThemeData theme,
    BuildContext context,
    UserDataModel item,
  ) {
    String lastMessage = '';
    return InkWell(
      onTap: () {
        AppCubit.get(context)
            .getMessages(CacheHelper.getData(key: 'uId'), item.uId);
        navigateTo(
          context,
          ChatDetailsScreen(
            name: item.name,
            image: item.image,
            about: item.about,
            receiverId: item.uId,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 73.0,
            height: 73.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.canvasColor,
            ),
            child: Container(
              width: 60.0,
              height: 60.0,
              margin: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: item.image != ''
                    ? DecorationImage(
                        image: NetworkImage(item.image), fit: BoxFit.cover)
                    : null,
              ),
              child: item.image == ''
                  ? Icon(
                      Icons.person,
                      size: 50.0,
                      color: theme.secondaryHeaderColor,
                    )
                  : null,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: theme.secondaryHeaderColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamBuilder<List<MessageModel>>(
                    stream: AppCubit.get(context).getMessages(
                      CacheHelper.getData(key: 'uId'),
                      item.uId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading...',
                          style: TextStyle(
                            color: theme.secondaryHeaderColor.withOpacity(0.8),
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text(
                          'No messages yet',
                          style: TextStyle(
                            color: theme.secondaryHeaderColor.withOpacity(0.8),
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                      lastMessage = snapshot.data!.last.message;

                      return Row(
                        children: [
                          snapshot.data!.last.isMediaMessage
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      color: theme.secondaryHeaderColor,
                                      size: 20.0,
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      'Photo',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: theme.secondaryHeaderColor),
                                    )
                                  ],
                                )
                              : Expanded(
                                  child: Text(
                                    lastMessage,
                                    // Assuming `message` is the content of the message
                                    style: TextStyle(
                                      color: theme.secondaryHeaderColor
                                          .withOpacity(0.8),
                                      fontSize: 14.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
