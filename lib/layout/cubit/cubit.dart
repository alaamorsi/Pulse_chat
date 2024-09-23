import 'dart:io';
import 'package:flutter/material.dart';
import 'package:talk_up/layout/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_up/model/message_model.dart';
import 'package:talk_up/model/status_model.dart';
import 'package:talk_up/model/user_model.dart';
import 'package:talk_up/modules/chat/chats_screen.dart';
import 'package:talk_up/modules/status/status_screen.dart';
import 'package:talk_up/shared/cache_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talk_up/shared/constant.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  // Manage bottom nav
  int currentIndex = 0;
  List<Widget> screens = [
    const ChatsScreen(),
    const StatusScreen(),
    // const CallScreen(),
  ];

  void changeBottomNav(int index) {
    currentIndex = index;
    if (index == 0) getUsers();

    if (index == 1) getAllStatuses();

    emit(AppChangeBottomNavState());
  }

  // Get User Data
  UserDataModel? user;

  Future<void> getUserData() async {
    emit(AppGetUserDataLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(CacheHelper.getData(key: 'uId'))
        .get()
        .then((value) {
      user = UserDataModel.fromJson(value.data()!);
      emit(AppGetUserDataSuccessState());
    }).catchError((error) {
      emit(AppGetUserDataErrorState());
    });
  }

  //Update user data
  Future<void> updateUserData({
    required String uId,
    String? name,
    String? email,
    String? image,
    String? about,
  }) async {
    Map<String, dynamic> updatedData = {};

    if (name != null) updatedData['name'] = name;
    if (email != null) updatedData['email'] = email;
    if (image != null) updatedData['image'] = image;
    if (about != null) updatedData['about'] = about;

    // Update user data
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .update(updatedData)
        .then((value) async {
      emit(AppUpdateUserSuccessState());

      // If name or image is updated, update all statuses as well
      if (name != null || image != null) {
        // Get all statuses for the user
        QuerySnapshot statusSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uId)
            .collection('status')
            .get();

        // Create a batch for updating statuses
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Loop through each status document and update it
        for (var statusDoc in statusSnapshot.docs) {
          if (name != null) {
            batch.update(statusDoc.reference, {'name': name});
          }
          if (image != null) {
            batch.update(statusDoc.reference, {'image': image});
          }
        }

        // Commit the batch update
        await batch.commit();
      }
    }).catchError((error) {
      emit(AppUpdateUserErrorState());
    });
  }


  List<UserDataModel> usersList = [];

  Future<void> getUsers() async {
    try {
      usersList = [];
      emit(AppGetUsersLoadingState());
      // Fetch the users from Firestore
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Map Firestore documents to a list of UserDataModel, excluding the current user
      usersList = querySnapshot.docs
          .where((doc) =>
              doc.id != CacheHelper.getData(key: 'uId')) // Exclude current user
          .map((doc) => UserDataModel.fromJson(doc.data()))
          .toList();
      emit(AppGetUsersSuccessState());
    } catch (error) {
      print(error.toString());
      emit(AppGetUsersErrorState());
      // Log error for debugging
      // Handle error appropriately, such as showing a message to the user
    }
  }

  MessageModel? messageModel;

// Send message
  Future<void> sendMessage(String receiverId, String message) async {
    emit(AppSendMessageLoadingState());
    final String currentUserID = CacheHelper.getData(key: 'uId');
    final String currentUserEmail = user!.email;
    final Timestamp timestamp = Timestamp.now();

    MessageModel messageModel = MessageModel(
      senderId: currentUserID,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      time: timestamp,
      isMediaMessage: false,
    );

    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Add message to Firestore
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageModel.toMap())
        .then((value) async {
      emit(AppSendMessageSuccessState());
    }).catchError((error) {
      emit(AppSendMessageErrorState());
    });
  }

  //Get messages
  List<MessageModel> messages = [];

  Stream<List<MessageModel>> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageModel.fromJson(data, doc.id);
            }).toList());
  }

  //Clear chat
  Future<void> clearChat(String userId, String otherUserId) async {
    // Sort user IDs to ensure the chatRoomId is the same for both users
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Get a reference to the messages collection
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages');

    // Fetch all messages in the chat room
    QuerySnapshot messageSnapshot = await messagesRef.get();

    // Batch delete all messages
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (QueryDocumentSnapshot doc in messageSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch to delete all messages
    await batch.commit().catchError((error) {
      print('Error clearing chat: $error');
    });
  }

  //Add status
  StatusModel? userStatusModel;

  Future<void> addStatus({
    required String status,
    required Color color,
    required String name,
    required String uId,
    required String image,
  }) async {
    emit(AppAddStatusLoadingState());
    StatusModel statusModel = StatusModel(
      status: status,
      uId: uId,
      image: image,
      color: color,
      name: name,
      time: Timestamp.now(),
      isMediaStatus: false,
      descriptionMediaStatus: '',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('status')
        .add(statusModel.toMap())
        .then((value) {
      print('Status added successfully');
      emit(AppAddStatusSuccessState());
    }).catchError((error) {
      print('Error adding status: $error');
      emit(AppAddStatusErrorState());
    });
  }

  //Get statuses
  Stream<List<StatusesModel>> getAllStatuses() {
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap((snapshot) async {
      List<StatusesModel> statusesList = [];

      // Loop through each user document
      for (var doc in snapshot.docs) {
        String uId = doc['uId'];
        String name = doc['name'];
        String image = doc['image'];
        Color color = Colors.orange;

        // Get the statuses for each user
        QuerySnapshot statusSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uId)
            .collection('status')
            .get();

        List<StatusModel> statuses = statusSnapshot.docs.map((statusDoc) {
          return StatusModel.fromJson(statusDoc.data() as Map<String, dynamic>);
        }).toList();

        // Only add user if they have statuses
        if (statuses.isNotEmpty) {
          statusesList.add(
            StatusesModel(
              statuses: statuses,
              uId: uId,
              name: name,
              image: image,
              color: color,
            ),
          );
        }
      }

      // Return the list of statuses; if none, return an empty list
      return statusesList.isNotEmpty ? statusesList : [];
    });
  }




//Pick file
  FilePickerResult? tryPickFile;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;

  Future<void> pickFile(
      {required bool isMediaMessage, required String receiverId}) async {
    emit(AppPickFileLoadingState());
    try {
      tryPickFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (tryPickFile != null) {
        fileName = tryPickFile!.files.first.name;
        pickedFile = tryPickFile!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
        print('File name = $fileName');
        if (isMediaMessage) {
          await uploadFileToFirebase(
              isMediaMessage: isMediaMessage,
              receiverId: receiverId,
              fileToUpload: pickedFile!,
              descriptionMediaStatus: '');
        }
        emit(AppPickFileSuccessState());
      }
    } catch (error) {
      print(error);
      emit(AppPickFileErrorState());
    }
  }

  //Upload the file
  Future<void> uploadFileToFirebase({
    required bool isMediaMessage,
    required String receiverId,
    required PlatformFile fileToUpload,
    required String descriptionMediaStatus,
  }) async {
    emit(AppUploadFileLoadingState());
    if (pickedFile == null) return;
    if (isMediaMessage) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'files/messages/$uId/${pickedFile!.name}'); // Include uId in the path
        await storageRef.putFile(File(pickedFile!.path!));
        String downloadUrl = await storageRef.getDownloadURL();
        // add the path in cloud firestore
        ////////////
        final String currentUserID = user!.uId;
        final String currentUserEmail = user!.email;
        final Timestamp timestamp = Timestamp.now();

        MessageModel messageModel = MessageModel(
          senderId: currentUserID,
          senderEmail: currentUserEmail,
          receiverId: receiverId,
          message: downloadUrl,
          time: timestamp,
          isMediaMessage: true,
        );

        List<String> ids = [currentUserID, receiverId];
        ids.sort();
        String chatRoomId = ids.join('_');

        // Add message to Firestore
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageModel.toMap())
            .then((value) async {
          print('File uploaded successfully: $downloadUrl');
          emit(AppUploadFileSuccessState());
          ////////////
        });
      } catch (e) {
        print('Failed to upload file: $e');
        emit(AppUploadFileErrorState());
      }
    }
    if (!isMediaMessage) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'files/statuses/$uId/${pickedFile!.name}'); // Include uId in the path
        await storageRef.putFile(File(pickedFile!.path!));
        String downloadUrl = await storageRef.getDownloadURL();
        // add the path in cloud firestore
        //////////
        StatusModel statusModel = StatusModel(
          status: downloadUrl,
          uId: CacheHelper.getData(key: 'uId'),
          image: user!.image,
          color: Colors.orange,
          name: user!.name,
          time: Timestamp.now(),
          isMediaStatus: true,
          descriptionMediaStatus: descriptionMediaStatus,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uId)
            .collection('status')
            .add(statusModel.toMap())
            .then((value) {
          print('Status added successfully');
          emit(AppUploadFileSuccessState());
        }).catchError((error) {
          print('Error adding status: $error');
          emit(AppUploadFileErrorState());
        });
        //////////
      } catch (e) {
        print('Failed to upload file: $e');
        emit(AppUploadFileErrorState());
      }
    }
  }

  //Search about users
  Future<List<UserDataModel>> searchAbout({
    required bool isSearchAboutUsers,
    required String searchQuery,
  }) async {
    if (isSearchAboutUsers) {
      // Clear the global usersList before fetching new data
      usersList = [];
      emit(AppSearchAboutUsersLoadingState()); // Emit loading state

      try {
        // Fetch the users from Firestore
        final querySnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        // Filter the users based on the search query and exclude the current user
        usersList = querySnapshot.docs
            .where((doc) =>
                doc.id !=
                CacheHelper.getData(key: 'uId')) // Exclude current user
            .map((doc) => UserDataModel.fromJson(doc.data()))
            .where((user) {
          final name = user.name.toLowerCase();
          final searchLower = searchQuery.toLowerCase();
          return name.contains(searchLower);
        }).toList();

        emit(
            AppSearchAboutUsersSuccessState()); // Emit success state after updating usersList
        return usersList; // Return the global usersList
      } catch (error) {
        print(error.toString()); // Log error for debugging
        emit(
            AppSearchAboutUsersErrorState()); // Emit error state if using Bloc/Cubit
        return [];
      }
    } else {
      return []; // Return an empty list if not searching about users
    }
  }

//Dark mode
  bool isDark = CacheHelper.getData(key: 'isDark') ?? false;

  changeMode(bool? mode) {
    if (mode != null) {
      isDark = mode;
      CacheHelper.saveData(key: 'isDark', value: isDark).then((value) {
        emit(AppChangeAppModeState());
      });
    }
  }

  //Theme
  Map<String, Color> canvasColors = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Orange': Colors.orange,
  };
  String? canvasColor = CacheHelper.getColor(key: 'canvasColor')?.value ==
          Colors.blue.value
      ? 'Blue'
      : CacheHelper.getColor(key: 'canvasColor')?.value == Colors.green.value
          ? 'Green'
          : CacheHelper.getColor(key: 'canvasColor')?.value ==
                  Colors.orange.value
              ? 'Orange'
              : 'Blue';

  void changeTheme(String? theme) {
    if (theme != null) {
      canvasColor = theme;
      // Save the color value as an integer (ARGB)
      CacheHelper.saveData(
              key: 'canvasColor', value: canvasColors[theme]!.value)
          .then((value) {
        canvasColorConstant = canvasColors[theme];
        emit(AppChangeThemeState());
      });
    }
  }
}
