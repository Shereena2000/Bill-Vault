
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class SubscriptionModel {
  String? id;
  String subscriptionType;
  String subscriptionName;
  String brand;
  DateTime registrationDate;
  DateTime nextBillingDate;
  String recurringPeriod;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  SubscriptionModel({
    this.id,
    required this.subscriptionType,
    required this.subscriptionName,
    required this.brand,
    required this.registrationDate,
    required this.nextBillingDate,
    required this.recurringPeriod,
    required this.isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionType': subscriptionType,
      'subscriptionName': subscriptionName,
      'brand': brand,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'nextBillingDate': Timestamp.fromDate(nextBillingDate),
      'recurringPeriod': recurringPeriod,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      subscriptionType: map['subscriptionType'] ?? '',
      subscriptionName: map['subscriptionName'] ?? '',
      brand: map['brand'] ?? '',
      registrationDate: (map['registrationDate'] as Timestamp).toDate(),
      nextBillingDate: (map['nextBillingDate'] as Timestamp).toDate(),
      recurringPeriod: map['recurringPeriod'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  SubscriptionModel copyWith({
    String? id,
    String? subscriptionType,
    String? subscriptionName,
    String? brand,
    DateTime? registrationDate,
    DateTime? nextBillingDate,
    String? recurringPeriod,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      brand: brand ?? this.brand,
      registrationDate: registrationDate ?? this.registrationDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods
  String get daysUntilNextBilling {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now);
    
    if (difference.inDays < 0) {
      return "Overdue";
    } else if (difference.inDays == 0) {
      return "Due today";
    } else if (difference.inDays == 1) {
      return "Due tomorrow";
    } else if (difference.inDays <= 7) {
      return "Due in ${difference.inDays} days";
    } else if (difference.inDays <= 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Due in $weeks week${weeks > 1 ? 's' : ''}";
    } else {
      final months = (difference.inDays / 30).floor();
      return "Due in $months month${months > 1 ? 's' : ''}";
    }
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now);
    return difference.inDays <= 7 && difference.inDays >= 0;
  }

  bool get isOverdue {
    return nextBillingDate.isBefore(DateTime.now());
  }
}

class SubscriptionTypeModel {
  String id;
  String name;
  String imageUrl;

  SubscriptionTypeModel({
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

  factory SubscriptionTypeModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionTypeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}