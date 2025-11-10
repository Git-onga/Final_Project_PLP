import 'dart:async';
import 'package:flutter/material.dart';


class ShowcaseViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> showcases;
  final int initialIndex;

  const ShowcaseViewerScreen({
    Key? key,
    required this.showcases,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ShowcaseViewerScreen> createState() => _ShowcaseViewerScreenState();
}

class _ShowcaseViewerScreenState extends State<ShowcaseViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < widget.showcases.length - 1) {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showcases = widget.showcases;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _startAutoAdvance();
            },
            itemCount: showcases.length,
            itemBuilder: (context, index) {
              final show = showcases[index];
              return Center(
                child: show['media_url'] != null
                    ? Image.network(
                        show['media_url'],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : const Icon(Icons.image, color: Colors.white),
              );
            },
          ),
          // Top progress bar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(
                showcases.length,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? Colors.white
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Caption text
          Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: Text(
              showcases[_currentIndex]['caption'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

