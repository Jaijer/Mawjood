import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _lostItemsCollection =
  FirebaseFirestore.instance.collection('lost_items');
  final CollectionReference _foundItemsCollection =
  FirebaseFirestore.instance.collection('found_items');

  // Get collection based on item type
  CollectionReference _getCollection(ItemType type) {
    return type == ItemType.lost ? _lostItemsCollection : _foundItemsCollection;
  }

  // Get stream of items (lost or found)
  Stream<List<Item>> getItems(ItemType type) {
    return _getCollection(type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add an item
  Future<void> addItem(Item item) {
    return _getCollection(item.type).add(item.toMap());
  }

  // Update an item
  Future<void> updateItem(Item item) {
    return _getCollection(item.type).doc(item.id).update(item.toMap());
  }

  // Delete an item
  Future<void> deleteItem(Item item) {
    return _getCollection(item.type).doc(item.id).delete();
  }

  // Mark item as resolved
  Future<void> markItemAsResolved(Item item) {
    return _getCollection(item.type).doc(item.id).update({
      'status': ItemStatus.resolved.toString(),
    });
  }
}