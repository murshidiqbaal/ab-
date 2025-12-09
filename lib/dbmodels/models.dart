import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 1)
class Student {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isSelected;

  @HiveField(2)
  String paymentMethod;

  @HiveField(3)
  double? balance;

  @HiveField(4)
  List<Student> studentsWithLessThanAmount;

  @HiveField(5)
  int? id;

  @HiveField(6)
  int? collectionId;

  Student({
    required this.name,
    this.isSelected = false,
    this.paymentMethod = '',
    this.balance,
    required this.studentsWithLessThanAmount,
    this.id,
    this.collectionId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      collectionId: json['collection_id'],
      name: json['name'] ?? '',
      isSelected: json['is_selected'] ?? false,
      paymentMethod: json['payment_method'] ?? '',
      balance:
          json['balance'] != null ? (json['balance'] as num).toDouble() : null,
      studentsWithLessThanAmount: [], // Handle separately if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (collectionId != null) 'collection_id': collectionId,
      'name': name,
      'is_selected': isSelected,
      'payment_method': paymentMethod,
      'balance': balance,
    };
  }
}

@HiveType(typeId: 2)
class Collection extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String amount;

  @HiveField(2)
  List<Student> studentList;

  @HiveField(3)
  int? id;

  Collection({
    required this.title,
    required this.amount,
    required this.studentList,
    this.id,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'] ?? '',
      amount: json['amount'] ?? '',
      studentList: [], // Students fetched separately usually
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
    };
  }
}
