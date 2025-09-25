
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class ContactModel {
  String? id;
  String name;
  String phone;
  String profession;
  DateTime createdAt;
  DateTime updatedAt;

  ContactModel({
    this.id,
    required this.name,
    required this.phone,
    required this.profession,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profession': profession,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profession: map['profession'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? profession,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profession: profession ?? this.profession,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
    }
  }

  @override
  String toString() {
    return 'ContactModel{id: $id, name: $name, phone: $phone, profession: $profession}';
  }
}