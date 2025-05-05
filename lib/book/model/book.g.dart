// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      title: fields[0] as String,
      author: fields[1] as String,
      pages: fields[2] as int,
      height: fields[3] as int,
      width: fields[4] as int,
      comment: fields[5] as String?,
      coverImageUrl: fields[6] as String?,
      coverImagePath: fields[7] as String?,
      spineImagePath: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.pages)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.coverImageUrl)
      ..writeByte(7)
      ..write(obj.coverImagePath)
      ..writeByte(8)
      ..write(obj.spineImagePath)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
