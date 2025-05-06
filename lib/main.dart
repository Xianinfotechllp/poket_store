import 'package:flutter/material.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/cart_controller/fetch_cart_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/fetch_product.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/notification_provider.dart';
import 'package:poketstore/controllers/login_reg_controller/registration_controller.dart';
import 'package:poketstore/controllers/order_controller/order_controller.dart';
import 'package:poketstore/controllers/product_by_shop_controller/product_by_shop_controller.dart';
import 'package:poketstore/controllers/search_producer_controller.dart';
import 'package:poketstore/controllers/set_location_controller.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:poketstore/service/permission_service/permission_service.dart';
import 'package:poketstore/view/splash/splash_screen.dart';
import 'package:provider/provider.dart';

import 'controllers/shop_of_user_controller/shop_of_user_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService.requestPermissions();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),
        ChangeNotifierProvider(create: (_) => SearchProducerProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => FetchProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ShopOfUserProvider()),
        ChangeNotifierProvider(create: (_) => MyShopListUserProvider()),
        ChangeNotifierProvider(create: (_) => ProductsByShopProvider()),
        ChangeNotifierProvider(create: (_) => ShopeDetailsProvider()),
        ChangeNotifierProvider(create: (_) => FetchCartProvider()),
        ChangeNotifierProvider(create: (_) => HomeProductController()),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => UserProfileController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
