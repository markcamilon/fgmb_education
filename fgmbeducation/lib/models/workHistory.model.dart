class WorkHistoryTile {
  final String id;
  final String boardID;
  final String content;
  final String createdOn;

  WorkHistoryTile({
    required this.id,
    required this.boardID,
    required this.content,
    required this.createdOn,
  });

  factory WorkHistoryTile.fromJson(Map<String, dynamic> json) {
    return WorkHistoryTile(
      id: json['id'],
      boardID: json['board_id'],
      content: json['content'],
      createdOn: json['created_on'],
    );
  }
}
