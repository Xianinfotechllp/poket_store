class FetchCartModel {
  final String message;
  final Cart cart;

  FetchCartModel({required this.message, required this.cart});

  factory FetchCartModel.fromJson(Map<String, dynamic> json) {
    return FetchCartModel(
      message: json['message'],
      cart: Cart.fromJson(json['cart']),
    );
  }
}

class Cart {
  final String id;
  final String userId;
  final List<FetchCartItem> items;
  final String createdAt;
  final String updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      userId: json['userId'],
      items: List<FetchCartItem>.from(
        json['items'].map((x) => FetchCartItem.fromJson(x)),
      ),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class FetchCartItem {
  final FetchProduct product;
  final int quantity;
  final int totalAmount;
  final String id;

  FetchCartItem({
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.id,
  });

  factory FetchCartItem.fromJson(Map<String, dynamic> json) {
    return FetchCartItem(
      product: FetchProduct.fromJson(json['productId']),
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
      id: json['_id'],
    );
  }
}

class FetchProduct {
  final String id;
  final String name;
  final int price;
  final String productImage;

  FetchProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.productImage,
  });

  factory FetchProduct.fromJson(Map<String, dynamic> json) {
    return FetchProduct(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      productImage: json['productImage'],
    );
  }
}
