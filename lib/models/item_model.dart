// lib/models/item_model.dart

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

  // Convert Item to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': date.toIso8601String(),
      'contact_info': contactInfo,
      'image_urls': imageUrls,
      'status': status == ItemStatus.active ? 'active' : 'resolved',
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create Item from Supabase data
  factory Item.fromMap(Map<String, dynamic> map, ItemType type) {
    return Item(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      contactInfo: map['contact_info'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      type: type,
      status: map['status'] == 'resolved' ? ItemStatus.resolved : ItemStatus.active,
      userId: map['user_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}