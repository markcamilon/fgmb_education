import 'package:workistant/models/workBoard.model.dart';
import 'package:workistant/models/workList.model.dart';

class WorkBoardInfo {
  WorkBoard info;
  List<WorkList> lists;

  WorkBoardInfo({
    required this.info,
    required this.lists,
  });

  factory WorkBoardInfo.fromJson(Map<String, dynamic> json) {
    List<WorkList> workLists = [];
    WorkBoard workInfo;

    if (json['lists'] != null) {
      json['lists'].forEach((values) {
        workLists.add(
          new WorkList.fromJson(values),
        );
      });
    }

    workInfo = WorkBoard.fromJson(json['info']);

    return WorkBoardInfo(
      info: workInfo,
      lists: workLists,
    );
  }
}
