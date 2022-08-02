import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:photo_to_painting/features/desktop/desktop_page.dart';
import 'package:photo_to_painting/features/premium/premium_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const date = 'DATE';
const _productIds = {'weekly'};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<dynamic> _subscription;
  List<ProductDetails> _products = [];
  InAppPurchase inAppPurchase = InAppPurchase.instance;
  bool isPremium = false;

  @override
  void initState() {
    final prefs = SharedPreferences.getInstance();
    prefs.then(
      (value) {
        final res = value.getString(date);
        if (res != null) {
          final a = DateTime.now().compareTo(DateTime.parse(res));
          isPremium = a < 0;
        }
      },
    );
    final Stream purchaseUpdated = inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {});
    super.initState();
    initStoreInfo();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: const Text('Error purchasing subscription'),
              action: SnackBarAction(
                label: 'Close',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            isPremium = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            date,
            (DateTime.now().add(
              const Duration(days: 7),
            )).toIso8601String(),
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  initStoreInfo() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {}
    ProductDetailsResponse productDetailResponse = await inAppPurchase.queryProductDetails(
      _productIds,
    );
    if (productDetailResponse.error == null) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 17, top: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 32,
                    width: 141,
                  ),
                  Visibility(
                    visible: !isPremium,
                    child: CupertinoButton(
                      child: Image.asset(
                        'assets/get_prem.png',
                        height: 15,
                        width: 84,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PremiumScreen(
                              productDetails: (_products.isEmpty) ? null : _products[0],
                              onPurchase: _products.isEmpty
                                  ? () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setString(
                                        date,
                                        (DateTime.now().add(
                                          const Duration(days: 7),
                                        )).toIso8601String(),
                                      );
                                      setState(() {
                                        isPremium = true;
                                      });
                                      Navigator.pop(context);
                                    }
                                  : () async {
                                      final res = await inAppPurchase.buyNonConsumable(
                                        purchaseParam: PurchaseParam(
                                          productDetails: _products[0],
                                        ),
                                      );
                                      if (res) {
                                        Navigator.pop(context);
                                      }
                                    },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 37,
              ),
              const Text(
                'Photo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      'assets/camera.png',
                      height: 100,
                      width: 100,
                    ),
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (file != null) {
                        final shared = await SharedPreferences.getInstance();
                        final res = shared.getString(date);
                        if (res != null) {
                          final a = DateTime.now().compareTo(DateTime.parse(res));
                          if (a < 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DesktopPage(
                                  isPro: true,
                                  image: File(file.path),
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DesktopPage(
                                  isPro: false,
                                  image: File(file.path),
                                ),
                              ),
                            );
                          }
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DesktopPage(
                                isPro: false,
                                image: File(file.path),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    width: 13,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      'assets/lib.png',
                      width: 100,
                      height: 100,
                    ),
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file != null) {
                        final shared = await SharedPreferences.getInstance();
                        final res = shared.getString(date);
                        if (res != null) {
                          final a = DateTime.now().compareTo(DateTime.parse(res));
                          if (a < 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DesktopPage(
                                  isPro: true,
                                  image: File(file.path),
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DesktopPage(
                                  isPro: false,
                                  image: File(file.path),
                                ),
                              ),
                            );
                          }
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DesktopPage(
                                isPro: false,
                                image: File(file.path),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
