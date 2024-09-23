import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/cubit.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:talk_up/layout/home_screen.dart';
import 'package:talk_up/model/message_model.dart';
import 'package:talk_up/modules/chat/view_contact_screen.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:talk_up/shared/components.dart';
import 'package:talk_up/shared/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String name;
  final String image;
  final String about;
  final String receiverId;

  const ChatDetailsScreen({
    super.key,
    required this.name,
    required this.image,
    required this.receiverId,
    required this.about,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  TextEditingController typingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  bool isExpanded = false;
  String? lastMessageContent;
  bool _isInitialScroll = true; // Flag to track initial scroll
  late final FirebaseMessaging firebaseMessaging;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to the bottom after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    typingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppSendMessageSuccessState) {
          _scrollToBottom(); // Scroll when message is sent
          return;
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            cubit.getUsers();
            navigateAndFinish(context, const HomeScreen());
            return true;
          },
          child: Scaffold(
            appBar: defaultAppBar(
              arrowBackFunction: () {
                cubit.getUsers();
                navigateAndFinish(context, const HomeScreen());
              },
              isChat: true,
              image: widget.image,
              theme: theme,
              title: widget.name,
              moreFunction: PopupMenuButton<String>(
                color: theme.scaffoldBackgroundColor,
                position: PopupMenuPosition.under,
                icon: Icon(Icons.more_vert, color: theme.secondaryHeaderColor),
                onSelected: (String result) {
                  switch (result) {
                    case 'View contact':
                      {
                        navigateTo(
                            context,
                            ViewContactScreen(
                              name: widget.name,
                              image: widget.image,
                              receiverId: widget.receiverId,
                              isImage: widget.image.isNotEmpty,
                              about: widget.about,
                            ));
                      }
                      break;
                    case 'Clear chat':
                      {
                        cubit.clearChat(cubit.user!.uId, widget.receiverId);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'View contact',
                    child: Row(
                      children: [
                        Text(
                          'View contact',
                          style: TextStyle(color: theme.secondaryHeaderColor),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Clear chat',
                    child: Row(
                      children: [
                        Text(
                          'Clear chat',
                          style: TextStyle(color: theme.secondaryHeaderColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: StreamBuilder<List<MessageModel>>(
                      stream: AppCubit.get(context).getMessages(
                          CacheHelper.getData(key: 'uId'), widget.receiverId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return Container(); // Show nothing while waiting
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading messages',
                              style:
                                  TextStyle(color: theme.secondaryHeaderColor),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No messages yet',
                              style:
                                  TextStyle(color: theme.secondaryHeaderColor),
                            ),
                          );
                        }

                        if (_isInitialScroll) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                            _isInitialScroll =
                                false; // Prevent further initial scrolls
                          });
                        } else if (lastMessageContent !=
                            snapshot.data!.last.message) {
                          lastMessageContent = snapshot.data!.last.message;
                          _scrollToBottom(); // Scroll for new messages
                        }

                        return ListView.separated(
                          controller: _scrollController,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 70.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) => buildItemMessage(
                            snapshot.data![index],
                            snapshot.data![index].senderId ==
                                    CacheHelper.getData(key: 'uId')
                                ? CacheHelper.getData(key: 'uId')
                                : widget.receiverId,
                          ),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15.0),
                          itemCount: snapshot.data!.length,
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 60.0,
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          width: 0.5,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(color: theme.primaryColor),
                            textInputAction: TextInputAction.newline,
                            controller: typingController,
                            cursorColor: theme.primaryColor,
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
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Message...',
                              hintStyle: TextStyle(color: theme.primaryColor),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: IconButton(
                                  onPressed: () {
                                    cubit.pickFile(
                                        isMediaMessage: true,
                                        receiverId: widget.receiverId);
                                  },
                                  icon:
                                      const Icon(Icons.add_photo_alternate_outlined),
                                  color: theme.primaryColor,
                                ),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              filled: true,
                              fillColor: theme.canvasColor,
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: theme.primaryColor, width: 2.0),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                        if (isTyping)
                          Row(
                            children: [
                              const SizedBox(width: 10.0),
                              Container(
                                width: 45.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.canvasColor,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    await cubit.sendMessage(widget.receiverId,
                                        typingController.text);
                                    typingController.clear();
                                    setState(() {
                                      isTyping = false;
                                    });
                                    _scrollToBottom(); // Scroll when message is sent
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildItemMessage(MessageModel item, String fromWho) {
    String time = formatTime(item.time);
     isExpanded = isExpanded;

    return fromWho == CacheHelper.getData(key: 'uId')
        ? item.isMediaMessage
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: screenWidth / 2,
                    height: screenHeight / 3,
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12.0),
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        )),
                    child: Container(
                      alignment: Alignment.bottomRight,
                      width: screenWidth / 2,
                      height: screenHeight / 3,
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                            image: NetworkImage(item.message),
                            fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          time,
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    constraints: BoxConstraints(
                        minHeight: 60.0,
                        minWidth: 130.0,
                        maxWidth: MediaQuery.of(context).size.width * 0.66),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 70.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.message,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                maxLines: isExpanded ? null : 1,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (item.message.length > 100)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        isExpanded ? 'Read less' : 'Read more',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: Theme.of(context).primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
        : item.isMediaMessage
            ? Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    width: screenWidth / 2,
                    height: screenHeight / 3,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12.0),
                          topLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        )),
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      width: screenWidth / 2,
                      height: screenHeight / 3,
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                            image: NetworkImage(item.message),
                            fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          time,
                          style: TextStyle(
                              fontSize: 10.0,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    constraints: BoxConstraints(
                        minHeight: 60.0,
                        minWidth: 130.0,
                        maxWidth: MediaQuery.of(context).size.width * 0.66),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 70.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.message,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                maxLines: isExpanded ? null : 1,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (item.message.length > 100)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Text(
                                    'Read more',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }
}
