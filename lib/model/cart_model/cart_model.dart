class CartItem {
  final String? productId;
  final String? name;
  // final Product? product;
  final int? price;
  final String? productImage;
  final int? quantity;
  final int? totalAmount;
  final String? id;

  CartItem({
    this.productId,
    // this.product,
    this.name,
    this.price,
    this.productImage,
    this.quantity,
    this.totalAmount,
    this.id,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'];

    return CartItem(
      // product: Product.fromJson(json['productId']),
      productId: product is String ? product : product['_id'],
      name: product is Map ? product['name'] : null,
      price: product is Map ? product['price'] : null,
      productImage: product is Map ? product['productImage'] : null,
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "quantity": quantity,
      "totalAmount": totalAmount,
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

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "items": items.map((item) => item.toJson()).toList(),
      "_id": id,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

// class Product {
//   final String id;
//   final String name;
//   final int price;
//   final String productImage;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.productImage,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id'],
//       name: json['name'],
//       price: json['price'],
//       productImage: json['productImage'],
//     );
//   }
// }

// class CartItem {
//   final String id;
//   final Product product;
//   final int quantity;
//   final int totalAmount;

//   CartItem({
//     required this.id,
//     required this.product,
//     required this.quantity,
//     required this.totalAmount,
//   });

//   factory CartItem.fromJson(Map<String, dynamic> json) {
//     return CartItem(
//       id: json['_id'],
//       product: Product.fromJson(json['productId']),
//       quantity: json['quantity'],
//       totalAmount: json['totalAmount'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'productId': product.toJson(),
//       'quantity': quantity,
//       'totalAmount': totalAmount,
//     };
//   }
// }
