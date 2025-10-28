import 'package:flutter/material.dart';
import 'package:versity_soko/models/shop_model.dart';
import 'package:versity_soko/screens/shop/cart_screen.dart';
import '../home/home_screen.dart';
import '../shop/shop_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {

	@override
	Widget build(BuildContext context) {
		return Scaffold(
		backgroundColor: Colors.white,
		body: SingleChildScrollView(
      child: SafeArea(
        child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildAppBar(),

						// Search Bar
						_buildSearchBar(),
						
						// Filter Tags
						_buildFilterTags(),
						
						// Top Shops Section
						_buildTopShopsSection(),

						// Shop Grid
						_buildShopGridSection(),
					],
				),
      )
			
			),
      // bottomNavigationBar: CustomBottomNavBar(
			// 	currentIndex: 0,
			// 	onTap: (index) {
			// 	switch (index) {
			// 		case 0:
			// 		Navigator.pushNamed(context, '/home');
			// 		case 1:
			// 		Navigator.pushNamed(context, '/shops');
			// 		break;
			// 		case 2:
			// 		Navigator.pushNamed(context, '/create');
			// 		break;
			// 		case 3:
			// 		Navigator.pushNamed(context, '/community');
			// 		break;
			// 		case 4:
			// 		Navigator.pushNamed(context, '/message');
			// 	}
			// 	},
			// ),
		);
	}

	Widget _buildAppBar() {
		return SafeArea(
      child: Padding(
        padding:  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Marketplace',
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              ),
            ),
            Spacer(),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              },
            ),
            
          ],
        ),
      )
    );
	}

	Widget _buildSearchBar() {
		return Container(
			height: 50,
			margin: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
			decoration: BoxDecoration(
			color: Colors.grey[50],
			borderRadius: BorderRadius.circular(12),
			border: Border.all(
				color: Colors.grey[200]!,
			),
			),
			child: Row(
			children: [
				const SizedBox(width: 16),
				Icon(
				Icons.search,
				color: Colors.grey[500],
				size: 20,
				),
				const SizedBox(width: 12),
				Expanded(
				child: TextField(
					decoration: InputDecoration(
					hintText: 'Search products, shops...',
					hintStyle: TextStyle(
						color: Colors.grey[500],
					),
					border: InputBorder.none,
					),
				),
				),
				const SizedBox(width: 16),
			],
			),
		);
	}

	Widget _buildFilterTags() {
		final categories = [
		'All Categories',
		'Clothes',
		'Make-up Accessories',
		'Electronics',
		'Books',
		'Food & Drinks',
		'Stationery',
		];

		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16.0, ),
			child: SizedBox(
				height: 25,
				child: ListView(
					scrollDirection: Axis.horizontal,
					children: [
						const SizedBox(width: 4),
						...List.generate(categories.length, (index) {
							return Container(
								margin: const EdgeInsets.symmetric(horizontal: 2.0),
								child: ElevatedButton(
									onPressed: () {},
									style: ElevatedButton.styleFrom(
										backgroundColor: index == 0 ? Colors.blue : Colors.white,
										foregroundColor: index == 0 ? Colors.white : Colors.grey[700],
										elevation: 0,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(20),
											side: BorderSide(
												color: index == 0 ? Colors.blue : Colors.grey[300]!,
											),
										),
										padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
									),
									child: Text(
										categories[index],
										style: TextStyle(
											fontSize: 10,
											fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
										),
									),
								),
							);
						}),
					const SizedBox(width: 4),
					],
				),
			),
		) ;
	}

	Widget _buildTopShopsSection() {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
				// Section Title
				Text(
					'Top Shops',
					style: TextStyle(
					fontSize: 15,
					fontWeight: FontWeight.bold,
					color: Colors.grey[800],
					),
				),
				
				const SizedBox(height: 16),
				
				// Horizontal Scrollable Shops
				SizedBox(
					height: 200,
					child: ListView(
					scrollDirection: Axis.horizontal,
					children: const [
						SizedBox(width: 4),
						TopShopCard(
						shopName: 'The Campus Bistro',
						description: 'Your go-to for quick bites, gourmet coffee, and study snacks. Freshly made daily!',
						imageUrl: 'https://picsum.photos/200/150?random=1',
						),
						SizedBox(width: 12),
						TopShopCard(
						shopName: 'Tech Hub',
						description: 'Latest gadgets, accessories and electronics for students at campus prices.',
						imageUrl: 'https://picsum.photos/200/150?random=2',
						),
						SizedBox(width: 12),
						TopShopCard(
						shopName: 'Style Studio',
						description: 'Trendy clothes and accessories for the fashionable campus student.',
						imageUrl: 'https://picsum.photos/200/150?random=3',
						),
						SizedBox(width: 12),
						TopShopCard(
						shopName: 'Book Nook',
						description: 'Textbooks, novels, and stationery for all your academic needs.',
						imageUrl: 'https://picsum.photos/200/150?random=4',
						),
						SizedBox(width: 4),
					],
					),
				),
				],
			),
		); 
	}

	Widget _buildShopGridSection() {
		return Padding(
			padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'All Shops',
						style: TextStyle(
							fontSize: 15,
							fontWeight: FontWeight.bold,
							color: Colors.grey[800],
						),
					),
          const SizedBox(height: 16),
					GridView.count(
						crossAxisCount: 2,
						childAspectRatio: 0.8,
						crossAxisSpacing: 4,
						mainAxisSpacing: 4,
						shrinkWrap: true,
						children: const [
						ShopCard(
							shopName: "Infinity Boutique",
							rating: 5.3,
							productImages: [
								"https://picsum.photos/200/150?random=4",
								"https://picsum.photos/200/150?random=5",
							],
							isVerified: true,
						),
						ShopCard(
							shopName: "Infinity Boutique",
							rating: 5.3,
							productImages: [
								"https://picsum.photos/200/150?random=4",
								"https://picsum.photos/200/150?random=5",
							],
							isDelivery: true,
							isVerified: true,
						),
						ShopCard(
							shopName: "Infinity Boutique",
							rating: 5.3,
							productImages: [
								"https://picsum.photos/200/150?random=4",
								"https://picsum.photos/200/150?random=5",
							],
							isDelivery: true,
						),
						ShopCard(
							shopName: "Infinity Boutique",
							rating: 5.3,
							productImages: [
								"https://picsum.photos/200/150?random=4",
								"https://picsum.photos/200/150?random=5",
							],
							isVerified: true,
						),
						],
					)
				
				],
			),
		); 
		
	}
}

class TopShopCard extends StatelessWidget {
	final String shopName;
	final String description;
	final String imageUrl;

	const TopShopCard({
		super.key,
		required this.shopName,
		required this.description,
		required this.imageUrl,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 280,
			height: 200, // 👈 give it a height
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(16),
				image: DecorationImage(
				image: NetworkImage(imageUrl),
				fit: BoxFit.cover,
				),
				boxShadow: [
				BoxShadow(
					color: Colors.grey.withOpacity(0.1),
					blurRadius: 8,
					offset: const Offset(0, 2),
				),
				],
			),
			child: ClipRRect(
				borderRadius: BorderRadius.circular(16),
				child: Stack(
					children: [
						// Semi-transparent overlay for bottom half
						Align(
						alignment: Alignment.bottomCenter,
						child: Container(
							height: 120, // 👈 bottom half (adjust as needed)
							width: double.infinity,
							decoration: BoxDecoration(
							color: Colors.black.withOpacity(0.6), // semi-transparent
							),
							padding: const EdgeInsets.all(12),
							child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								// Shop Name
								Text(
									shopName,
									style: const TextStyle(
										fontSize: 14,
										fontWeight: FontWeight.bold,
										color: Colors.white,
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
								const SizedBox(height: 6),
								// Description
								Text(
								description,
								style: const TextStyle(
									fontSize: 12,
									color: Colors.white70,
									height: 1.4,
								),
								maxLines: 2,
								overflow: TextOverflow.ellipsis,
								),
								const Spacer(),
								// Explore Button
								SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: () {
									// Navigate to shop detail
									},
									style: ElevatedButton.styleFrom(
									backgroundColor: Colors.blue,
									foregroundColor: Colors.white,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(8),
									),
									padding: const EdgeInsets.symmetric(vertical: 8),
									),
									child: const Text(
									'Explore Shop',
									style: TextStyle(
										fontSize: 12,
										fontWeight: FontWeight.w600,
									),
									),
								),
								),
							],
							),
						),
						),
					],
				),
			),
		);
	}
}

class ShopCard extends StatelessWidget {
	// final String shopUrl;
	final String shopName;
	final double rating;
	final List<String> productImages;
	final bool isDelivery;
	final bool isVerified;
  
  // ShopModel shop;

	const ShopCard({
		super.key,
		// required this.shopUrl,
		required this.shopName,
		required this.rating,
		required this.productImages,
		this.isDelivery = false,
		this.isVerified = false,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 170,
      height: 300,
			margin: const EdgeInsets.all(4),
			padding: const EdgeInsets.all(7.5),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.grey.shade300),
				color: Colors.white,
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Shop name + rating
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Stack(
								alignment: Alignment.center,
								children: [
								// Gradient border for new content
								Container(
								width: 40,
								height: 40,
								decoration: BoxDecoration(
									color:Color(0xFF833AB4),
									shape: BoxShape.circle,
								),
								child: Padding(
									padding: const EdgeInsets.all(2.0),
									child: Container(
										decoration: BoxDecoration(
											color: Colors.white,
											shape: BoxShape.circle,
										),
										child: Padding(
											padding: const EdgeInsets.all(2.0),
											child: _buildShopAvatar(),
										),
									),
								),
								)
							
								],
							),
							SizedBox(width: 10),
							Expanded(
								child: Text(
									shopName,
									style: const TextStyle(
									fontSize: 10,
									fontWeight: FontWeight.bold,
									),
									maxLines: 2,
									softWrap: true,
									overflow: TextOverflow.visible,
								),
							),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
								decoration: BoxDecoration(
									color: Colors.amber.shade100,
									borderRadius: BorderRadius.circular(12),
								),
								child: Row(
									children: [
										const Icon(Icons.star,
											size: 10, color: Colors.orange),
										Text(
										rating.toString(),
										style: const TextStyle(
											fontSize: 12,
											fontWeight: FontWeight.w600,
											color: Colors.orange,
										),
										),
									],
								),
							),
						],
					),
					const SizedBox(height: 10),
					SizedBox(
						width: double.infinity,              // Thickness of the line
						height: 1,            // Height of the line
						child: DecoratedBox(
							decoration: BoxDecoration(color: Colors.grey.shade300),
						),
					),
					const SizedBox(height: 10),
					// Badges (delivery, verified)
					Row(
						children: [
							if (isDelivery)
								Container(
									padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
									margin: const EdgeInsets.only(right: 6),
									decoration: BoxDecoration(
										color: Colors.green.shade50,
										borderRadius: BorderRadius.circular(12),
									),
									child: Text(
										"Delivery",
										style: TextStyle(
											fontSize: 10,
											color: Colors.green.shade700,
											fontWeight: FontWeight.w500,
										),
									),
								),
							if (isVerified)
								Container(
									padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
									decoration: BoxDecoration(
										color: Colors.blue.shade50,
										borderRadius: BorderRadius.circular(12),
									),
									child: Text(
										"Verified",
										style: TextStyle(
										fontSize: 10,
										color: Colors.blue.shade700,
										fontWeight: FontWeight.w500,
										),
									),
								),
						],
					),
					const SizedBox(height: 15),

					// Product images row
					Row(
            mainAxisAlignment: MainAxisAlignment.center,
						children: productImages
							.take(4)
							.map(
                  (img) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img,
                        width: 53,
                        height: 53,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 53,
                            height: 53,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
							.toList(),
					),

					const SizedBox(height: 15),

					// View Shop button
					SizedBox(
						width: double.infinity,
						child: OutlinedButton(
							onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //   builder: (context) => ShopDetailScreen(shop: shop),
                //   ),
                // );
              },
							style: OutlinedButton.styleFrom(
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(12),
								),
								side: BorderSide(color: Colors.purple.shade400),
							),
							child: const Text(
								"View Shop",
								style: TextStyle(
									fontSize: 13,
									fontWeight: FontWeight.w600,
									color: Colors.purple,
								),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildShopAvatar() {
    return ClipOval(
      child: Image.network(
        'https://picsum.photos/100/100?random=${shopName.hashCode}',
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 32,
            height: 32,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              size: 18,
              color: Colors.grey[500],
            ),
          );
        },
      ),
    );
  }
}
