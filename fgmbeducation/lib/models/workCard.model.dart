class WorkCard {
  var id;
  var boardID;
  var listID;
  var posIndex;
  var content;
  var createdOn;
  var createdBy;

  WorkCard({
    this.id,
    this.boardID,
    this.listID,
    this.posIndex,
    this.content,
    this.createdOn,
    this.createdBy,
  });

  factory WorkCard.fromJson(Map<String, dynamic> json) {
    return WorkCard(
      id: json['id'],
      boardID: json['board_id'],
      listID: json['list_id'],
      posIndex: json['pos_index'],
      content: json['content'],
      createdOn: json['created_on'],
      createdBy: json['created_by'],
    );
  }
}
