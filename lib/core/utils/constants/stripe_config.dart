class StripeConfig {
  StripeConfig._();

  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51TJr9jKp2PreO93W4yGrHTj0yPXqICAiQy6p8CIWojxDOKsjeOkN5so0WRPkgSuJTqSH4bs2tmimSwgg6nHZvE3S00MfnKMOO5',
  );

  static const String merchantDisplayName = 'Outdoorda';
}
