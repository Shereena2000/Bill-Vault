import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class ProductModel {
  String? id;
  String productType;
  String productName;
  String brand;
  DateTime purchaseDate;
  DateTime warrantyEndDate;
  String? billImageUrl;
  String warrantyPeriod;
  bool isWarrantyActive;
  DateTime createdAt;
  DateTime updatedAt;

  ProductModel({
    this.id,
    required this.productType,
    required this.productName,
    required this.brand,
    required this.purchaseDate,
    required this.warrantyEndDate,
    this.billImageUrl,
    required this.warrantyPeriod,
    required this.isWarrantyActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productType': productType,
      'productName': productName,
      'brand': brand,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'warrantyEndDate': Timestamp.fromDate(warrantyEndDate),
      'billImageUrl': billImageUrl,
      'warrantyPeriod': warrantyPeriod,
      'isWarrantyActive': isWarrantyActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      productType: map['productType'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      purchaseDate: (map['purchaseDate'] as Timestamp).toDate(),
      warrantyEndDate: (map['warrantyEndDate'] as Timestamp).toDate(),
      billImageUrl: map['billImageUrl'],
      warrantyPeriod: map['warrantyPeriod'] ?? '',
      isWarrantyActive: map['isWarrantyActive'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? productType,
    String? productName,
    String? brand,
    DateTime? purchaseDate,
    DateTime? warrantyEndDate,
    String? billImageUrl,
    String? warrantyPeriod,
    bool? isWarrantyActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productType: productType ?? this.productType,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
      billImageUrl: billImageUrl ?? this.billImageUrl,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      isWarrantyActive: isWarrantyActive ?? this.isWarrantyActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods
  String get warrantyRemainingText {
    if (!isWarrantyActive) return "Warranty Expired";
    
    final now = DateTime.now();
    final difference = warrantyEndDate.difference(now);
    
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return "$months months warranty remaining";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} days warranty remaining";
    } else {
      return "Warranty Expired";
    }
  }

  bool get isWarrantyExpiringSoon {
    final now = DateTime.now();
    final difference = warrantyEndDate.difference(now);
    return difference.inDays <= 30 && difference.inDays > 0;
  }
}

class ProductTypeModel {
  String id;
  String name;
  String imageUrl;

  ProductTypeModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory ProductTypeModel.fromMap(Map<String, dynamic> map) {
    return ProductTypeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}