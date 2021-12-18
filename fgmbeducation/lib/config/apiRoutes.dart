class APIRoutes {
  static final String baseURL = "http://api.macvindev.com/";
  static final String registerUser = baseURL + "user/register";
  static final String loginUser = baseURL + "user/login";
  static final String changePassword = baseURL + "user/changepassword";

  static final String attemptReset = baseURL + "user/sendresetemail";
  static final String verifyOTP = baseURL + "user/verifyotp";
  static final String resetPassword = baseURL + "user/resetpassword";

  static final String getWorkBoards = baseURL + "boards/getworkboards";
  static final String getFinanceBoards = baseURL + "boards/getfinanceboards";
  static final String addWorkBoard = baseURL + "boards/addworkboard";
  static final String addFinanceBoard = baseURL + "boards/addfinanceboard";

  static final String addWorkList = baseURL + "boards/addworklist";
  static final String addWorkCard = baseURL + "boards/addworkcard";

  static final String createHistoryLog = baseURL + "boards/createhistorylog";
  static final String getWorkHistory = baseURL + "boards/getworkhistory";

  static final String deleteWorkCard = baseURL + "boards/deleteworkcard";
  static final String deleteWorkList = baseURL + "boards/deleteworklist";
  static final String deleteWorkBoard = baseURL + "boards/deleteworkboard";

  static final String editWorkList = baseURL + "boards/editworklist";
  static final String editWorkCard = baseURL + "boards/editworkcard";

  static final String getFinanceBoard = baseURL + "boards/getfinanceboard";
  static final String getFinanceHistory =
      baseURL + "boards/gettransactionhistory";
  static final String deleteFinanceBoard =
      baseURL + "boards/deletefinanceboard";
  static final String makeTransaction = baseURL + "boards/maketransaction";

  static final String addReminder = baseURL + "reminders/add";
  static final String editReminder = baseURL + "reminders/edit";
  static final String getReminders = baseURL + "reminders/get";
  static final String getTodayReminders =
      baseURL + "reminders/getfortodayreminders";
  static final String deleteReminder = baseURL + "reminders/delete";

  static final String getFullBoardInfo = baseURL + "boards/getfullboardinfo";

  static final String changeCardPosition =
      baseURL + "boards/changecardposition";

  static final String changeListPosition =
      baseURL + "boards/changelistposition";
}
