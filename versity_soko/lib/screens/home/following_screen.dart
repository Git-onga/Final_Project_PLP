import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:versity_soko/screens/shop/shop_detail_screen.dart';
import 'package:versity_soko/services/shop_follow_service.dart';

class FollowingShopsScreen extends StatefulWidget {
  const FollowingShopsScreen({super.key});

  @override
  State<FollowingShopsScreen> createState() => _FollowingShopsScreenState();
}

class _FollowingShopsScreenState extends State<FollowingShopsScreen> {
  // 🛍️ Enhanced mock followed shops data
  List<Map<String, dynamic>> followedShops = [];
  final ShopFollowService _shopFollowService = ShopFollowService();
  bool _showFollowingOnly = true;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool _loading = false;
  bool get loading => _loading;
  final SupabaseClient _supabase = Supabase.instance.client;
  // final followingProvider = Provider.of<FollowingProvider>(context, listen: false);

  void toggleFollow(int index) {
    setState(() {
      followedShops[index]["isFollowing"] = !followedShops[index]["isFollowing"];
    });
  }

  /// Fetch followed shops and set to followedShops
  Future<void> loadFollowedShops() async {
    print('Loading ....');
    try {
      setState(() {
        _loading = true;
      });

      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ No user logged in.");
        return;
      }

      // 1️⃣ Fetch list of followed shop IDs
      final List<String> shopIds =
          await _shopFollowService.fetchFollowedShops(userId: user.id);

      if (shopIds.isEmpty) {
        setState(() {
          followedShops = [];
        });
        return;
      }

      // 2️⃣ Use the service function for each shop ID
      final List<Map<String, dynamic>> shopDetails = [];

      for (String shopId in shopIds) {
        final details = await _shopFollowService.getFollowedShopDetails(
          userId: user.id,
          shopId: shopId,
        );

        if (details != null) {
          shopDetails.add(details);
        }
      }

      // 3️⃣ Update state
      setState(() {
        followedShops = shopDetails;
      });

      print('... Loading Complete');
      print(followedShops);
    } catch (e) {
      debugPrint("❌ Error loading followed shops: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }



  void initState() {
    super.initState();
    loadFollowedShops();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Followed Shops",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
        iconTheme:  IconThemeData(color: isDark ? Colors.grey[300] : Colors.black),
        
      ),
      backgroundColor: isDark? Colors.black : Colors.grey[50],
      body: ListView.builder(
        itemCount: followedShops.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return _buildShopCard(index);
        },
      )
    );

      
  }

  Widget _buildShopCard(int index) {
    final shop = followedShops[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E1A33), Color(0xFF2C254A)]
              : const [Color(0xFFF1EEF6), Color(0xFFE1E6F4)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        onTap: () => _navigateToShopProfile(shop),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Shop Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                shop["image_url"] ?? "",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.store, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),

            // 📋 Shop Info Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏪 Shop Icon / Avatar
                  CircleAvatar(
                    backgroundImage: NetworkImage(shop["image_url"] ?? ""),
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),

                  // 📝 Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔤 Name + Category
                        Text(
                          shop["name"] ?? "Unnamed Shop",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop["category"] ?? "Unknown Category",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // 👥 Followers + Delivery
                        Row(
                          children: [
                            Icon(Icons.people, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              "${shop["followers"] ?? 0} followers",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.local_shipping,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (shop["delivery"] ?? false)
                                    ? "Delivery available"
                                    : "No delivery",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 🕒 Business Hours
                        if (shop["business_hours"] != null)
                          Text(
                            "Open: ${shop["business_hours"]["open_time"] ?? 'N/A'} - ${shop["business_hours"]["close_time"] ?? 'N/A'}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),

                        const SizedBox(height: 6),

                        // 💳 Payment Method
                        if (shop["payment_methods"] != null)
                          Text(
                            "Payment: ${shop["payment_methods"]["method"] ?? 'N/A'} (${shop["payment_methods"]["paybill_number"] ?? ''})",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // 🔘 Follow/Unfollow Button
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShopDetailScreen(shopId: shop['id']),
                          ),
                        );
                      },
                      child: const Text(
                        "View Shop",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  // Widget _buildFollowButton(Map<String, dynamic> shop, int originalIndex) {
  //   return Column(
  //     children: [
  //       ElevatedButton(
  //         onPressed: () => toggleFollow(originalIndex),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: shop["isFollowing"] ? Colors.grey[100] : Colors.blue,
  //           foregroundColor: shop["isFollowing"] ? Colors.grey[700] : Colors.white,
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //             side: BorderSide(
  //               color: shop["isFollowing"] ? Colors.grey[300]! : Colors.blue,
  //             ),
  //           ),
  //           elevation: 0,
  //         ),
  //         child: Text(
  //           shop["isFollowing"] ? "Following" : "Follow",
  //           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  //         ),
  //       ),
  //       // if (shop["isFollowing"])
  //         TextButton(
  //           onPressed: () {
  //             // Show shop showcase
  //             _showShopShowcase(shop);
  //           },
  //           style: TextButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //             minimumSize: Size.zero,
  //           ),
  //           child: Text(
  //             "View Shop",
  //             style: TextStyle(
  //               color: Colors.blue[600],
  //               fontSize: 10,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

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