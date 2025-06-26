// cart_model.dart
class CartResponseModel {
  final CartModel cart;

  CartResponseModel({required this.cart});

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(cart: CartModel.fromJson(json['cart']));
  }
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final int totalCartPrice;
  final String createdAt;
  final String updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalCartPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'],
      userId: json['userId'],
      items: List<CartItemModel>.from(
        json['items'].map((x) => CartItemModel.fromJson(x)),
      ),
      totalCartPrice: json['totalCartPrice'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final int productPrice;
  final int totalProductPrice;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.productPrice,
    required this.totalProductPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'],
      product: ProductModel.fromJson(json['productId']),
      quantity: json['quantity'],
      productPrice: json['productPrice'],
      totalProductPrice: json['totalProductPrice'],
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String productImage;
  final int price;
  final int quantity;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      productImage: json['productImage'],
      price: json['price'],
      quantity: json['quantity'],
      estimatedTime: json['estimatedTime'],
      productType: json['productType'],
      deliveryOption: json['deliveryOption'],
      category: json['category'],
    );
  }
}
