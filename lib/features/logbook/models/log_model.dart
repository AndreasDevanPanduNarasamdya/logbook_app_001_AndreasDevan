import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id; // Penanda unik global dari MongoDB
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    this.category = 'Pribadi', // Default kategori
  });

  // Membongkar data dari Cloud menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
    );
  }

  // Memasukkan data ke Map (BSON) untuk dikirim ke Cloud
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(), // Buat ID otomatis jika belum ada
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
  }
}
