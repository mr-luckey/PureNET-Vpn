import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/vpn.dart';

class Pref {
  static late Box _box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('data');
  }


  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  static set isDarkMode(bool v) => _box.put('isDarkMode', v);


  static Vpn get vpn {
    final raw = _box.get('vpn');
    return Vpn.fromJson(jsonDecode((raw ?? '{}')));
  }

  static set vpn(Vpn v) => _box.put('vpn', jsonEncode(v.toJson()));

  static bool get autoConnectEnabled => _box.get('autoConnectEnabled') ?? false;
  static set autoConnectEnabled(bool v) => _box.put('autoConnectEnabled', v);


  static List<Vpn> get vpnList {
    List<Vpn> temp = [];
    final data = jsonDecode(_box.get('vpnList') ?? '[]');

    for (var i in data) temp.add(Vpn.fromJson(i));

    return temp;
  }

  static set vpnList(List<Vpn> v) => _box.put('vpnList', jsonEncode(v));
}
