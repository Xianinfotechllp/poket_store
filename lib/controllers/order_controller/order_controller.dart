import 'package:flutter/material.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/service/order_service/order_service.dart';

class OrderController extends ChangeNotifier {
  final OrderService _service = OrderService();
  bool loading = false;
  OrderResponse? orderResponse;

  Future<void> submitOrder(List<OrderItem> items, String addressId) async {
    loading = true;
    notifyListeners();

    final request = PlaceOrderRequest(items: items, addressId: addressId);
    orderResponse = await _service.placeOrder(request);

    loading = false;
    notifyListeners();
  }
}
