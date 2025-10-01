class ProductData {
  final String productType;
  final String productName;
  final String brand;
  final DateTime purchaseDate;
  final String? billImagePath;
  String? warrantyPeriod;

  ProductData({
    required this.productType,
    required this.productName,
    required this.brand,
    required this.purchaseDate,
    this.billImagePath,
    this.warrantyPeriod,
  });

  ProductData copyWith({
    String? productType,
    String? productName,
    String? brand,
    DateTime? purchaseDate,
    String? billImagePath,
    String? warrantyPeriod,
  }) {
    return ProductData(
      productType: productType ?? this.productType,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      billImagePath: billImagePath ?? this.billImagePath,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productType': productType,
      'productName': productName,
      'brand': brand,
      'purchaseDate': purchaseDate.toIso8601String(),
      'billImagePath': billImagePath,
      'warrantyPeriod': warrantyPeriod,
    };
  }

  factory ProductData.fromMap(Map<String, dynamic> map) {
    return ProductData(
      productType: map['productType'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      purchaseDate: DateTime.parse(map['purchaseDate']),
      billImagePath: map['billImagePath'],
      warrantyPeriod: map['warrantyPeriod'],
    );
  }

  @override
  String toString() {
    return 'ProductData{productType: $productType, productName: $productName, brand: $brand, purchaseDate: $purchaseDate, billImagePath: $billImagePath, warrantyPeriod: $warrantyPeriod}';
  }
}