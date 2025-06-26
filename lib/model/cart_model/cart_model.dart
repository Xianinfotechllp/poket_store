class CartRequestModel {
  final String productId;
  final int quantity;

  CartRequestModel({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}
