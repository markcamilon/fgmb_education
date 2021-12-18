import 'package:workistant/models/workCard.model.dart';

class WorkList {
  var id;
  var boardID;
  var posIndex;
  var title;
  var createdOn;
  var createdBy;
  List<WorkCard> cards;

  WorkList({
    this.id,
    this.boardID,
    this.posIndex,
    this.title,
    this.createdOn,
    this.createdBy,
    required this.cards,
  });

  factory WorkList.fromJson(Map<String, dynamic> json) {
    List<WorkCard> wC = [];

    if (json['cards'] != null) {
      json['cards'].forEach((v) {
        wC.add(
          new WorkCard.fromJson(v),
        );
      });
    }

    return WorkList(
      id: json['id'],
      boardID: json['board_id'],
      posIndex: json['pos_index'],
      title: json['title'],
      createdOn: json['created_on'],
      createdBy: json['created_by'],
      cards: wC,
    );
  }
}
