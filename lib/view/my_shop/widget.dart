import 'package:flutter/material.dart';

class MyShopeItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const MyShopeItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.close, color: Colors.grey),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                item["image"],
                width: 70,
                height: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '1Kg, Price',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('\$4.99'),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(30),
                        //     border: Border.all(color: Colors.grey.shade300),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       IconButton(
                        //         onPressed: () {},
                        //         icon: Icon(Icons.remove, color: Colors.grey),
                        //       ),
                        //       Text(
                        //         item["quantity"].toString(),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       IconButton(
                        //         onPressed: () {},
                        //         icon: Icon(Icons.add, color: Colors.green),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.movie_edit, color: Colors.green),
                        ),
                        // Text(
                        //   '\$${item["price"].toStringAsFixed(2)}',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
