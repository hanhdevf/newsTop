import 'package:newtop/utils/constants.dart';

class Category {
  final String id;
  final String name;
  final String displayName;
  final String icon;
  final bool isSelected;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    this.isSelected = false,
  });

  // Factory constructor để tạo Category từ JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  // Convert Category thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon,
      'isSelected': isSelected,
    };
  }

  // Copy with method để tạo bản sao với thay đổi
  Category copyWith({
    String? id,
    String? name,
    String? displayName,
    String? icon,
    bool? isSelected,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Override toString để debug
  @override
  String toString() {
    return 'Category(id: $id, name: $name, displayName: $displayName, isSelected: $isSelected)';
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static method để tạo danh sách categories mặc định từ NewsCategory enum
  static List<Category> getDefaultCategories() {
    return NewsCategory.values.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      
      return Category(
        id: category.value,
        name: category.value,
        displayName: category.displayName,
        icon: category.icon,
        isSelected: index == 0, // First category is selected by default
      );
    }).toList();
  }

  // Helper method để tạo Category từ NewsCategory enum
  static Category fromNewsCategory(NewsCategory newsCategory, {bool isSelected = false}) {
    return Category(
      id: newsCategory.value,
      name: newsCategory.value,
      displayName: newsCategory.displayName,
      icon: newsCategory.icon,
      isSelected: isSelected,
    );
  }

  // Helper method để tạo Category từ category ID
  static Category fromId(String categoryId, {bool isSelected = false}) {
    // Tìm NewsCategory tương ứng
    final newsCategory = NewsCategory.values.firstWhere(
      (category) => category.value == categoryId,
      orElse: () => NewsCategory.general,
    );
    
    return fromNewsCategory(newsCategory, isSelected: isSelected);
  }

  // Helper method để kiểm tra category ID có hợp lệ không
  static bool isValidCategoryId(String categoryId) {
    return NewsCategory.values.any((category) => category.value == categoryId);
  }

  // Helper method để toggle selection
  Category toggleSelection() {
    return copyWith(isSelected: !isSelected);
  }

  // Helper method để set selection
  Category setSelected(bool selected) {
    return copyWith(isSelected: selected);
  }
}
