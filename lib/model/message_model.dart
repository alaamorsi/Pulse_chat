import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  late String senderId;
  late String senderEmail;
  late String receiverId;
  late String message;
  late Timestamp time;
  String id='';
  late bool isMediaMessage;

  MessageModel({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.time,
    required this.isMediaMessage,
  });

  MessageModel.fromJson(Map<String, dynamic> json, String id) {
    senderId = json['senderId'];
    senderEmail = json['senderEmail'];
    receiverId = json['receiverId'];
    message = json['message'];
    time = json['time'];
    id = id;
    isMediaMessage = json['isMessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'time': time,
      'id': id,
      'isMessage': isMediaMessage,
    };
  }
}
