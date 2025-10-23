import 'dart:async';
import 'package:flutter/material.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final PageController _pageController = PageController();
  final PageController _imagePageController = PageController();

  int _currentShowcase = 0;
  int _currentImageIndex = 0;
  Timer? _timer;
  bool _isPaused = false;

  final List<Map<String, dynamic>> showcases = [
    {
      'seller': 'Infinity Boutique',
      'sellerImage': 'https://picsum.photos/50/50?random=99',
      'images': [
        'https://picsum.photos/400/600?random=13',
        'https://picsum.photos/400/600?random=14',
        'https://picsum.photos/400/600?random=15',
      ],
      'products': [
        {'name': 'Summer Dress', 'price': 'KES. 2,530'},
        {'name': 'Designer Handbag', 'price': 'KES. 2,530'},
        {'name': 'Casual Sneakers', 'price': 'KES. 2,530'},
      ]
    },
    {
      'seller': 'Tech Gadgets',
      'sellerImage': 'https://picsum.photos/50/50?random=100',
      'images': [
        'https://picsum.photos/400/600?random=16',
        'https://picsum.photos/400/600?random=17',
      ],
      'products': [
        {'name': 'Wireless Earbuds', 'price': 'KES. 2,530'},
        {'name': 'Smart Watch', 'price': 'KES. 2,530'},
      ]
    },
    {
      'seller': 'Home Decor',
      'sellerImage': 'https://picsum.photos/50/50?random=101',
      'images': [
        'https://picsum.photos/400/600?random=19',
        'https://picsum.photos/400/600?random=20',
      ],
      'products': [
        {'name': 'Modern Lamp', 'price': 'KES. 2,530'},
        {'name': 'Wall Art', 'price': 'KES. 2,530'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isPaused) return;

      setState(() {
        final currentShowcase = showcases[_currentShowcase];
        if (_currentImageIndex < currentShowcase['images'].length - 1) {
          _nextImage();
        } else {
          _nextShowcase();
        }
      });
    });
  }

  void _nextShowcase() {
    if (_currentShowcase < showcases.length - 1) {
      _currentShowcase++;
      _currentImageIndex = 0;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _currentShowcase = 0;
      _currentImageIndex = 0;
      _pageController.jumpToPage(0);
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) _startAutoSlide();
  }

  void _nextImage() {
    final currentShowcase = showcases[_currentShowcase];
    if (_currentImageIndex < currentShowcase['images'].length - 1) {
      _currentImageIndex++;
      _imagePageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _currentImageIndex--;
      _imagePageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imagePageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePause,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousImage();
          } else if (details.primaryVelocity! < 0) {
            _nextImage();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: showcases.length,
          itemBuilder: (context, showcaseIndex) {
            final showcase = showcases[showcaseIndex];
            final images = showcase['images'] as List<String>;
            final products = showcase['products'] as List<Map<String, String>>;

            return Stack(
              children: [
                _buildImageBackground(images),
                if (_isPaused) _buildPauseIndicator(context),
                _buildProgressBar(context, images),
                _buildSellerHeader(context, showcase, images),
                _buildProductInfo(context, products),
                if (images.length > 1) _buildNavigationButtons(),
              ],
            );
          },
        ),
      ),
    );
  }

  // -------------------
  // 🧩 UI Components
  // -------------------

  Widget _buildImageBackground(List<String> images) {
    return Positioned.fill(
      child: PageView.builder(
        controller: _imagePageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPauseIndicator(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.pause, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, List<String> images) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(images.length, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: index <= _currentImageIndex ? Colors.white : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSellerHeader(BuildContext context, Map<String, dynamic> showcase, List<String> images) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(showcase['sellerImage']), radius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(showcase['seller'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${_currentImageIndex + 1}/${images.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, List<Map<String, String>> products) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              products[_currentImageIndex]['name']!,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              products[_currentImageIndex]['price']!,
              style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint('Added ${products[_currentImageIndex]['name']} to cart');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Stack(
      children: [
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              onPressed: _previousImage,
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              onPressed: _nextImage,
              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
