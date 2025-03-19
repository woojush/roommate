// InfoCategory와 InfoItem 모델 정의

class InfoItem {
  final String title;
  final String? link;
  final List<InfoItem> children;

  InfoItem({
    required this.title,
    this.link,
    this.children = const [],
  });

  factory InfoItem.fromJson(Map<String, dynamic> json) {
    return InfoItem(
      title: json['title'] as String,
      link: json['link'] as String?,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((childJson) => InfoItem.fromJson(childJson))
          .toList(),
    );
  }
}

class InfoCategory {
  final String title;
  final List<InfoItem> items;

  InfoCategory({
    required this.title,
    required this.items,
  });

  factory InfoCategory.fromJson(Map<String, dynamic> json) {
    return InfoCategory(
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => InfoItem.fromJson(itemJson))
          .toList(),
    );
  }
}
