import 'dart:io';

import 'package:bill_vault/Service/cloudinary_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../Features/contact_screens/contact/model/contact_model.dart';
import '../Features/product_screens/product/model/product_model.dart';
import '../Features/subscription_screens/subscriptions/model/subscription_model.dart';

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

//contacts section

static const String _contactsCollection = 'contacts';
  
  // Contact CRUD Operations
  static Future<String> addContact(ContactModel contact) async {
    try {
      String contactId = _uuid.v4();
      contact.id = contactId;
      
      await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .set(contact.toMap());
      
      print('Contact added successfully: ${contact.name}');
      return contactId;
    } catch (e) {
      print('Error adding contact: $e');
      throw Exception('Failed to add contact: $e');
    }
  }

  static Future<List<ContactModel>> getAllContacts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting contacts: $e');
      throw Exception('Failed to get contacts: $e');
    }
  }

  static Future<void> updateContact(ContactModel contact) async {
    try {
      await _firestore
          .collection(_contactsCollection)
          .doc(contact.id)
          .update(contact.toMap());
      
      print('Contact updated successfully: ${contact.name}');
    } catch (e) {
      print('Error updating contact: $e');
      throw Exception('Failed to update contact: $e');
    }
  }

  static Future<void> deleteContact(String contactId) async {
    try {
      await _firestore
          .collection(_contactsCollection)
          .doc(contactId)
          .delete();
      
      print('Contact deleted successfully');
    } catch (e) {
      print('Error deleting contact: $e');
      throw Exception('Failed to delete contact: $e');
    }
  }

  // Get real-time contacts stream
  static Stream<List<ContactModel>> getContactsStream() {
    return _firestore
        .collection(_contactsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          print('Contacts stream updated: ${snapshot.docs.length} contacts');
          return snapshot.docs
              .map((doc) => ContactModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Search contacts
  static Future<List<ContactModel>> searchContacts(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching contacts: $e');
      throw Exception('Failed to search contacts: $e');
    }
  }

  // Get contacts by profession
  static Future<List<ContactModel>> getContactsByProfession(String profession) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_contactsCollection)
          .where('profession', isEqualTo: profession)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ContactModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting contacts by profession: $e');
      throw Exception('Failed to get contacts by profession: $e');
    }
  }

  // Get available professions
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

//subscriptions
 static const String _subscriptionsCollection = 'subscriptions';
  static const String _subscriptionTypesCollection = 'subscription_types';
  static const String _subscriptionBrandsCollection = 'subscription_brands';
  
  // Subscription CRUD Operations
  static Future<String> addSubscription(SubscriptionModel subscription) async {
    try {
      String subscriptionId = _uuid.v4();
      subscription.id = subscriptionId;
      
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .set(subscription.toMap());
      
      print('Subscription added successfully: ${subscription.subscriptionName}');
      return subscriptionId;
    } catch (e) {
      print('Error adding subscription: $e');
      throw Exception('Failed to add subscription: $e');
    }
  }

  static Future<List<SubscriptionModel>> getAllSubscriptions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_subscriptionsCollection)
          .orderBy('registrationDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting subscriptions: $e');
      throw Exception('Failed to get subscriptions: $e');
    }
  }

  static Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscription.id)
          .update(subscription.toMap());
      
      print('Subscription updated successfully: ${subscription.subscriptionName}');
    } catch (e) {
      print('Error updating subscription: $e');
      throw Exception('Failed to update subscription: $e');
    }
  }

  static Future<void> deleteSubscription(String subscriptionId) async {
    try {
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .delete();
      
      print('Subscription deleted successfully');
    } catch (e) {
      print('Error deleting subscription: $e');
      throw Exception('Failed to delete subscription: $e');
    }
  }

  // Get real-time subscriptions stream
  static Stream<List<SubscriptionModel>> getSubscriptionsStream() {
    return _firestore
        .collection(_subscriptionsCollection)
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Subscriptions stream updated: ${snapshot.docs.length} subscriptions');
          return snapshot.docs
              .map((doc) => SubscriptionModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Subscription Types Operations
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
      print('Error getting subscription types: $e');
      throw Exception('Failed to get subscription types: $e');
    }
  }

  // Get subscription brands by type
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
      print('Error getting subscription brands: $e');
      throw Exception('Failed to get subscription brands: $e');
    }
  }

  // Get available recurring periods
  static List<String> getAvailableRecurringPeriods() {
    return [
      'Monthly',
      'Quarterly',
      'Half Yearly',
      'Yearly',
    ];
  }

  // Search subscriptions
  static Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_subscriptionsCollection)
          .where('subscriptionName', isGreaterThanOrEqualTo: query)
          .where('subscriptionName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching subscriptions: $e');
      throw Exception('Failed to search subscriptions: $e');
    }
  }

  // Initialize default subscription data
  static Future<void> initializeSubscriptionDefaultData() async {
    try {
      // Check if data already exists
      QuerySnapshot existingTypes = await _firestore
          .collection(_subscriptionTypesCollection)
          .limit(1)
          .get();
      
      if (existingTypes.docs.isNotEmpty) {
        print('Subscription default data already exists, skipping initialization');
        return;
      }

      // Add default subscription types
      List<SubscriptionTypeModel> defaultSubscriptionTypes = [
        SubscriptionTypeModel(id: '1', name: 'Gaming', imageUrl: 'assets/images/gaming.png'),
        SubscriptionTypeModel(id: '2', name: 'Music', imageUrl: 'assets/images/music.png'),
        SubscriptionTypeModel(id: '3', name: 'News', imageUrl: 'assets/images/news.png'),
        SubscriptionTypeModel(id: '4', name: 'OTT', imageUrl: 'assets/images/ott.png'),
        SubscriptionTypeModel(id: '5', name: 'SaaS Platform', imageUrl: 'assets/images/saas.png'),
      ];

      print('Adding ${defaultSubscriptionTypes.length} subscription types to Firebase...');

      for (SubscriptionTypeModel subscriptionType in defaultSubscriptionTypes) {
        await _firestore
            .collection(_subscriptionTypesCollection)
            .doc(subscriptionType.id)
            .set(subscriptionType.toMap());
        print('Added subscription type: ${subscriptionType.name}');
      }

      // Add default subscription brands
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

      print('Adding brands for ${defaultSubscriptionBrands.length} subscription types...');

      for (String subscriptionType in defaultSubscriptionBrands.keys) {
        await _firestore
            .collection(_subscriptionBrandsCollection)
            .doc(subscriptionType)
            .set({'brands': defaultSubscriptionBrands[subscriptionType]!});
        print('Added brands for: $subscriptionType');
      }

      print('Subscription default data initialization completed successfully');

    } catch (e) {
      print('Error initializing subscription default data: $e');
    }
  }
}