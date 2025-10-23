import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Shopping Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.cartItems.isEmpty) return const SizedBox();
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context, cartProvider),
                  tooltip: 'Clear Cart',
                );
              },
            ),
          ],
        ),
        body: const CartBody(),
        bottomNavigationBar: const CartBottomBar(),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}

class CartBody extends StatelessWidget {
  const CartBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoading) {
          return _buildLoadingState();
        }

        if (cartProvider.cartItems.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.cartItems[index];
                  return CartItemCard(
                    item: item,
                    onQuantityChanged: (newQuantity) {
                      cartProvider.updateQuantity(item.id, newQuantity);
                    },
                    onRemove: () {
                      cartProvider.removeItem(item.id);
                    },
                  );
                },
              ),
            ),

            // Promo Code Section
            _buildPromoCodeSection(cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ShimmerCartItem(),
        );
      },
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
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Looks like you haven\'t added anything to your cart yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to products screen
                // Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cartProvider.promoCodeController,
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => cartProvider.applyPromoCode(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.cartItems.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price Summary
              _buildPriceSummary(cartProvider),
              const SizedBox(height: 16),
              
              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(context, cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceSummary(CartProvider cartProvider) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', cartProvider.subtotal),
        if (cartProvider.discount > 0)
          _buildPriceRow('Discount', -cartProvider.discount, isDiscount: true),
        _buildPriceRow('Shipping', cartProvider.shippingFee),
        _buildPriceRow('Tax', cartProvider.tax),
        const Divider(height: 20),
        _buildPriceRow(
          'Total',
          cartProvider.total,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.grey[700],
            ),
          ),
          Text(
            isDiscount ? '-${_formatCurrency(amount)}' : _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  void _proceedToCheckout(BuildContext context, CartProvider cartProvider) {
    if (cartProvider.cartItems.isEmpty) return;
    
    // Navigate to checkout screen
    print('Proceeding to checkout with ${cartProvider.cartItems.length} items');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proceeding to checkout with ${cartProvider.totalItems} items'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.variant,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price and Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      _buildQuantitySelector(),
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

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: item.quantity > 1
                ? () => onQuantityChanged(item.quantity - 1)
                : null,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              visualDensity: VisualDensity.compact,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onQuantityChanged(item.quantity + 1),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(4),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer Loading Widget
class ShimmerCartItem extends StatelessWidget {
  const ShimmerCartItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            
            // Shimmer Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
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
}

// Cart Provider
class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  final TextEditingController promoCodeController = TextEditingController();
  bool _isLoading = false;
  double _discount = 0.0;
  final double _shippingFee = 5.99;
  final double _taxRate = 0.08; // 8%

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  double get discount => _discount;

  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get tax {
    return (subtotal - _discount) * _taxRate;
  }

  double get shippingFee {
    return subtotal > 50 ? 0 : _shippingFee; // Free shipping over $50
  }

  double get total {
    return (subtotal - _discount) + shippingFee + tax;
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  CartProvider() {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _cartItems.addAll([
      CartItem(
        id: '1',
        name: 'Summer Floral Dress',
        price: 49.99,
        imageUrl: 'https://picsum.photos/200/300?random=1',
        variant: 'Size: M, Color: Blue',
        quantity: 1,
      ),
      CartItem(
        id: '2',
        name: 'Designer Handbag',
        price: 89.99,
        imageUrl: 'https://picsum.photos/200/300?random=2',
        variant: 'Color: Black',
        quantity: 1,
      ),
      CartItem(
        id: '3',
        name: 'Casual Sneakers',
        price: 59.99,
        imageUrl: 'https://picsum.photos/200/300?random=3',
        variant: 'Size: 42, Color: White',
        quantity: 2,
      ),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity < 1) {
      removeItem(itemId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
    
    ScaffoldMessenger.of(GlobalContext.context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void clearCart() {
    _cartItems.clear();
    _discount = 0.0;
    promoCodeController.clear();
    notifyListeners();
    
    ScaffoldMessenger.of(GlobalContext.context).showSnackBar(
      const SnackBar(
        content: Text('Cart cleared'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void applyPromoCode() {
    final code = promoCodeController.text.trim();
    if (code.isEmpty) return;

    // Mock promo code validation
    if (code == 'SAVE10') {
      _discount = subtotal * 0.1; // 10% discount
      ScaffoldMessenger.of(GlobalContext.context).showSnackBar(
        const SnackBar(
          content: Text('Promo code applied! 10% discount added.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _discount = 0.0;
      ScaffoldMessenger.of(GlobalContext.context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Colors.red,
        ),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String variant;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.variant,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? variant,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Global context helper (for SnackBar in Provider)
class GlobalContext {
  static late BuildContext context;
}

// Usage in main.dart:
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Builder(
//         builder: (context) {
//           GlobalContext.context = context;
//           return CartScreen();
//         },
//       ),
//     );
//   }
// }