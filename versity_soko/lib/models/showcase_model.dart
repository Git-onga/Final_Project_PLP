class ShowcaseModel {
  final String id;
  final String shopId;
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewsCount;

  ShowcaseModel({
    required this.id,
    required this.shopId,
    required this.mediaUrl,
    this.caption,
    required this.createdAt,
    this.expiresAt,
    this.viewsCount = 0,
  });

  /// ✅ From Supabase JSON
  factory ShowcaseModel.fromJson(Map<String, dynamic> json) {
    return ShowcaseModel(
      id: json['id'].toString(),
      shopId: json['shop_id'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      viewsCount: json['views_count'] ?? 0,
    );
  }

  /// ✅ To JSON (for upload)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'media_url': mediaUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'views_count': viewsCount,
    };
  }
}
