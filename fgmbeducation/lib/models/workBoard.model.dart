class WorkBoard {
  final String id;
  final String ownerID;
  final String title;
  final String shared;
  final String createdOn;
  final String updatedOn;

  WorkBoard({
    required this.id,
    required this.ownerID,
    required this.title,
    required this.shared,
    required this.createdOn,
    required this.updatedOn,
  });

  factory WorkBoard.fromJson(Map<String, dynamic> json) {
    return WorkBoard(
      id: json['id'],
      ownerID: json['owner_id'],
      title: json['title'],
      shared: json['shared'],
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
    );
  }
}
