class Address {
  final String street;
  final String city;
  final String state;
  final String pincode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      pincode: json['pincode'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'state': state, 'pincode': pincode};
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? "",
      name: json['name'] ?? "",
      price: json['price'] ?? "",
      quantity: json['quantity'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final Address address;
  final List<OrderItem> items;
  final int totalAmount;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? "",
      userId: json['userId'] ?? "",
      address: Address.fromJson(json['address'] ?? {}),
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? "",
      paymentStatus: json['paymentStatus'] ?? "",
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'address': address.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
