// lib/models/item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemType { lost, found }

enum ItemStatus { active, resolved }

class Item {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final String contactInfo;
  final List<String> imageUrls;
  final ItemType type;
  final ItemStatus status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.contactInfo,
    required this.imageUrls,
    required this.type,
    this.status = ItemStatus.active,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create a copy of this item with updated fields
  Item copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? date,
    String? contactInfo,
    List<String>? imageUrls,
    ItemType? type,
    ItemStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      contactInfo: contactInfo ?? this.contactInfo,
      imageUrls: imageUrls ?? this.imageUrls,
      type: type ?? this.type,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert Item to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': Timestamp.fromDate(date),
      'contactInfo': contactInfo,
      'imageUrls': imageUrls,
      'type': type.toString(),
      'status': status.toString(),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create Item from Firestore document
  factory Item.fromMap(Map<String, dynamic> map, String docId) {
    return Item(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      contactInfo: map['contactInfo'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      type: map['type'] == ItemType.lost.toString() ? ItemType.lost : ItemType.found,
      status: map['status'] == ItemStatus.resolved.toString()
          ? ItemStatus.resolved
          : ItemStatus.active,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}