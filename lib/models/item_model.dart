enum ItemType { lost, found }
enum ItemStatus { active, resolved }

class Item {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final List<String> imageUrls;
  final String userId;
  final String contactInfo;
  final ItemType type;
  final ItemStatus status;

  Item({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.imageUrls,
    required this.userId,
    required this.contactInfo,
    required this.type,
    this.status = ItemStatus.active,
  });

  // Convert Item to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': date.toIso8601String(),
      'imageUrls': imageUrls,
      'userId': userId,
      'contactInfo': contactInfo,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }

  // Create Item from Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      userId: map['userId'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      type: map['type'] == 'found' ? ItemType.found : ItemType.lost,
      status: map['status'] == 'resolved' ? ItemStatus.resolved : ItemStatus.active,
    );
  }

  // Create a copy of the item with some fields updated
  Item copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? date,
    List<String>? imageUrls,
    String? userId,
    String? contactInfo,
    ItemType? type,
    ItemStatus? status,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      imageUrls: imageUrls ?? this.imageUrls,
      userId: userId ?? this.userId,
      contactInfo: contactInfo ?? this.contactInfo,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}