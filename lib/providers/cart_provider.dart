import 'package:flutter/foundation.dart';
import '../models/membership.dart';

class CartProvider with ChangeNotifier {
  Membership? _selectedMembership;

  Membership? get selectedMembership => _selectedMembership;

  bool get isCartEmpty => _selectedMembership == null;

  void addToCart(Membership membership) {
    _selectedMembership = membership;
    notifyListeners();
  }

  void clearCart() {
    _selectedMembership = null;
    notifyListeners();
  }
}
