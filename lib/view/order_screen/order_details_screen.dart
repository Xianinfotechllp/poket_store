// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:poketstore/controllers/order_controller/order_controller.dart';
// import 'package:poketstore/model/order_model/order_model.dart';
// import 'package:provider/provider.dart';

// class OrderDetailScreen extends StatefulWidget {
//   final String orderId;

//   const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<OrderProvider>(
//         context,
//         listen: false,
//       ).fetchOrderDetails(widget.orderId); // Use the new provider
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Order Details',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         shadowColor: Colors.transparent,
//       ),
//       body: Consumer<OrderProvider>(
//         builder: (context, orderProvider, _) {
//           if (orderProvider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
//               ),
//             );
//           } else if (orderProvider.selectedOrder == null &&
//               !orderProvider.isLoading) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     color: Colors.black,
//                     size: 48,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Failed to load order details',
//                     style: TextStyle(color: Colors.grey, fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),
//                   // ElevatedButton(
//                   //   onPressed: () {
//                   //     Provider.of<OrderProvider>(
//                   //       context,
//                   //       listen: false,
//                   //     ).fetchOrderDetails(widget.orderId);
//                   //   },
//                   //   child: const Text('Retry'),
//                   // ),
//                 ],
//               ),
//             );
//           } else {
//             final order = orderProvider.selectedOrder!;
//             log("Order ID: ${order.id} (${order.id.runtimeType})");
//             log("User ID: ${order.userId} (${order.userId.runtimeType})");
//             log(
//               "Address: ${order.address.toJson()} (${order.address.runtimeType})",
//             );
//             log(
//               "Items: ${order.items.map((item) => item.toJson()).toList()} (${order.items.runtimeType})",
//             );
//             log(
//               "Total Amount: ${order.totalAmount} (${order.totalAmount.runtimeType})",
//             );
//             log("Status: ${order.status} (${order.status.runtimeType})");
//             log(
//               "Payment Status: ${order.paymentStatus} (${order.paymentStatus.runtimeType})",
//             );
//             log(
//               "Created At: ${order.createdAt} (${order.createdAt.runtimeType})",
//             );
//             log("Order Details: ${order.toJson()}");
//             return SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 16),
//                   _buildOrderSummary(order),
//                   const SizedBox(height: 20),
//                   _buildOrderItems(order),
//                   const SizedBox(height: 20),
//                   _buildShippingAddress(order.address),
//                   const SizedBox(height: 20),
//                   _buildPaymentSummary(order),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildOrderSummary(Order order) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'ORDER SUMMARY',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               letterSpacing: 0.5,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow('Order Number', '#${order.id.substring(0, 8)}'),
//           const SizedBox(height: 12),
//           _buildDetailRow('Order Date', _formatDate(order.createdAt)),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Status', style: TextStyle(color: Colors.black87)),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(order.status).withAlpha(25),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: _getStatusColor(order.status),
//                     width: 0.5,
//                   ),
//                 ),
//                 child: Text(
//                   order.status.toUpperCase(),
//                   style: TextStyle(
//                     color: _getStatusColor(order.status),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.black87)),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOrderItems(Order order) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'ITEMS (${order.items.length})',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               letterSpacing: 0.5,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: order.items.length,
//             separatorBuilder: (context, index) => const Divider(height: 24),
//             itemBuilder: (context, index) {
//               final item = order.items[index];
//               return Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       color: Colors.grey[100],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'Qty: ${item.quantity}',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     '\$${(item.price * item.quantity).toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShippingAddress(Address address) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'SHIPPING ADDRESS',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               letterSpacing: 0.5,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Address: ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   address.street,
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'City: ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   '${address.city}, ${address.state}',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Pincode: ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   address.pincode,
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentSummary(Order order) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(13),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const Text(
//             'PAYMENT SUMMARY',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               letterSpacing: 0.5,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildPaymentRow(
//             'Subtotal',
//             '\$${order.totalAmount.toStringAsFixed(2)}',
//           ),
//           const SizedBox(height: 8),
//           // _buildPaymentRow('Shipping', '\$0.00'),
//           const SizedBox(height: 12),
//           const Divider(height: 1, color: Colors.black12),
//           const SizedBox(height: 12),
//           _buildPaymentRow(
//             'Total',
//             '\$${order.totalAmount.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: isTotal ? Colors.black : Colors.black87,
//             fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//             fontSize: isTotal ? 16 : 14,
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'processing':
//         return Colors.orange;
//       case 'shipped':
//         return Colors.blue;
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _formatDate(DateTime? date) {
//     //Making the date nullable.
//     if (date == null) {
//       return 'N/A'; // Or any other default value
//     }
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
// }
