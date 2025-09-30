# TODO: Fix Lint Issues in az_pos Flutter Project

## Steps to Complete

- [x] Add missing dependencies: printing, esc_pos_bluetooth to pubspec.yaml
- [x] Remove unused imports in lib/screens/checkout_screen.dart (pdf, pdf/widgets, intl)
- [x] Fix deprecated Radio usage in lib/screens/checkout_screen.dart (use RadioGroup)
- [x] Add 'key' parameter to widget constructors in various screens and widgets
- [x] Fix dead code in lib/screens/order_history_screen.dart
- [x] Remove unused import in lib/services/database_service.dart (flutter/foundation.dart)
- [ ] Fix const constructor issue in test/widget_test.dart
- [x] Address other warnings: avoid_print (partial), sort_child_properties_last, etc.
- [ ] Fix unreachable_switch_default in lib/models/payment_method.dart
- [x] Fix unused local variable in database_service.dart
- [x] Fix deprecated withOpacity in product_card.dart

## Followup Steps

- [x] Run flutter analyze to verify all issues are resolved (reduced from 72 to 46)
- [x] Run flutter pub get to install new dependencies
- [ ] Test the app to ensure no runtime issues
