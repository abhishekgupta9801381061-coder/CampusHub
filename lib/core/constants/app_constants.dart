class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'CampusHub';
  static const String appTagline = 'Privacy-first private campus network for Freshmen';
  static const String appVersion = '1.0.0';

  // Server-Ready Business Rules & Rate Limits
  static const int maxPartnerRequestsPerDay = 1;
  static const int maxPartnerRequestEditsPerDay = 3;
  static const int partnerRequestExpiryDays = 5;
  static const int maxActiveGroupsPerUser = 4;

  // Curated University Data Lists
  static const List<String> branches = [
    'Computer Science & Engineering',
    'Electronics & Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Data Science & AI',
    'Information Technology',
  ];

  static const List<String> hostels = [
    'Hostel H-1 (Raman)',
    'Hostel H-2 (Aryabhata)',
    'Hostel H-3 (Kalam)',
    'Hostel H-4 (Bhabha)',
    'Hostel G-1 (Kalpana)',
    'Hostel G-2 (Gargi)',
    'Hostel G-3 (Maitreyi)',
  ];

  static const List<String> securityQuestions = [
    'What is your favorite programming language or tech skill?',
    'What was the name of your high school physics teacher?',
    'What was your dream university or hobby before college?',
    'What is the title of your all-time favorite book or movie?',
    'What was the model of your first phone or laptop?',
  ];

  static const List<String> partnerRequestTypes = [
    'Hackathon Team',
    'Startup Co-Founder',
    'Course Project',
    'Study Partner',
    'Research Paper',
    'Coding Competition',
  ];

  static const List<String> confessionCategories = [
    '#General',
    '#CSE',
    '#ECE',
    '#ME',
    '#Civil',
    '#Hostel',
  ];

  static const List<String> exchangeCategories = [
    'Textbooks',
    'Calculators',
    'Lab coats',
    'Notes',
    'Stationery',
    'Hardware & Gadgets',
    'Other',
  ];

  static const List<String> achievementStatuses = [
    'pending',
    'verified',
    'rejected',
  ];
}
