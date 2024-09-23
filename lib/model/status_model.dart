import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  late String status;
  late String uId;
  late String image;
  late Color color;
  late String name;
  late Timestamp time;
  late bool isMediaStatus;
  late String descriptionMediaStatus;

  StatusModel({
    required this.status,
    required this.uId,
    required this.image,
    required this.color,
    required this.name,
    required this.time,
    required this.isMediaStatus,
    required this.descriptionMediaStatus,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      status: json['status'] ?? '',
      uId: json['uId'] ?? '',
      image: json['image'] ?? '',
      color: json['color'] != null ? intToColor(json['color']) : Colors.cyan,
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      isMediaStatus: json['isMediaStatus'] ?? false,
      descriptionMediaStatus: json['descriptionMediaStatus'] ?? '',
    );
  }

  // Convert Color to int before storing it
  static int colorToInt(Color color) {
    return color.value;
  }

  // Convert int back to Color after retrieving it
  static Color intToColor(int colorValue) {
    return Color(colorValue);
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'uId': uId,
      'image': image,
      'color': colorToInt(color), // Store color as int
      'name': name,
      'time': time,
      'isMediaStatus': isMediaStatus,
      'descriptionMediaStatus': descriptionMediaStatus,
    };
  }
}

class StatusesModel {
  final List<StatusModel> statuses;
  final String uId;
  final String image;
  final Color color;
  final String name;

  StatusesModel({
    required this.statuses,
    required this.uId,
    required this.image,
    required this.color,
    required this.name,
  });

  factory StatusesModel.fromUserJson(
      Map<String, dynamic> json, List<StatusModel> statuses) {
    return StatusesModel(
      statuses: statuses,
      uId: json['uId'] ?? '',
      image: json['image'] ?? '',
      color: json['color'] != null
          ? StatusModel.intToColor(json['color'])
          : Colors.cyan,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statuses': statuses.map((status) => status.toMap()).toList(),
      'uId': uId,
      'image': image,
      'color': StatusModel.colorToInt(color), // Store color as int
      'name': name,
    };
  }
}
