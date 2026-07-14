import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeConfig {
  StripeConfig._();

  static String get publishableKey => dotenv.get(
        'STRIPE_PUBLISHABLE_KEY',
        fallback:
            'pk_live_51ICfltKRxWcMtHxmlHVF8blMcimsdVpRiY0v909YwWDh0mKsd46qIaILeDK2Z1MQvQJeScIfkjd72Yk5ad4ubt3Y00XZ58Q4zk',
      );

  static const String merchantDisplayName = 'Outdoorda';
}
