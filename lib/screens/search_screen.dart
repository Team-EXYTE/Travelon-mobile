import 'package:flutter/material.dart';
import '../data_model/event_model.dart';
import '../screens/event_detail_screen.dart';
import '../services/firebase_service.dart';
import '../widgets/safe_scrollable.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  List<Event> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;
  List<String> recentSearches = [];
  List<Event> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    try {
      setState(() {
        isLoading = true;
      });

      final events = await _firebaseService.getAllEvents();

      setState(() {
        _allEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading events for search: $e");
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    _performSearch(_searchController.text);
  }

  void _performSearch(String query) {
    final searchQuery = query.toLowerCase();
    final results =
        _allEvents.where((event) {
          return event.title.toLowerCase().contains(searchQuery) ||
              event.description.toLowerCase().contains(searchQuery) ||
              event.category.toLowerCase().contains(searchQuery) ||
              event.location.toLowerCase().contains(searchQuery);
        }).toList();

    setState(() {
      searchResults = results;
    });
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isNotEmpty && !recentSearches.contains(query.trim())) {
      setState(() {
        recentSearches.insert(0, query.trim());
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
      });
    }
  }

  Widget _eventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => EventDetailScreen(
                  imagePath: event.imagePath,
                  title: event.title,
                  price: event.price,
                  event: event,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                event.imagePath.startsWith('http')
                    ? Image.network(
                      event.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                    : Image.asset(
                      event.imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
          ),
          title: Text(
            event.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.location,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: FirebaseService.getCategoryColorByName(
                          event.category,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: FirebaseService.getCategoryColorByName(
                            event.category,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (event.isEnded)
                    const Text(
                      'Ended',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
          trailing: Text(
            event.price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentSearchItem(String search) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(search),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () {
          setState(() {
            recentSearches.remove(search);
          });
        },
      ),
      onTap: () {
        _searchController.text = search;
        _performSearch(search);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onSubmitted: (query) {
              _addToRecentSearches(query);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          if (!isSearching && recentSearches.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...recentSearches.map((search) => _recentSearchItem(search)),
          ],
          if (isLoading) ...[
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ] else if (isSearching) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      searchResults.isEmpty
                          ? 'No results found'
                          : '${searchResults.length} result${searchResults.length == 1 ? '' : 's'} found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _loadAllEvents().then(
                        (_) => _performSearch(_searchController.text),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  searchResults.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : SafeScrollable(
                        heightFactor: 0.6,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return _eventCard(searchResults[index]);
                          },
                        ),
                      ),
            ),
          ],
          if (!isSearching && recentSearches.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Search for events',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find events by name, category, or location',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
