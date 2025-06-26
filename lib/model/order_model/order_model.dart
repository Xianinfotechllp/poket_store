class PlaceOrderRequest {
  final List<OrderItem> items;
  final String addressId;

  PlaceOrderRequest({required this.items, required this.addressId});

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'addressId': addressId,
  };
}

class OrderItem {
  final String productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}

class OrderResponse {
  final String message;
  final OrderData order;
  final bool success;

  OrderResponse({
    required this.message,
    required this.order,
    required this.success,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      message: json['message'],
      order: OrderData.fromJson(json['order']),
      success: json['success'] ?? false,
    );
  }
}

class OrderData {
  final String userId;
  final List<OrderedItem> items;
  final int totalCartAmount;
  final String status;
  final String paymentStatus;
  final OrderAddress address;
  final String id;

  OrderData({
    required this.userId,
    required this.items,
    required this.totalCartAmount,
    required this.status,
    required this.paymentStatus,
    required this.address,
    required this.id,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      userId: json['userId'],
      items:
          (json['items'] as List).map((e) => OrderedItem.fromJson(e)).toList(),
      totalCartAmount: json['totalCartAmount'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      address: OrderAddress.fromJson(json['address']),
      id: json['_id'],
    );
  }
}

class OrderedItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final int totalAmount;

  OrderedItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalAmount,
  });

  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    return OrderedItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
    );
  }
}

class OrderAddress {
  final String houseNo;
  final String area;
  final String landmark;
  final String town;
  final String state;
  final String pincode;
  final String phoneNumber;
  final String countryName;

  OrderAddress({
    required this.houseNo,
    required this.area,
    required this.landmark,
    required this.town,
    required this.state,
    required this.pincode,
    required this.phoneNumber,
    required this.countryName,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      houseNo: json['houseNo'],
      area: json['area'],
      landmark: json['landmark'],
      town: json['town'],
      state: json['state'],
      pincode: json['pincode'],
      phoneNumber: json['phoneNumber'],
      countryName: json['countryName'],
    );
  }
}
