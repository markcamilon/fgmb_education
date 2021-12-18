class ReminderPalletteData {
  var id;
  var ownerID;
  var message;
  var time;
  var day;
  var status;
  var type;
  var createdOn;
  var notificationKey;

  ReminderPalletteData({
    this.id,
    this.ownerID,
    this.message,
    this.time,
    this.day,
    this.status,
    this.type,
    this.notificationKey,
    this.createdOn,
  });

  factory ReminderPalletteData.fromJson(Map<String, dynamic> json) {
    return ReminderPalletteData(
      id: json['id'],
      ownerID: json['owner_id'],
      message: json['message'],
      time: json['time'],
      day: json['day'],
      status: json['status'],
      type: json['type'],
      notificationKey: json['notification_key'],
      createdOn: json['created_on'],
    );
  }
}
