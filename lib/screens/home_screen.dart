import 'package:flutter/material.dart';
import '../screens/items/add_item_screen.dart';
import '../models/item_model.dart';
import '../screens/items/items_list.dart';
import '../components/theme2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Keys to access the ItemsList widgets
  final GlobalKey<ItemsListState> _lostItemsKey = GlobalKey<ItemsListState>();
  final GlobalKey<ItemsListState> _foundItemsKey = GlobalKey<ItemsListState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: context.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('KFUPM Lost & Found'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Lost Items'),
                Tab(text: 'Found Items'),
              ],
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ItemsList(key: _lostItemsKey, itemType: ItemType.lost),
              ItemsList(key: _foundItemsKey, itemType: ItemType.found),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                itemType: _tabController.index == 0 ? ItemType.lost : ItemType.found,
              ),
            ),
          );

          // Refresh list when returning from add screen
          if (result == true && mounted) {
            // Refresh the active tab
            if (_tabController.index == 0) {
              _lostItemsKey.currentState?.refreshItems();
            } else {
              _foundItemsKey.currentState?.refreshItems();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item added successfully')),
            );
          }
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}