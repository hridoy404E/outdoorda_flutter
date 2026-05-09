class StripeConfig {
  StripeConfig._();

  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_live_51ICfltKRxWcMtHxmlHVF8blMcimsdVpRiY0v909YwWDh0mKsd46qIaILeDK2Z1MQvQJeScIfkjd72Yk5ad4ubt3Y00XZ58Q4zk',
  );

  static const String merchantDisplayName = 'Outdoorda';
}
