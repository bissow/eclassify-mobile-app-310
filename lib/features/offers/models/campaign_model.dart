class CampaignModel {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? bannerImage;
  final String? mobileBanner;
  final String? highlightBadge;
  final double? discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  CampaignModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.bannerImage,
    this.mobileBanner,
    this.highlightBadge,
    this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      bannerImage: json['banner_image'],
      mobileBanner: json['mobile_banner'] ?? json['banner_image'],
      highlightBadge: json['highlight_badge'],
      discountPercentage: json['discount_percentage'] != null
          ? double.tryParse(json['discount_percentage'].toString())
          : null,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  bool get isEndingSoon {
    final diff = endDate.difference(DateTime.now());
    return !diff.isNegative && diff.inDays <= 3;
  }
}
