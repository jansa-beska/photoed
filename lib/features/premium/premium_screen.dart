import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumScreen extends StatelessWidget {
  final ProductDetails? productDetails;
  final Future<void> Function()? onPurchase;
  const PremiumScreen({
    Key? key,
    required this.productDetails,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 54,
        width: MediaQuery.of(context).size.width - 20,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: const Color(0xFFF15132),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () async {
            if (onPurchase != null) await onPurchase!();
          },
          child: const Text(
            'Subscribe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  'assets/top.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: Image.asset(
                'assets/middle.png',
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Image.asset(
                'assets/first.png',
                height: 18,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Image.asset(
                'assets/second.png',
                height: 18,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '* ',
                      style: TextStyle(
                        color: Color(0xFFF15132),
                      ),
                    ),
                    TextSpan(
                      text: 'Price may vary by region, so click the button below for pricing.',
                      style: TextStyle(
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
