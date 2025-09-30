# TODO: Add Payment Method Selection to Checkout

## Steps to Complete

- [x] Create PaymentMethod enum in lib/models/payment_method.dart
- [x] Update Order model in lib/models/order.dart to include paymentMethod field
- [x] Update CartController in lib/controllers/cart_controller.dart to manage selectedPaymentMethod
- [x] Update CheckoutScreen in lib/screens/checkout_screen.dart to display payment method selection UI
- [x] Update DatabaseService in lib/services/database_service.dart to handle paymentMethod in orders table

## Followup Steps

- [ ] Test the checkout flow with payment selection
- [ ] Verify orders are saved with payment method in database
- [ ] Check order history screen displays payment method
