import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:bill_vault/Service/cloudinary_service.dart';
import '../Features/contact_screens/contact/model/contact_model.dart';
import '../Features/product_screens/product/model/product_model.dart';
import '../Features/subscription_screens/subscriptions/model/subscription_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Uuid _uuid = Uuid();

  // Collections
  static const String _productsCollection = 'products';
  static const String _brandsCollection = 'brands';
  static const String _productTypesCollection = 'product_types';
  static const String _contactsCollection = 'contacts';
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _subscriptionTypesCollection = 'subscription_types';
  static const String _subscriptionBrandsCollection = 'subscription_brands';

  // Helper to get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // ============ PRODUCTS ============
  
  static Future<String> addProduct(ProductModel product) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      String productId = _uuid.v4();
      product.id = productId;
      
      // Add userId to the product data
      Map<String, dynamic> productData = product.toMap();
      productData['userId'] = _currentUserId;
      
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .set(productData);
      
      print('Product added for user: $_currentUserId');
      return productId;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  static Future<List<ProductModel>> getAllProducts() async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('userId', isEqualTo: _currentUserId)
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
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      // Verify ownership before updating
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .get();
      
      if (!doc.exists) throw Exception('Product not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized: You can only update your own products');
      }
      
      Map<String, dynamic> productData = product.toMap();
      productData['userId'] = _currentUserId; // Ensure userId is preserved
      
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(productData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      // Verify ownership before deleting
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();
      
      if (!doc.exists) throw Exception('Product not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized: You can only delete your own products');
      }
      
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  static Stream<List<ProductModel>> getProductsStream() {
    if (_currentUserId == null) {
      print('No user logged in, returning empty stream');
      return Stream.value([]);
    }
    
    print('Setting up products stream for user: $_currentUserId');
    return _firestore
        .collection(_productsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Products stream update: ${snapshot.docs.length} products');
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data()))
              .toList();
        });
  }

  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('userId', isEqualTo: _currentUserId)
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

  // ============ CONTACTS ============
  
  static Future<String> addContact(ContactModel contact) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      String contactId = _uuid.v4();
      contact.id = contactId;
      
      Map<String, dynamic> contactData = contact.toMap();
      contactData['userId'] = _currentUserId;
      
      await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .set(contactData);
      
      print('Contact added for user: $_currentUserId');
      return contactId;
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  static Future<List<ContactModel>> getAllContacts() async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  static Future<void> updateContact(ContactModel contact) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      DocumentSnapshot doc = await _firestore
          .collection(_contactsCollection)
          .doc(contact.id)
          .get();
      
      if (!doc.exists) throw Exception('Contact not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized');
      }
      
      Map<String, dynamic> contactData = contact.toMap();
      contactData['userId'] = _currentUserId;
      
      await _firestore
          .collection(_contactsCollection)
          .doc(contact.id)
          .update(contactData);
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  static Future<void> deleteContact(String contactId) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      DocumentSnapshot doc = await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .get();
      
      if (!doc.exists) throw Exception('Contact not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized');
      }
      
      await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  static Stream<List<ContactModel>> getContactsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(_contactsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactModel.fromMap(doc.data()))
            .toList());
  }

  static Future<List<ContactModel>> searchContacts(String query) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }

  static Future<List<ContactModel>> getContactsByProfession(String profession) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('profession', isEqualTo: profession)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get contacts by profession: $e');
    }
  }

  static List<String> getAvailableProfessions() {
    return [
      'A C Technician',
      'Builder',
      'CCTV Installer',
      'Driver',
      'Carpenter',
      'Electrician',
      'Plumber',
      'Painter',
      'Mason',
      'Gardener',
      'Security Guard',
      'House Keeper',
      'Cook',
      'Mechanic',
      'Welder',
      'Tailor',
      'Barber',
      'Doctor',
      'Teacher',
      'Other',
    ];
  }

  // ============ SUBSCRIPTIONS ============
  
  static Future<String> addSubscription(SubscriptionModel subscription) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      String subscriptionId = _uuid.v4();
      subscription.id = subscriptionId;
      
      Map<String, dynamic> subscriptionData = subscription.toMap();
      subscriptionData['userId'] = _currentUserId;
      
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .set(subscriptionData);
      
      print('Subscription added for user: $_currentUserId');
      return subscriptionId;
    } catch (e) {
      throw Exception('Failed to add subscription: $e');
    }
  }

  static Future<List<SubscriptionModel>> getAllSubscriptions() async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_subscriptionsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('registrationDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
    }
  }

  static Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      DocumentSnapshot doc = await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscription.id)
          .get();
      
      if (!doc.exists) throw Exception('Subscription not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized');
      }
      
      Map<String, dynamic> subscriptionData = subscription.toMap();
      subscriptionData['userId'] = _currentUserId;
      
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscription.id)
          .update(subscriptionData);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  static Future<void> deleteSubscription(String subscriptionId) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      DocumentSnapshot doc = await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .get();
      
      if (!doc.exists) throw Exception('Subscription not found');
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _currentUserId) {
        throw Exception('Unauthorized');
      }
      
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete subscription: $e');
    }
  }

  static Stream<List<SubscriptionModel>> getSubscriptionsStream() {
    if (_currentUserId == null) {
      print('No user logged in, returning empty stream');
      return Stream.value([]);
    }
    
    print('Setting up subscriptions stream for user: $_currentUserId');
    return _firestore
        .collection(_subscriptionsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Subscriptions stream update: ${snapshot.docs.length} subscriptions');
          return snapshot.docs
              .map((doc) => SubscriptionModel.fromMap(doc.data()))
              .toList();
        });
  }

  static Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_subscriptionsCollection)
          .where('userId', isEqualTo: _currentUserId)
          .where('subscriptionName', isGreaterThanOrEqualTo: query)
          .where('subscriptionName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search subscriptions: $e');
    }
  }

  // ============ SHARED DATA (No user filtering needed) ============
  
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

  static Future<List<SubscriptionTypeModel>> getSubscriptionTypes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_subscriptionTypesCollection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionTypeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subscription types: $e');
    }
  }

  static Future<List<String>> getSubscriptionBrandsByType(String subscriptionType) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_subscriptionBrandsCollection)
          .doc(subscriptionType.toLowerCase().replaceAll(' ', '_'))
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['brands'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get subscription brands: $e');
    }
  }

  static List<String> getAvailableRecurringPeriods() {
    return [
      'Monthly',
      'Quarterly',
      'Half Yearly',
      'Yearly',
    ];
  }

  // ============ IMAGE UPLOAD ============
  
  static Future<String?> uploadBillImage(File imageFile, String productId) async {
    try {
      String imageUrl = await CloudinaryService.uploadImage(imageFile, productId);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // ============ INITIALIZATION ============
  
  static Future<void> initializeDefaultData() async {
    try {
      QuerySnapshot existingProducts = await _firestore
          .collection(_productTypesCollection)
          .limit(1)
          .get();
      
      if (existingProducts.docs.isNotEmpty) {
        print('Default product data already exists');
        return;
      }

      List<ProductTypeModel> defaultProductTypes = [
        ProductTypeModel(id: '1', name: 'Air Conditioner', imageUrl: 'assets/images/fridge.png'),
        ProductTypeModel(id: '2', name: 'Air Fryer', imageUrl: 'assets/images/airfryer.png'), 
        ProductTypeModel(id: '3', name: 'Microwave', imageUrl: 'assets/images/microwave.png'), 
        ProductTypeModel(id: '4', name: 'Laptop', imageUrl: 'assets/images/laptop.png'),
        ProductTypeModel(id: '5', name: 'Television', imageUrl: 'assets/images/television.png'),
        ProductTypeModel(id: '6', name: 'Phone', imageUrl: 'assets/images/phone.png'),
      ];

      for (ProductTypeModel productType in defaultProductTypes) {
        await _firestore
            .collection(_productTypesCollection)
            .doc(productType.id)
            .set(productType.toMap(), SetOptions(merge: true));
      }

      Map<String, List<String>> defaultBrands = {
        'air conditioner': ['LG', 'Samsung', 'Voltas', 'Blue Star', 'Hitachi', 'Daikin'],
        'air fryer': ['Bajaj', 'Borosil', 'ButterFly', 'Sujatha', 'Cello', 'Kaff'],
        'microwave': ['LG', 'Samsung', 'IFB', 'Bajaj', 'Panasonic', 'Godrej'],
        'laptop': ['Dell', 'HP', 'Lenovo', 'ASUS', 'Acer', 'Apple'],
        'television': ['Sony', 'LG', 'Samsung', 'Mi', 'OnePlus', 'TCL'],
        'phone': ['Samsung', 'Apple', 'OnePlus', 'Xiaomi', 'Oppo', 'Vivo'],
      };

      for (String productType in defaultBrands.keys) {
        await _firestore
            .collection(_brandsCollection)
            .doc(productType)
            .set({'brands': defaultBrands[productType]!}, SetOptions(merge: true));
      }

      print('Product default data initialization completed');
    } catch (e) {
      print('Error initializing product default data: $e');
    }
  }

  static Future<void> initializeSubscriptionDefaultData() async {
    try {
      QuerySnapshot existingTypes = await _firestore
          .collection(_subscriptionTypesCollection)
          .limit(1)
          .get();
      
      if (existingTypes.docs.isNotEmpty) {
        print('Subscription default data already exists');
        return;
      }

      List<SubscriptionTypeModel> defaultSubscriptionTypes = [
        SubscriptionTypeModel(id: '1', name: 'Gaming', imageUrl: 'assets/images/gaming.png'),
        SubscriptionTypeModel(id: '2', name: 'Music', imageUrl: 'assets/images/music.png'),
        SubscriptionTypeModel(id: '3', name: 'News', imageUrl: 'assets/images/news.png'),
        SubscriptionTypeModel(id: '4', name: 'OTT', imageUrl: 'assets/images/ott.png'),
        SubscriptionTypeModel(id: '5', name: 'SaaS Platform', imageUrl: 'assets/images/saas.png'),
      ];

      for (SubscriptionTypeModel subscriptionType in defaultSubscriptionTypes) {
        await _firestore
            .collection(_subscriptionTypesCollection)
            .doc(subscriptionType.id)
            .set(subscriptionType.toMap());
      }

      Map<String, List<String>> defaultSubscriptionBrands = {
        'gaming': [
          'Apple Arcade', 'EA Play', 'Google Play Pass', 'Xbox Game Pass', 
          'PlayStation Plus', 'Nintendo Switch Online', 'Steam', 'Epic Games'
        ],
        'music': [
          'Spotify', 'Apple Music', 'YouTube Music', 'Amazon Music', 
          'JioSaavn', 'Gaana', 'Wynk Music', 'Hungama Music'
        ],
        'news': [
          'The Times of India', 'The Hindu', 'Indian Express', 'Economic Times',
          'Hindustan Times', 'DNA', 'Business Standard', 'Mint'
        ],
        'ott': [
          'Netflix', 'Amazon Prime Video', 'Disney+ Hotstar', 'SonyLIV',
          'Zee5', 'Voot', 'MX Player', 'ALTBalaji', 'Aha', 'Sun NXT'
        ],
        'saas_platform': [
          'Microsoft 365', 'Google Workspace', 'Adobe Creative Cloud', 'Canva Pro',
          'Notion', 'Figma', 'Slack', 'Zoom', 'Dropbox', 'iCloud'
        ],
      };

      for (String subscriptionType in defaultSubscriptionBrands.keys) {
        await _firestore
            .collection(_subscriptionBrandsCollection)
            .doc(subscriptionType)
            .set({'brands': defaultSubscriptionBrands[subscriptionType]!});
      }

      print('Subscription default data initialization completed');
    } catch (e) {
      print('Error initializing subscription default data: $e');
    }
  }
}