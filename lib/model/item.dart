
class DataItems {
  int id;
  String name;
  bool complete;


  DataItems(this.id, this.name, this.complete);

  @override
  String toString() {
    return '$name';
  }
  factory DataItems.fromMap(Map<String, dynamic> map) {
    return DataItems(map['id'], map['name'],map['complete']);
  }
}
