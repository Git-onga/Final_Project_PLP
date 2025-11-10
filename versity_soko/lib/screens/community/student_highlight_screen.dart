import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentHighlightsScreen extends StatefulWidget {
  const StudentHighlightsScreen({super.key});

  @override
  State<StudentHighlightsScreen> createState() =>
      _StudentHighlightsScreenState();
}

class _StudentHighlightsScreenState extends State<StudentHighlightsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _highlights = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHighlights();
  }

  Future<void> _fetchHighlights() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final response = await _supabase
          .from('student_highlights')
          .select('*')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _highlights = List<Map<String, dynamic>>.from(response ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
      debugPrint('❌ Error fetching highlights: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getHighlightColor(String category) {
    switch (category.toLowerCase()) {
      case 'clubs':
        return Colors.purpleAccent;
      case 'academics':
        return Colors.blueAccent;
      case 'sports':
        return Colors.orangeAccent;
      case 'arts':
        return Colors.greenAccent;
      case 'research':
        return Colors.indigoAccent;
      case 'community':
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _likeHighlight(String highlightId, int currentLikes) async {
    try {
      await _supabase
          .from('student_highlights')
          .update({'likes': currentLikes + 1})
          .eq('id', highlightId);
      
      // Update locally for immediate feedback
      setState(() {
        final index = _highlights.indexWhere((h) => h['id'] == highlightId);
        if (index != -1) {
          _highlights[index]['likes'] = currentLikes + 1;
        }
      });
      
      // Optional: Refresh from server to ensure consistency
      // await _fetchHighlights();
    } catch (e) {
      debugPrint('❌ Error liking highlight: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to like highlight'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Student Highlights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: _fetchHighlights,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_highlights.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchHighlights,
      color: Colors.blueAccent,
      backgroundColor: Colors.white,
      strokeWidth: 2.0,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _highlights.length,
        itemBuilder: (context, index) {
          final highlight = _highlights[index];
          return _buildHighlightCard(highlight);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Unable to load highlights',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage.isNotEmpty 
                ? _errorMessage 
                : 'Please check your connection and try again',
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchHighlights,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.highlight_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No highlights yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for student achievements!',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchHighlights,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(Map<String, dynamic> highlight) {
    final color = _getHighlightColor(highlight['category'] ?? '');
    final likes = highlight['likes'] ?? 0;
    final highlightId = highlight['id']?.toString() ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image with Hero animation
            Positioned.fill(
              child: Hero(
                tag: 'highlight-image-${highlight['id']}',
                child: _buildHighlightImage(highlight['image_url']),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        highlight['category']?.toString().toUpperCase() ??
                            'GENERAL',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      highlight['title'] ?? 'Untitled Highlight',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      highlight['description'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _likeHighlight(highlightId, likes),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$likes ${likes == 1 ? 'like' : 'likes'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(highlight['created_at']),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tap overlay for better UX
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HighlightDetailScreen(highlightId: highlight['id']),
                      ),
                    );
                  },
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightImage(String? imageUrl) {
    return Image.network(
      imageUrl ?? 'https://via.placeholder.com/600x400.png?text=No+Image',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Unable to load image',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showHighlightDetails(BuildContext context, Map<String, dynamic> highlight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _buildHighlightDetailSheet(highlight),
    );
  }

  Widget _buildHighlightDetailSheet(Map<String, dynamic> highlight) {
    final color = _getHighlightColor(highlight['category'] ?? '');
    final likes = highlight['likes'] ?? 0;
    final highlightId = highlight['id']?.toString() ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Hero image for smooth transition
            Hero(
              tag: 'highlight-image-${highlight['id']}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildDetailImage(highlight['featured_image'] ?? highlight['image_url']),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              highlight['title'] ?? 'Untitled Highlight',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Category and likes row
            Row(
              children: [
                Chip(
                  label: Text(
                    highlight['category']?.toString() ?? 'General',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: color,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _likeHighlight(highlightId, likes),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$likes',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(highlight['created_at']),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              highlight['description'] ?? 'No description available.',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement share functionality
                      _shareHighlight(highlight);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _likeHighlight(highlightId, likes);
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Like'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailImage(String? imageUrl) {
    return Image.network(
      imageUrl ?? 'https://via.placeholder.com/600x400.png?text=No+Image',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Unable to load image',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareHighlight(Map<String, dynamic> highlight) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${highlight['title']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class HighlightDetailScreen extends StatefulWidget {
  final String highlightId;

  const HighlightDetailScreen({super.key, required this.highlightId});

  @override
  State<HighlightDetailScreen> createState() => _HighlightDetailScreenState();
}

class _HighlightDetailScreenState extends State<HighlightDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? _highlightData;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isPostingComment = false;
  String? _errorMessage;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _fetchHighlightDetails();
    _fetchComments();
  }

  Future<void> _fetchHighlightDetails() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabase
          .from('student_highlights')
          .select('*')
          .eq('id', widget.highlightId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _highlightData = response;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Highlight not found.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load highlight: ${e.toString()}';
        });
      }
      debugPrint('❌ Error fetching highlight details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchComments() async {
    if (!mounted) return;
    
    setState(() => _isLoadingComments = true);

    try {
      final response = await _supabase
          .from('highlight_comments')
          .select('''
            *,
            user:profiles(username, avatar_url)
          ''')
          .eq('highlight_id', widget.highlightId)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _comments = List<Map<String, dynamic>>.from(response ?? []);
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching comments: $e');
      if (mounted) {
        setState(() {
          _commentError = 'Failed to load comments';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isPostingComment = true;
      _commentError = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Insert comment into database
      await _supabase.from('highlight_comments').insert({
        'highlight_id': widget.highlightId,
        'user_id': user.id,
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Clear input and refresh comments
      _commentController.clear();
      await _fetchComments();
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      if (mounted) {
        setState(() {
          _commentError = 'Failed to post comment';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to post comment'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  Future<void> _likeHighlight() async {
    if (_highlightData == null) return;

    final currentLikes = _highlightData!['likes'] ?? 0;
    
    try {
      await _supabase
          .from('student_highlights')
          .update({'likes': currentLikes + 1})
          .eq('id', widget.highlightId);

      // Update locally for immediate feedback
      if (mounted) {
        setState(() {
          _highlightData!['likes'] = currentLikes + 1;
        });
      }
    } catch (e) {
      debugPrint('❌ Error liking highlight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to like highlight'),
            backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _shareHighlight() async {
    // Implement share functionality
    if (_highlightData == null) return;

    final title = _highlightData!['title'] ?? 'Student Highlight';
    final description = _highlightData!['description'] ?? '';
    
    // Placeholder for share functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing: $title'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Color _getHighlightColor(String category) {
    switch (category.toLowerCase()) {
      case 'clubs':
        return Colors.purpleAccent;
      case 'academics':
        return Colors.blueAccent;
      case 'sports':
        return Colors.orangeAccent;
      case 'arts':
        return Colors.greenAccent;
      case 'research':
        return Colors.indigoAccent;
      case 'community':
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildImageWithHero(String imageUrl) {
    return Hero(
      tag: 'highlight-image-${widget.highlightId}',
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, imageUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 280,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 280,
                color: Colors.white12,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 280,
                color: Colors.white12,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.white54),
                    const SizedBox(height: 8),
                    Text(
                      'Unable to load image',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.broken_image, 
                            size: 64, color: Colors.white54),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _highlightData;

    return Scaffold(
      backgroundColor: const Color(0xFF6A11CB),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : highlight == null
                  ? _buildEmptyState()
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          stretch: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: highlight['image_url'] != null
                                ? _buildImageWithHero(highlight['image_url'])
                                : Container(
                                    color: Colors.white12,
                                    child: const Icon(Icons.image,
                                        size: 64, color: Colors.white54),
                                  ),
                          ),
                          backgroundColor: Colors.transparent,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, 
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: IconButton(
                                  icon: const Icon(Icons.share, 
                                      color: Colors.white),
                                  onPressed: _shareHighlight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Chip
                                if (highlight['category'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getHighlightColor(
                                              highlight['category'])
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      highlight['category']
                                              .toString()
                                              .toUpperCase() ??
                                          'GENERAL',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),

                                // Title
                                Text(
                                  highlight['title'] ?? 'Untitled Highlight',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Date and Likes
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(highlight['created_at']),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: _likeHighlight,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.favorite,
                                              color: Colors.redAccent, size: 20),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${highlight['likes'] ?? 0}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Description
                                Text(
                                  highlight['description'] ??
                                      'No description available.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Divider(color: Colors.white54),
                                const SizedBox(height: 20),

                                // Comments Section
                                _buildCommentsSection(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchHighlightDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A11CB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.highlight_off, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Highlight not found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The highlight you\'re looking for doesn\'t exist.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6A11CB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comments",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Comments List
        if (_isLoadingComments)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
        else if (_commentError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _commentError!,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white54),
                  onPressed: _fetchComments,
                ),
              ],
            ),
          )
        else if (_comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.chat_bubble_outline, 
                    size: 48, color: Colors.white54),
                SizedBox(height: 8),
                Text(
                  'No comments yet\nBe the first to comment!',
                  style: TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _comments.map((comment) {
              final user = comment['user'] as Map<String, dynamic>?;
              final username = user?['username'] ?? 'Anonymous';
              final content = comment['content'] ?? '';
              final createdAt = comment['created_at'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white24,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        // Add Comment Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (_commentError != null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _commentError!,
                    style: TextStyle(color: Colors.red.shade200),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isPostingComment
                      ? const CircularProgressIndicator(color: Colors.white)
                      : IconButton(
                          icon: const Icon(Icons.send, 
                              color: Colors.white, size: 28),
                          onPressed: _addComment,
                        ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}