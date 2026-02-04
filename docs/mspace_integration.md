<!-- # mspace Payment Integration

This documentation describes the mspace mobile payment integration implemented in the Travelon mobile app.

## Overview

The app integrates with [mspace](https://www.mspace.lk/) for mobile payments, allowing users to pay for event bookings directly from their mobile account balance.

## Features

- Direct mobile account charging via mspace API
- Real-time payment processing
- Sri Lankan mobile number validation
- Comprehensive error handling
- Payment success/failure feedback
- Transaction tracking with reference IDs

## Integration Components

### 1. MspacePaymentService (`lib/services/mspace_payment_service.dart`)

Main service class that handles:

- Payment processing via `/caas/direct/debit` endpoint
- Phone number formatting for Sri Lankan mobile numbers
- Transaction ID generation
- Response handling and error management

### 2. MspaceConfig (`lib/config/mspace_config.dart`)

Configuration class containing:

- API endpoints (test/production)
- Application credentials
- Default settings
- Test mode flag

### 3. CheckoutScreen Updates (`lib/screens/checkout_screen.dart`)

Enhanced checkout flow with:

- Mobile number input field with validation
- Real-time payment processing
- Success/error dialog displays
- mspace branding integration

## Setup Instructions

### 1. Obtain mspace Credentials

1. Contact [mspace](https://www.mspace.lk/) to register your application
2. Obtain your Application ID and Password
3. Get access to test/sandbox environment

### 2. Configure Credentials

Update `lib/config/mspace_config.dart` with your credentials:

```dart
class MspaceConfig {
  static const String applicationId = 'YOUR_APP_ID'; // Replace with actual
  static const String password = 'YOUR_PASSWORD';     // Replace with actual
  static const bool isTestMode = true;                // Set false for production
}
```

### 3. Production Deployment

For production deployment:

1. Set `isTestMode = false` in `MspaceConfig`
2. Update credentials with production values
3. Implement secure credential storage (environment variables, secure storage)
4. Test thoroughly with real mobile numbers

## API Integration Details

### Endpoint Used

- **URL**: `https://api.mspace.lk/caas/direct/debit`
- **Method**: POST
- **Content-Type**: `application/json;charset=utf-8`

### Request Format

```json
{
  "applicationId": "APP_999999",
  "password": "encrypted_password",
  "externalTrxId": "unique_transaction_id",
  "subscriberId": "tel:94771234567",
  "paymentInstrumentName": "Mobile Account",
  "amount": "100.00",
  "currency": "LKR"
}
```

### Response Format

**Success Response:**

```json
{
  "externalTrxId": "TRX123456789",
  "internalTrxId": "321",
  "referenceId": "12345678",
  "timeStamp": "2024-07-03T12:48:10-0400",
  "statusCode": "S1000",
  "statusDetail": "Success."
}
```

**Error Response:**

```json
{
  "statusCode": "E1001",
  "statusDetail": "Insufficient balance"
}
```

## Phone Number Validation

The service validates and formats Sri Lankan mobile numbers:

- Accepts formats: `0771234567`, `771234567`, `+94771234567`
- Converts to: `tel:94771234567`
- Validates: Must start with `7` and be 9 digits long (excluding country code)

## Error Handling

The integration handles various error scenarios:

### Network Errors

- Connection timeouts
- Server unavailability
- HTTP status errors

### Payment Errors

- Insufficient balance
- Invalid mobile number
- Account restrictions
- Service unavailable

### Validation Errors

- Invalid phone number format
- Missing required fields
- Invalid amount values

## Security Considerations

### Current Implementation

- HTTPS communication
- Request/response validation
- Error message sanitization

### Production Recommendations

1. **Credential Security**

   - Use environment variables for credentials
   - Implement secure storage for sensitive data
   - Regular credential rotation

2. **Additional Security**

   - Implement request signing/verification
   - Add request rate limiting
   - Log transactions for audit trail
   - Implement fraud detection

3. **PCI Compliance**
   - Follow PCI DSS guidelines
   - Secure transmission of payment data
   - Regular security audits

## Testing

### Test Mobile Numbers

Use valid Sri Lankan mobile numbers for testing:

- Format: `07XXXXXXXX` or `+947XXXXXXXX`
- Must be registered with mspace for testing

### Test Scenarios

1. **Successful Payment**

   - Valid mobile number
   - Sufficient balance
   - Valid amount

2. **Failed Payment**

   - Insufficient balance
   - Invalid mobile number
   - Service unavailable

3. **Network Errors**
   - No internet connection
   - Server timeouts
   - Invalid responses

## Monitoring and Logging

### Transaction Logging

- Log all payment requests/responses
- Store transaction IDs for reference
- Monitor success/failure rates

### Error Monitoring

- Track payment failures
- Monitor API response times
- Alert on high failure rates

### Performance Metrics

- Payment processing times
- API availability
- User conversion rates

## Support and Troubleshooting

### Common Issues

1. **Payment Fails with "Invalid Subscriber"**

   - Verify mobile number format
   - Ensure number is registered with mspace
   - Check if number has sufficient balance

2. **HTTP 401 Unauthorized**

   - Verify application credentials
   - Check if credentials are properly encoded
   - Ensure application is active

3. **Network Timeout**
   - Check internet connectivity
   - Verify API endpoint availability
   - Implement retry logic

### Contact Information

- **mspace Support**: [Contact details from mspace]
- **API Documentation**: https://www.mspace.lk/API_Documentation/
- **Developer Portal**: [If available]

## Future Enhancements

### Planned Features

1. **OTP Integration**

   - Implement OTP flow for additional security
   - Use mspace OTP request/verify APIs

2. **Subscription Management**

   - User subscription status
   - Recurring payments
   - Subscription notifications

3. **Location Services**

   - Location-based payment restrictions
   - Geo-tagged transactions

4. **Enhanced Security**
   - Two-factor authentication
   - Biometric verification
   - Advanced fraud detection

### API Extensions

- Balance inquiry before payment
- Transaction history retrieval
- Payment status polling
- Refund processing

## Version History

- **v1.0.0** - Initial mspace integration
  - Direct debit payment processing
  - Basic error handling
  - Mobile number validation

---

For technical support or questions about this integration, please contact the development team. -->
