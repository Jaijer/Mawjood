import 'package:flutter/material.dart';
import 'package:mawjood/models/item_model.dart';
import 'package:mawjood/services/supabase_service.dart';
import 'package:mawjood/screens/items/item_details_screen.dart';
import 'package:mawjood/screens/items/edit_item_screen.dart';
import 'package:mawjood/components/theme2.dart';  // Import theme for consistent styling

class ItemsList extends StatefulWidget {
  final ItemType itemType;

  const ItemsList({Key? key, required this.itemType}) : super(key: key);

  @override
  State<ItemsList> createState() => ItemsListState();
}

class ItemsListState extends State<ItemsList>
    with AutomaticKeepAliveClientMixin {
  final SupabaseService _supabaseService = SupabaseService();
  late Stream<List<Item>> _itemsStream;
  final ValueNotifier<bool> _refreshTrigger = ValueNotifier<bool>(false);

  // ── NEW: Search & Filter State ─────────────────────
  String _searchQuery = '';
  String? _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Documents',
    'Clothing',
    'Keys',
    'Bags',
    'Other',
  ];

  // Public methods to refresh
  void refreshItems() => _refreshItems();
  void refreshList() => refreshItems();

  @override
  bool get wantKeepAlive => true; // Keep state across tabs

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _itemsStream = _supabaseService.getItems(widget.itemType);
  }

  Future<void> _refreshItems() async {
    _refreshTrigger.value = !_refreshTrigger.value;
    setState(_initStream);
    return Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: context.backgroundDecoration,
      child: ValueListenableBuilder<bool>(
        valueListenable: _refreshTrigger,
        builder: (context, _, __) {
          return Column(
            children: [
              // ── SEARCH & FILTER UI ───────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Search field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by title…',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (q) =>
                            setState(() => _searchQuery = q.trim().toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Category',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          prefixIcon: Icon(Icons.category),
                      ),
                        isExpanded: true,
                        value: _selectedCategory,
                        items: [
                          DropdownMenuItem(value: '', child: Text('All')),
                          ..._categories.map(
                                (c) => DropdownMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                        onChanged: (cat) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── ITEM LIST (with pull-to-refresh) ───────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshItems,
                  child: StreamBuilder<List<Item>>(
                    stream: _itemsStream,
                    builder: (context, snapshot) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      // Error state
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading data:\n${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _refreshItems,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final allItems = snapshot.data ?? [];

                      // ── IN-MEMORY FILTERING ───────────────────
                      final filtered = allItems.where((item) {
                        final matchesSearch = item.title
                            .toLowerCase()
                            .contains(_searchQuery);
                        final matchesCategory = _selectedCategory == null ||
                            _selectedCategory!.isEmpty ||
                            item.category == _selectedCategory;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      // Empty state
                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.itemType == ItemType.lost
                                    ? Icons.search_off
                                    : Icons.help_outline,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No items match “$_searchQuery”'
                                    : (widget.itemType == ItemType.lost
                                    ? 'No lost items reported yet'
                                    : 'No found items reported yet'),
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to add an item!',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      // Data loaded: show filtered list
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildItemCard(context, item);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── YOUR ORIGINAL CARD & NAVIGATION LOGIC ─────────
  Widget _buildItemCard(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetails(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.imageUrls.first,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, prog) =>
                  prog == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (ctx, e, st) => Container(
                    color: Colors.grey[200],
                    height: 180,
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.location} • ${item.date.day}/${item.date.month}/${item.date.year}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _navigateToEdit(context, item),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _confirmDelete(context, item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, Item item) async {
    final needsRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
    );
    if (needsRefresh == true) _refreshItems();
  }

  void _navigateToEdit(BuildContext context, Item item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
    );
    if (result == true) _refreshItems();
  }

  Future<void> _confirmDelete(BuildContext context, Item item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _supabaseService.deleteItem(item);
        _refreshItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting item: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
