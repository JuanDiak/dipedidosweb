import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../Api.dart';

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String StripeKeySecret =API.GetStripeKeySecret();
  static String StripeKeyPublic =API.GetStripeKeyPublic();
  //static String StripeKeySecret = 'sk_test_6mu4UTQyDBFA8pLF8q9ZpBe900kRoacSDh'; //MIAS
  //static String StripeKeyPublic = 'pk_test_7s8dwDvWDxvTGK7eDXY7YKFw00xKYJ2Oi6'; //MIAS

  //static String secret = 'sk_test_UpH4J5i9bIS8io5VuqT5YZai00ur5Lfhhf'; //PEPE
  //static String secret = 'sk_test_hUdpBC1UfgW8284pU9Wa1W3B00Mq56Wd5U'; //FRAN
  //publishableKey:"pk_test_SBSleJJ73rJAqEtWPDDvaDkn00cf1H2M4h",  // FRAN
  //publishableKey:"pk_test_N40iZtscTHZKsUR8wvPwBOUn008i2ZwlY7",  // PEPE


  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.StripeKeySecret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init() {
    Stripe.publishableKey = StripeKeyPublic;
  }

  static Future<String> makePayment({String amount, String currency}) async {
    Map<String, dynamic> paymentIntent;
    var result='';
    try {
      paymentIntent = await createPaymentIntent(amount, currency);

      var gpay = PaymentSheetGooglePay(
          merchantCountryCode: "ES",
          currencyCode: "ES",
          testEnv: true);
      //STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['client_secret'],
              style: ThemeMode.light,
              merchantDisplayName: 'Merchant Name',
              googlePay: gpay));
      //STEP 3: Display Payment sheet
      //displayPaymentSheet();
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Payment Successfully");
        result='OK';
      });
    } catch (err) {
      print(err);
    }
    return result;
  }

  static displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Payment Successfully");
      });
    } catch (e) {
      print('$e');
    }
  }

  static createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
          Uri.parse(StripeService.paymentApiUrl),
          body: body,
          headers: StripeService.headers
     /*   Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51MWx8OAVMyklfe3C3gP4wKOhTsRdF6r1PYhhg1PqupXDITMrV3asj5Mmf0G5F9moPL6zNfG3juK8KHgV9XNzFPlq00wmjWwZYA',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,*/
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

}


