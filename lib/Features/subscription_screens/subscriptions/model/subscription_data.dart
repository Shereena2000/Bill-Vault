// Create this as: lib/Features/subscription_screens/model/subscription_data.dart

class SubscriptionData {
  final String subscriptionType;
  final String subscriptionName;
  final String brand;
  final DateTime registrationDate;
  String? recurringPeriod;

  SubscriptionData({
    required this.subscriptionType,
    required this.subscriptionName,
    required this.brand,
    required this.registrationDate,
    this.recurringPeriod,
  });

  SubscriptionData copyWith({
    String? subscriptionType,
    String? subscriptionName,
    String? brand,
    DateTime? registrationDate,
    String? recurringPeriod,
  }) {
    return SubscriptionData(
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      brand: brand ?? this.brand,
      registrationDate: registrationDate ?? this.registrationDate,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscriptionType': subscriptionType,
      'subscriptionName': subscriptionName,
      'brand': brand,
      'registrationDate': registrationDate.toIso8601String(),
      'recurringPeriod': recurringPeriod,
    };
  }

  factory SubscriptionData.fromMap(Map<String, dynamic> map) {
    return SubscriptionData(
      subscriptionType: map['subscriptionType'] ?? '',
      subscriptionName: map['subscriptionName'] ?? '',
      brand: map['brand'] ?? '',
      registrationDate: DateTime.parse(map['registrationDate']),
      recurringPeriod: map['recurringPeriod'],
    );
  }

  @override
  String toString() {
    return 'SubscriptionData{subscriptionType: $subscriptionType, subscriptionName: $subscriptionName, brand: $brand, registrationDate: $registrationDate, recurringPeriod: $recurringPeriod}';
  }
}