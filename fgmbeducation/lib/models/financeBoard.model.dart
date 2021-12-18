class FinanceBoard {
  final String id;
  final String ownerID;
  final String budget;
  final String title;
  final String shared;
  final String createdOn;
  final String updatedOn;

  FinanceBoard(
      {required this.id,
      required this.ownerID,
      required this.budget,
      required this.title,
      required this.shared,
      required this.createdOn,
      required this.updatedOn});

  factory FinanceBoard.fromJson(Map<String, dynamic> json) {
    return FinanceBoard(
      id: json['id'],
      ownerID: json['owner_id'],
      budget: json['budget'],
      title: json['title'],
      shared: json['shared'],
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
    );
  }
}
