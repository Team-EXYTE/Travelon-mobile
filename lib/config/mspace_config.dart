// /// Configuration class for mspace payment settings
// ///
// /// This file contains the configuration for mspace payment integration.
// /// For production, ensure these values are properly secured and not hardcoded.
// class MspaceConfig {
//   /// mspace API base URL
//   static const String baseUrl = 'https://api.mspace.lk';

//   /// Application ID provided by mspace
//   /// Replace with your actual application ID from mspace
//   static const String applicationId = 'APP_999999';

//   /// Application password provided by mspace
//   /// Replace with your actual password from mspace
//   /// In production, consider using environment variables or secure storage
//   static const String password = '95904999aa8edb0c038b3295fdd271de';

//   /// Default currency for transactions
//   static const String currency = 'LKR';

//   /// Payment instrument name for mobile account charging
//   static const String paymentInstrumentName = 'Mobile Account';

//   /// Whether to use sandbox/test environment
//   /// Set to false for production
//   static const bool isTestMode = true;

//   /// Test mode base URL (if different from production)
//   static const String testBaseUrl = 'https://test-api.mspace.lk';

//   /// Get the appropriate base URL based on test mode
//   static String get apiBaseUrl => isTestMode ? testBaseUrl : baseUrl;
// }
