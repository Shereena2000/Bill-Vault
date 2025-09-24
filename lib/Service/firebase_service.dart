import 'dart:io';

import 'package:bill_vault/Service/cloudinary_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../Features/product_screens/product/model/product_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Uuid _uuid = Uuid();

  // Collections
  static const String _productsCollection = 'products';
  static const String _brandsCollection = 'brands';
  static const String _productTypesCollection = 'product_types';

  // Product CRUD Operations
  static Future<String> addProduct(ProductModel product) async {
    try {
      String productId = _uuid.v4();
      product.id = productId;
      
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .set(product.toMap());
      
      return productId;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  static Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('purchaseDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  static Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get real-time products stream
  static Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection(_productsCollection)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  // Product Types Operations
  static Future<List<ProductTypeModel>> getProductTypes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productTypesCollection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductTypeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get product types: $e');
    }
  }

  // Brands Operations
  static Future<List<String>> getBrandsByProductType(String productType) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_brandsCollection)
          .doc(productType.toLowerCase())
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['brands'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get brands: $e');
    }
  }

  // Image Upload using Cloudinary
  static Future<String?> uploadBillImage(File imageFile, String productId) async {
    try {
      String imageUrl = await CloudinaryService.uploadImage(imageFile, productId);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Search products
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('productName', isGreaterThanOrEqualTo: query)
          .where('productName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

// In your firebase_service.dart, update the initializeDefaultData method:

static Future<void> initializeDefaultData() async {
  try {
    // Check if data already exists to avoid re-adding
    QuerySnapshot existingProducts = await _firestore
        .collection(_productTypesCollection)
        .limit(1)
        .get();
    
    if (existingProducts.docs.isNotEmpty) {
      print('Default data already exists, skipping initialization');
      return;
    }

    // Add default product types with correct asset paths
    List<ProductTypeModel> defaultProductTypes = [
      ProductTypeModel(id: '1', name: 'Air Conditioner', imageUrl: 'assets/images/fridge.png'),
      ProductTypeModel(id: '2', name: 'Air Fryer', imageUrl: 'assets/images/airfryer.png'), // Check if this file exists
      ProductTypeModel(id: '3', name: 'Microwave', imageUrl: 'assets/images/washingmachine.png'), // Check if this file exists
      ProductTypeModel(id: '4', name: 'Laptop', imageUrl: 'assets/images/laptop.png'),
      ProductTypeModel(id: '5', name: 'Television', imageUrl: 'assets/images/television.png'),
      ProductTypeModel(id: '6', name: 'Phone', imageUrl: 'assets/images/phone.png'),
    ];

    print('Adding ${defaultProductTypes.length} product types to Firebase...');

    for (ProductTypeModel productType in defaultProductTypes) {
      await _firestore
          .collection(_productTypesCollection)
          .doc(productType.id)
          .set(productType.toMap(), SetOptions(merge: true));
      print('Added product type: ${productType.name}');
    }

    // Add default brands
    Map<String, List<String>> defaultBrands = {
      'air conditioner': ['LG', 'Samsung', 'Voltas', 'Blue Star', 'Hitachi', 'Daikin'],
      'air fryer': ['Bajaj', 'Borosil', 'ButterFly', 'Sujatha', 'Cello', 'Kaff'],
      'microwave': ['LG', 'Samsung', 'IFB', 'Bajaj', 'Panasonic', 'Godrej'],
      'laptop': ['Dell', 'HP', 'Lenovo', 'ASUS', 'Acer', 'Apple'],
      'television': ['Sony', 'LG', 'Samsung', 'Mi', 'OnePlus', 'TCL'],
      'phone': ['Samsung', 'Apple', 'OnePlus', 'Xiaomi', 'Oppo', 'Vivo'],
    };

    print('Adding brands for ${defaultBrands.length} product types...');

    for (String productType in defaultBrands.keys) {
      await _firestore
          .collection(_brandsCollection)
          .doc(productType)
          .set({'brands': defaultBrands[productType]!}, SetOptions(merge: true));
      print('Added brands for: $productType');
    }

    print('Default data initialization completed successfully');

  } catch (e) {
    print('Error initializing default data: $e');
    // Don't throw the error, just log it so app can continue
  }
}
}