class AppStrings {
  AppStrings._();

  // Privacy notices
  static const String privacyNoticeZeroPhone = 'Phone number and personal email are never required.';
  static const String privacyNoticeZeroRoom = 'Exact room number is strictly confidential and never asked.';
  static const String ghostModeActiveNotice = "Ghost Mode is ON. You're invisible in Discover & Search.";
  static const String socialBridgeNotice = 'Your contact information is never publicly displayed. Generate a temporary, revocable connection link.';

  // Rate-limiting UX messages
  static const String partnerRequestDailyLimitReached = "You've reached today's partner-request limit (1 per calendar day). You can create another request tomorrow.";
  static const String partnerRequestEditLimitReached = "You've used all 3 edits available for today.";
  static const String groupsMaxLimitReached = 'You have reached the maximum allowed limit of 4 active groups.';

  // Promotional consent
  static const String promotionalConsentTitle = 'Allow CampusHub to feature my achievements';
  static const String promotionalConsentDesc = 'Permit your verified badges and hackathon wins to appear on university milestone carousels. Personal details are never revealed.';
}
