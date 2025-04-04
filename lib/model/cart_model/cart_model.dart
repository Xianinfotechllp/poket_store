class CartItem {
  final String? productId;
  final String? name;
  final int? price;
  final String? productImage;
  final int? quantity;
  final int? totalAmount;
  final String? id;

  CartItem({
    this.productId,
    this.name,
    this.price,
    this.productImage,
    this.quantity,
    this.totalAmount,
    this.id,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']['_id'],
      name: json['productId']['name'],
      price: json['productId']['price'],
      productImage: json['productId']['productImage'],
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      // "name": name,
      // "price": price,
      // "productImage": productImage,
      "quantity": quantity,
      "totalAmount": totalAmount,
      // "id": id,
    };
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    required this.userId,
    required this.items,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'],
      items:
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
      id: json['_id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
