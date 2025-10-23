import 'package:flutter/material.dart';

class FollowingShopsScreen extends StatefulWidget {
  const FollowingShopsScreen({super.key});

  @override
  State<FollowingShopsScreen> createState() => _FollowingShopsScreenState();
}

class _FollowingShopsScreenState extends State<FollowingShopsScreen> {
  // 🛍️ Enhanced mock followed shops data
  List<Map<String, dynamic>> followedShops = [
    {
      "id": "1",
      "name": "Infinity Boutique",
      "logo": "https://picsum.photos/200?random=1",
      "coverImage": "https://picsum.photos/400/200?random=10",
      "followers": "2.3k",
      "products": "124",
      "rating": 4.7,
      "category": "Fashion & Apparel",
      "isFollowing": true,
      "isLive": true,
      "lastActive": "2 hours ago",
    },
    {
      "id": "2",
      "name": "Campus Trends",
      "logo": "https://picsum.photos/200?random=2",
      "coverImage": "https://picsum.photos/400/200?random=11",
      "followers": "1.1k",
      "products": "89",
      "rating": 4.3,
      "category": "Student Fashion",
      "isFollowing": true,
      "isLive": false,
      "lastActive": "5 hours ago",
    },
    {
      "id": "3",
      "name": "Gadget Hub",
      "logo": "https://picsum.photos/200?random=3",
      "coverImage": "https://picsum.photos/400/200?random=12",
      "followers": "4.8k",
      "products": "256",
      "rating": 4.9,
      "category": "Electronics",
      "isFollowing": true,
      "isLive": true,
      "lastActive": "Live now",
    },
    {
      "id": "4",
      "name": "Book Haven",
      "logo": "https://picsum.photos/200?random=4",
      "coverImage": "https://picsum.photos/400/200?random=13",
      "followers": "900",
      "products": "67",
      "rating": 4.5,
      "category": "Books & Stationery",
      "isFollowing": true,
      "isLive": false,
      "lastActive": "1 day ago",
    },
    {
      "id": "5",
      "name": "Artisan Crafts",
      "logo": "https://picsum.photos/200?random=5",
      "coverImage": "https://picsum.photos/400/200?random=14",
      "followers": "1.5k",
      "products": "45",
      "rating": 4.8,
      "category": "Handmade",
      "isFollowing": false,
      "isLive": false,
      "lastActive": "3 days ago",
    },
  ];

  bool _showFollowingOnly = true;

  void toggleFollow(int index) {
    setState(() {
      followedShops[index]["isFollowing"] = !followedShops[index]["isFollowing"];
    });
  }

  void _unfollowAll() {
    setState(() {
      for (var shop in followedShops) {
        shop["isFollowing"] = false;
      }
    });
  }

  List<Map<String, dynamic>> get _filteredShops {
    if (_showFollowingOnly) {
      return followedShops.where((shop) => shop["isFollowing"] == true).toList();
    }
    return followedShops;
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = _filteredShops;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Followed Shops",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_showFollowingOnly && filteredShops.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFollowingOnly = !_showFollowingOnly;
              });
            },
            tooltip: 'Show all shops',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 🔘 Filter Chip Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(
                    'Following (${followedShops.where((shop) => shop["isFollowing"] == true).length})',
                  ),
                  selected: _showFollowingOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showFollowingOnly = selected;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.blue[50],
                  checkmarkColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _showFollowingOnly ? Colors.blue : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                    'All Shops (${followedShops.length})',
                  ),
                  selected: !_showFollowingOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showFollowingOnly = !selected;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.blue[50],
                  checkmarkColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: !_showFollowingOnly ? Colors.blue : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 📱 Shop List
          Expanded(
            child: filteredShops.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = filteredShops[index];
                      return _buildShopCard(shop, index);
                    },
                  ),
          ),
        ],
      ),

      // 🚀 Floating Action Button for bulk actions
      floatingActionButton: _showFollowingOnly && filteredShops.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _unfollowAll,
              icon: const Icon(Icons.person_remove, size: 20),
              label: const Text("Unfollow All"),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop, int originalIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Navigate to shop profile / showcase
          _navigateToShopProfile(shop);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Cover Image with Live Indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    shop["coverImage"],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                if (shop["isLive"] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            "LIVE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 📋 Shop Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎪 Logo with Verified Badge
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(shop["logo"]),
                        radius: 24,
                      ),
                      if (shop["rating"] >= 4.5)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // 📝 Shop Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              shop["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 16,
                            ),
                            Text(
                              shop["rating"].toString(),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shop["category"],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "${shop["followers"]} followers",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "•",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${shop["products"]} products",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shop["isLive"] ? "Live now" : "Active ${shop["lastActive"]}",
                          style: TextStyle(
                            color: shop["isLive"] ? Colors.red : Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔘 Follow Button
                  _buildFollowButton(shop, originalIndex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(Map<String, dynamic> shop, int originalIndex) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => toggleFollow(originalIndex),
          style: ElevatedButton.styleFrom(
            backgroundColor: shop["isFollowing"] ? Colors.grey[100] : Colors.blue,
            foregroundColor: shop["isFollowing"] ? Colors.grey[700] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: shop["isFollowing"] ? Colors.grey[300]! : Colors.blue,
              ),
            ),
            elevation: 0,
          ),
          child: Text(
            shop["isFollowing"] ? "Following" : "Follow",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        if (shop["isFollowing"])
          TextButton(
            onPressed: () {
              // Show shop showcase
              _showShopShowcase(shop);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(
              "View Shop",
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _showFollowingOnly 
                  ? "You're not following any shops yet"
                  : "No shops available",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showFollowingOnly
                  ? "Discover amazing shops and follow them to see their latest products here!"
                  : "Check back later for more shops",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_showFollowingOnly)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showFollowingOnly = false;
                  });
                },
                child: const Text("Explore Shops"),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToShopProfile(Map<String, dynamic> shop) {
    // Navigate to shop profile
    print("Navigating to ${shop["name"]} profile");
    // Navigator.pushNamed(context, '/shopProfile', arguments: shop);
  }

  void _showShopShowcase(Map<String, dynamic> shop) {
    // Show shop showcase
    print("Showing showcase for ${shop["name"]}");
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ShopShowcaseScreen(shop: shop)));
  }
}