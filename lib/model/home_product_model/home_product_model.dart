class ShopWithProducts {
  final String shopName;
  final List<HomeProduct> products;

  ShopWithProducts({required this.shopName, required this.products});

  factory ShopWithProducts.fromJson(Map<String, dynamic> json) {
    // Ensure 'products' key exists and is a List.  Important for null safety and type checking.
    List<dynamic> productsData = json['products'] ??
        []; // Default to empty list if 'products' is null or missing.

    return ShopWithProducts(
      shopName: json['shopName'] ?? "",
      products: productsData
          .map((productJson) => HomeProduct.fromJson(productJson))
          .toList(),
    );
  }
}

class HomeProduct {
  final String id;
  final Shop shop;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String productImage;
  final int sold;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  final String userId;
  final bool favorite;
  final String category;
  final String createdAt;
  final String updatedAt;
  final int v;

  HomeProduct({
    required this.id,
    required this.shop,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.userId,
    required this.favorite,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory HomeProduct.fromJson(Map<String, dynamic> json) {
    return HomeProduct(
      id: json['_id'] ?? "",
      shop: Shop.fromJson(json['shop'] ?? {}),
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productImage: json['productImage'] ?? "",
      sold: json['sold'] ?? 0,
      estimatedTime: json['estimatedTime'] ?? "",
      productType: json['productType'] ?? "",
      deliveryOption: json['deliveryOption'] ?? "",
      userId: json['userId'] ?? "",
      favorite: json['favorite'] ?? false,
      category: json['category'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      v: json['__v'] ?? 0,
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
      id: json['_id'] ?? "",
      shopName: json['shopName'] ?? "",
      state: json['state'] ?? "",
      place: json['place'] ?? "",
      pinCode: json['pinCode'] ?? "",
      locality: json['locality'] ?? "",
    );
  }
}
