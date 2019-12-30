import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class _Bridge {
  static const MethodChannel _channel = const MethodChannel('leancloud_plugin');

  static Future<Map> invokeMethod(String method, Map arguments) async {
    Map result = await _channel.invokeMethod(method, arguments);
    return result;
  }
}

class RTMException implements Exception {
  RTMException({
    @required this.code,
    this.message,
    this.details,
  }) : assert(code != null);

  final String code;
  final String message;
  final dynamic details;

  @override
  String toString() => 'LeanCloud.RTMException($code, $message, $details)';
}

class Client {
  Client({@required this.id, this.tag}) : assert(id != null);

  final String id;
  final String tag;

  RTMException _encounteredError(Map result) {
    final Map error = result['error'];
    return RTMException(
        code: error['code'],
        message: error['message'],
        details: error['details']);
  }

  Future<void> initialize() async {
    var args = {'clientId': this.id};
    if (this.tag != null) {
      args['tag'] = this.tag;
    }
    final Map result =
        await _Bridge.invokeMethod('initClient', args);
    if (result['error'] != null) {
      throw _encounteredError(result);
    } else {
      return;
    }
  }

  Future<void> deinitialize() async {
    var args = {'clientId': this.id};
    final Map result =
        await _Bridge.invokeMethod('deinitClient', args);
    if (result['error'] != null) {
      throw _encounteredError(result);
    } else {
      return;
    }
  }

  Future<void> open({bool force = true}) async {
    var args = {'clientId': this.id, 'force': force};
    final Map result =
        await _Bridge.invokeMethod('openClient', args);
    if (result['error'] != null) {
      throw _encounteredError(result);
    } else {
      return;
    }
  }

  Future<void> close() async {
    var args = {'clientId': this.id};
    final Map result =
        await _Bridge.invokeMethod('closeClient', args);
    if (result['error'] != null) {
      throw _encounteredError(result);
    } else {
      return;
    }
  }
}
