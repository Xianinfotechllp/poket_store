class HomeProduct {
  final String id;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final List<String> category;
  final String productImage;
  final int sold;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final Shop shop;

  HomeProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.shop,
  });

  factory HomeProduct.fromJson(Map<String, dynamic> json) {
    return HomeProduct(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
      category: List<String>.from(json['category']),
      productImage: json['productImage'],
      sold: json['sold'],
      estimatedTime: json['estimatedTime'],
      productType: json['productType'],
      deliveryOption: json['deliveryOption'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      shop: Shop.fromJson(json['shop']),
    );
  }
}

class Shop {
  final String id;
  final String shopName;
  final String state;
  final String place;
  final String pinCode;
  final String locality;

  Shop({
    required this.id,
    required this.shopName,
    required this.state,
    required this.place,
    required this.pinCode,
    required this.locality,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['_id'],
      shopName: json['shopName'],
      state: json['state'],
      place: json['place'],
      pinCode: json['pinCode'],
      locality: json['locality'],
    );
  }
}
