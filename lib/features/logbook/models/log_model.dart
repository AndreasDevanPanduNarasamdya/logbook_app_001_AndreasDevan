import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
  final String title;
  final String date;
  final String description;
  final String category;
  bool isSynced;

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    this.category = 'Pribadi',
    this.isSynced = true,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    var rawId = map['_id'];
    ObjectId? parsedId;
    bool isFromCloud = false;

    if (rawId is ObjectId) {
      parsedId = rawId;
      isFromCloud = true;
    } else if (rawId is String && rawId.length == 24) {
      try {
        parsedId = ObjectId.fromHexString(rawId);
      } catch (e) {
        parsedId = null;
      }
    }

    return LogModel(
      id: parsedId,
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',

      isSynced: isFromCloud ? true : (map['isSynced'] ?? true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'title': title,
      'date': date,
      'description': description,
      'category': category,
      'isSynced': isSynced,
    };
  }
}
