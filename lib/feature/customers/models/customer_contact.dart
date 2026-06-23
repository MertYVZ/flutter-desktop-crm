import 'package:Ok/product/database/app_database.dart';
import 'package:equatable/equatable.dart';

final class CustomerContactItem extends Equatable {
  const CustomerContactItem({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.title,
    required this.email,
    required this.phone,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String fullName;
  final String? title;
  final String? email;
  final String? phone;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerContactItem.fromEntity(CustomerContact entity) {
    return CustomerContactItem(
      id: entity.id,
      customerId: entity.customerId,
      fullName: entity.fullName,
      title: entity.title,
      email: entity.email,
      phone: entity.phone,
      isPrimary: entity.isPrimary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  String get displayTitle =>
      (title?.trim().isNotEmpty ?? false) ? title!.trim() : '-';

  String get displayEmail =>
      (email?.trim().isNotEmpty ?? false) ? email!.trim() : '-';

  String get displayPhone =>
      (phone?.trim().isNotEmpty ?? false) ? phone!.trim() : '-';

  @override
  List<Object?> get props => [
        id,
        customerId,
        fullName,
        title,
        email,
        phone,
        isPrimary,
        createdAt,
        updatedAt,
      ];
}
