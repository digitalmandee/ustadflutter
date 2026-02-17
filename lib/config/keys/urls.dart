class AppUrls {
  static const String baseUrl = "http://15.235.204.49:5000/";
  static const String otp = "auth/send-otp";
  static const String forgotPass = "auth/forgot-password";
  static const String confirmPass = "auth/user-reset_password";
  static const String verifyOtp = "auth/verify-otp";
  static const String signUp = "auth/user-signup";
  static const String logIn = "auth/user-signin";
  static const String onBoard = "tutor/onboarding";
  static const String googleSignIn = "auth/google-login";
  static const String googleSignUp = "auth/google-signup";
  ///////// Tutor Experience //////////////
  static const String getTutorExp = "tutor/experience";
  static const String addTutorExp = "tutor/experience/add";
  static const String deleteTutorExp = "tutor/experience/delete/";
  static const String editTutorExp = "tutor/experience/edit/";

  ////////////  Add Eduction Tutor ////////
  static const String getTutorEdu = "tutor/education";
  static const String addTutorEdu = "tutor/education/add";
  static const String updateTutorEdu = "tutor/education/edit/";
  static const String deleteTutorEdu = "tutor/education/delete/";
  static const String addAbout = "tutor/about/add";
  static const String editAbout = "tutor/about/edit";
  ////////////   Tutor  Profile  ////////
  static const String getTutorProfile = "tutor/profile";
  static const String editTutorProfile = "tutor/profile/edit";
  static const String deletePic = "/parent/profile/image/delete";

  ////////////  Add parent child Profile ////////
  static const String addChild = "parent/child/add";
  static const String parentOnBoard = "parent/onboarding";
  static const String getChildren = "parent/children";
  static const String getChildrenNotes = "parent/child/notes";
  static const String editChild = "parent/child/update";
  static const String delChild = "parent/child";
  static const String getParentFromtutor = "tutor/parent";
  ////////////  notifications ////////
  static const String getnotifications = "tutor/notification/history";
  static const String dellnotifications = "parent/notifications/bulk-delete";
  ////////////  Tutor Location ////////
  static const String addLocation = "tutor/location";
  static const String getLocations = "tutor/location";
  static const String deleteLocation = "tutor/location";

  ////////////  Cost setting screen ////////
  static const String getcostsetting = "tutor/subject/settings";
  static const String postcostsetting = "tutor/subject/settings";
  static const String editcostsetting = "tutor/subject/settings";
  ////////////  Chat APIs ////////
  static const String getAllChat = "chat/conversations";
  static const String createConversation = "chat/conversations";
  static const String sendMessage = "chat/messages";
  static const String getConverstion = "chat/messages/conversation/";
  static const String markAllRead = "chat/conversationS/";
  static const String getConverstionbyID = "chat/conversations/";
  static const String deleteMessage = "chat/messages";
  static const String sendMedia = "chat/files/upload";
  ////////////  GET TUTORS ////////
  static const String getTutor = "tutor/locations";
  static const String getTutorProfileFromParentSide = "parent/tutor/";

  ///////////////  offers ////////////////
  static const String offerStatus = "parent/offer/";
  static const String paymentIntent = "parent/payfast/subscription/initiate";
  static const String paymentIntentDummy = "parent/payment/intent-bypass";

  ///////////////  Settions ////////////////
  static const String getparentSessions = "tutor/sessions";
  static const String getsessions = "tutor/sessions";
  static const String createSubSession = "tutor/session";
  static const String updateSubSession = "tutor/session";
  static const String getSubsession = "tutor/session";
  ///////////////  Notes ////////////////
  static const String addNotes = "tutor/child/notes";
  ////////////////////  Categories Search Tutor From Parent Side ///////////////////////

  static const String getTutorWithSubject = "tutor/locations";

  ////////////////////  Parent Profie setting ///////////////////////

  static const String getParentProfile = "parent/profile";
  static const String editParentProfile = "parent/profile/edit";

  ////////////////////  TutorDashBiard ///////////////////////

  static const String getTutorEarnings = "tutor/monthly-earnings";
  ////////////////////  ParentDashBiard ///////////////////////

  static const String getParentSpendings = "parent/monthly-spending";

  ////////////////////  PAYMENTS ///////////////////////
  static const String withdrawAmount = "tutor/payment-request";
  static const String parentWithdrawAmount = "parent/payment-request";
  static const String parentUpdateBank = "parent/bank-details";
  static const String getPaymentRequests = "tutor/payment-request";
  static const String getParentCards = "parent/payfast/instruments";
  static const String getParentPaymentRequests = "parent/payment-request";

  ////////////////////  CONTRACTS ///////////////////////
  static const String getTutorContracts = "tutor/contracts";
  static const String getParentContracts = "parent/contracts";
  static const String cancelTutorContract = "tutor/contracts";
  static const String cancelParentContract = "parent/contracts";

  ////////////////////  logout ///////////////////////

  static const String logout = "auth/user-logout";
}
