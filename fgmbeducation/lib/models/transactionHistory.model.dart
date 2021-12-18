class TransactionHistory {
  final String id;
  final String ownerID;
  final String boardID;
  final String reason;
  final String amount;
  final String isAddition;
  final String createdBy;
  final String createdOn;

  TransactionHistory({
    required this.id,
    required this.ownerID,
    required this.boardID,
    required this.reason,
    required this.amount,
    required this.isAddition,
    required this.createdBy,
    required this.createdOn,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'],
      ownerID: json['owner_id'],
      boardID: json['board_id'],
      reason: json['reason'],
      amount: json['amount'],
      isAddition: json['isAddition'],
      createdBy: json['created_by'],
      createdOn: json['created_on'],
    );
  }
}
