// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rc168/main.dart';
import 'package:rc168/pages/member/address/address_add_page.dart';
import 'package:rc168/pages/shop/shop_cart_page.dart';
import 'package:rc168/responsive_text.dart';

class AddressCartAddPage extends StatefulWidget {
  @override
  _AddressCartAddPageState createState() => _AddressCartAddPageState();
}

class _AddressCartAddPageState extends State<AddressCartAddPage> {
  Future<List<CustomerAddress>>? addresses;

  @override
  void initState() {
    super.initState();
    addresses = fetchAddresses();
  }

  void _openAddAddressCartAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddressAddPage()),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText(
          title,
          baseFontSize: 38,
        ),
        content: ResponsiveText(
          message,
          baseFontSize: 36,
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('確定'),
          ),
        ],
      ),
    );
  }

  Future<List<CustomerAddress>> fetchAddresses() async {
    final response = await dio.get(
        '${appUri}/gws_appcustomer_address&customer_id=${customerId}&api_key=${apiKey}');

    if (response.statusCode == 200) {
      var responseData = response.data;
      List<CustomerAddress> addresses =
          (responseData['customer_address'] as List)
              .map((addressJson) => CustomerAddress.fromJson(addressJson))
              .toList();

      // 异步填充额外的详细信息
      for (var address in addresses) {
        await address.fillAdditionalDetails();
      }

      return addresses;
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  Future<String> fetchZoneName(String zoneId) async {
    final response = await dio.get('${appUrl}/zones/$zoneId');
    if (response.statusCode == 200) {
      // 解析響應，獲取zone名稱
      return response.data['name'];
    } else {
      throw Exception('Failed to load zone name');
    }
  }

  Future<String> fetchCountryName(String countryId) async {
    final response = await dio
        .get('${appUri}/gws_country&country_id=${countryId}&api_key=${apiKey}');
    if (response.statusCode == 200) {
      // 解析響應，獲取country名稱
      return response.data['country'][0]['name'];
    } else {
      throw Exception('Failed to load country name');
    }
  }

  Future<bool> deleteAddress(String customerId, String addressId) async {
    final response = await dio.get(
        '${appUri}/gws_appcustomer_address/remove&customer_id=${customerId}&address_id=${addressId}&api_key=${apiKey}');

    if (response.statusCode == 200) {
      var res = response.data;

      // 检查响应是否包含 message 键
      if (res.containsKey('message')) {
        var message = res['message'];

        // 判断 message 是否是一个数组，且第一个元素的 msg_status 是否为 true
        if (message is List &&
            message.isNotEmpty &&
            message[0]['msg_status'] == true) {
          return true; // 删除成功
        } else if (message.containsKey('error')) {
          return false; // 删除失败
        }
      }
    } else {
      throw Exception('Failed to load country name');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('地址'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF4F4E4C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ShopCartPage())),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<CustomerAddress>>(
          future: addresses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var address = snapshot.data![index];
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          '${address.firstname} ${address.lastname}',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          '${address.address1} \n${address.address2} \n${address.city}, ${address.zoneName}, ${address.countryName}, ${address.postcode}',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Row should be as big as the sum of its children.
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ShopCartPage(
                                        addressId: address.addressId)));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                var deleteAddressRes = await deleteAddress(
                                    '${address.customerId}',
                                    '${address.addressId}');

                                if (!deleteAddressRes) {
                                  _showDialog('刪除', '地址目前沒有此 ID。');
                                } else {
                                  // 从列表中移除该地址
                                  setState(() {
                                    snapshot.data!.removeAt(index);
                                  });
                                  _showDialog('刪除', '地址已經刪除。');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(), // 添加横线
                    ],
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      bottomSheet: Container(
        color: Colors.white, // 設置背景顏色為白色
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: ElevatedButton(
            onPressed: () {
              _openAddAddressCartAddPage();
            },
            child: ResponsiveText(
              '增加新的地址',
              baseFontSize: 36,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 按鈕背景顏色
              foregroundColor: const Color(0xFF4F4E4C),
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerAddress {
  String addressId;
  String customerId;
  String firstname;
  String lastname;
  String company;
  String address1;
  String address2;
  String city;
  String postcode;
  String countryId;
  String zoneId;
  String customField;
  String zoneName;
  String countryName;
  String cellphone;
  String pickupstore;

  CustomerAddress({
    required this.addressId,
    required this.customerId,
    required this.firstname,
    required this.lastname,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.postcode,
    required this.countryId,
    required this.zoneId,
    required this.customField,
    required this.zoneName,
    required this.countryName,
    required this.cellphone,
    required this.pickupstore,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      addressId: json['address_id'],
      customerId: json['customer_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      company: json['company'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      postcode: json['postcode'],
      countryId: json['country_id'],
      zoneId: json['zone_id'],
      customField: json['custom_field'],
      countryName: '',
      zoneName: '',
      cellphone: json['cellphone'],
      pickupstore: json['pickupstore'],
    );
  }

  Future<void> fillAdditionalDetails() async {
    // 从 API 获取 zone 和 country 名称
    this.zoneName = await fetchZoneName(this.countryId, this.zoneId);
    this.countryName = await fetchCountryName(this.countryId);
  }
}

Future<String> fetchZoneName(String countryId, String zoneId) async {
  final dio = Dio(); // 创建 Dio 实例
  try {
    final response = await dio.get(
        '${appUri}/gws_zone&country_id=${countryId}&api_key=${apiKey}'); // 使用 Dio 发送 GET 请求
    if (response.statusCode == 200) {
      List zones = response.data['zones'];

      var matchingZone = zones.firstWhere(
        (z) => z['zone_id'] == zoneId && z['country_id'] == countryId,
        orElse: () => null,
      );
      if (matchingZone != null) {
        // 返回匹配的区域名称
        return matchingZone['name'];
      } else {
        throw Exception('Matching zone not found');
      }
    } else {
      throw Exception('Failed to load zone name');
    }
  } catch (e) {
    // 处理异常
    throw Exception('Failed to fetch zone name: $e');
  }
}

Future<String> fetchCountryName(String countryId) async {
  final dio = Dio(); // 创建 Dio 实例
  try {
    final response = await dio.get(
        '${appUri}/gws_country&country_id=${countryId}&api_key=${apiKey}'); // 使用 Dio 发送 GET 请求
    if (response.statusCode == 200) {
      // 解析响应并返回国家名称
      return response.data['country'][0]['name'];
    } else {
      throw Exception('Failed to load country name');
    }
  } catch (e) {
    // 处理异常
    throw Exception('Failed to fetch country name: $e');
  }
}
