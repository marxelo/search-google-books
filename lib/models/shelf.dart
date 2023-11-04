import 'package:gbooks/enums/ownership.dart';
import 'package:gbooks/enums/read_status.dart';

class Shelf {
  late int? id;
  String externalId;
  ReadStatus readStatus;
  Ownership ownership;

  Shelf({
    this.id,
    required this.externalId,
    required this.readStatus,
    required this.ownership,
  });

  // Convert a BookManager into a Map. The keys must correspond to the names of the
  // source fields in the BookManager class.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'externalId': externalId,
      'readStatus': readStatus.index,
      'ownership': ownership.index,
    };
  }

  // Convert a Map into a BookManager. The keys must correspond to the names of the
  // source fields in the BookManager class.
  static Shelf fromMap(Map<String, dynamic> map) {
    return Shelf(
      id: map['id'],
      externalId: map['externalId'],
      readStatus: ReadStatus.values[map['readStatus']],
      ownership: Ownership.values[map['ownership']],
    );
  }
}
