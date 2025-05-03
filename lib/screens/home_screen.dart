// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../screens/items/add_item_screen.dart';
import '../models/item_model.dart';
import '../screens/items/items_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      appBar: AppBar(
        title: const Text('KFUPM Lost & Found'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lost Items'),
            Tab(text: 'Found Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Lost Items Tab
          ItemsList(itemType: ItemType.lost),
          // Found Items Tab
          ItemsList(itemType: ItemType.found),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(
              itemType: _tabController.index == 0 ? ItemType.lost : ItemType.found,
            )),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}