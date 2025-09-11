// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constants.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final int typeId = 2;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.groceries;
      case 1:
        return TransactionCategory.transportation;
      case 2:
        return TransactionCategory.housing;
      case 3:
        return TransactionCategory.entertainment;
      case 4:
        return TransactionCategory.health;
      case 5:
        return TransactionCategory.food;
      case 6:
        return TransactionCategory.utilities;
      case 7:
        return TransactionCategory.shopping;
      case 8:
        return TransactionCategory.education;
      case 9:
        return TransactionCategory.personal;
      case 10:
        return TransactionCategory.salary;
      case 11:
        return TransactionCategory.freelance;
      case 12:
        return TransactionCategory.investments;
      case 13:
        return TransactionCategory.rental;
      case 14:
        return TransactionCategory.business;
      case 15:
        return TransactionCategory.gifts;
      case 16:
        return TransactionCategory.other;
      default:
        return TransactionCategory.groceries;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.groceries:
        writer.writeByte(0);
        break;
      case TransactionCategory.transportation:
        writer.writeByte(1);
        break;
      case TransactionCategory.housing:
        writer.writeByte(2);
        break;
      case TransactionCategory.entertainment:
        writer.writeByte(3);
        break;
      case TransactionCategory.health:
        writer.writeByte(4);
        break;
      case TransactionCategory.food:
        writer.writeByte(5);
        break;
      case TransactionCategory.utilities:
        writer.writeByte(6);
        break;
      case TransactionCategory.shopping:
        writer.writeByte(7);
        break;
      case TransactionCategory.education:
        writer.writeByte(8);
        break;
      case TransactionCategory.personal:
        writer.writeByte(9);
        break;
      case TransactionCategory.salary:
        writer.writeByte(10);
        break;
      case TransactionCategory.freelance:
        writer.writeByte(11);
        break;
      case TransactionCategory.investments:
        writer.writeByte(12);
        break;
      case TransactionCategory.rental:
        writer.writeByte(13);
        break;
      case TransactionCategory.business:
        writer.writeByte(14);
        break;
      case TransactionCategory.gifts:
        writer.writeByte(15);
        break;
      case TransactionCategory.other:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
