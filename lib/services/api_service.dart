import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../utils/console_util.dart';
import '../utils/custom_exceptions.dart';

class ApiService {
  static const _timeOut = 20;
  final String _baseUrl = "https://app.wellkins.com.au/api/";
  //"http://38.107.67.145:8100/api/";
  //"https://localhost:7038/api/";

  // get
  Future<dynamic> getDataFromApi({
    required String api,
    String url = '',
    dynamic headers,
    bool decode = true,
    bool showRes = true,
    int timeOut = _timeOut,
  }) async {
    final rng = Random();
    final ver = 'v=${rng.nextInt(100)}';
    final Uri uri;

    if (url.isEmpty) {
      uri = Uri.parse('$_baseUrl$api$ver');
    } else {
      uri = Uri.parse('$url$ver');
    }

    try {
      final duration = Duration(seconds: timeOut);
      final response = await http.get(uri, headers: headers).timeout(duration);
      return _response(response, showRes, decode: decode);
      // if (url.isEmpty) {
      //   return _response(response, showRes, decode: decode);
      // } else {
      //   final request = http.Request('GET', uri);
      //   final response = await http.Client().send(request);
      //   return response;
      // }
    } on SocketException {
      throw FetchDataException('No Internet Connection', '$uri');
    } on TimeoutException {
      throw ApiNotRespondingException('API Not Responding', '$uri');
    }
  }

  // post
  Future<dynamic> postDataToApi({
    required String api,
    dynamic headers,
    dynamic payload,
    String filePath = '',
    String fileName = '',
    String fileKey = '',
    bool multipart = false,
    bool isPut = false,
    bool isDelete = false,
    bool showRes = true,
  }) async {
    final rng = Random();
    final ver = 'v=${rng.nextInt(100)}';

    final Uri uri = Uri.parse('$_baseUrl$api$ver');

    try {
      if (multipart) {
        final method = isPut ? 'PUT' : 'POST';
        final request = http.MultipartRequest(method, uri)
          ..fields.addAll(payload)
          ..headers.addAll(headers);

        if (filePath.isNotEmpty && fileName.isNotEmpty) {
          final image = await http.MultipartFile.fromPath(
            fileKey,
            filePath,
            filename: fileName,
          );
          request.files.add(image);
        }

        final response = await http.Response.fromStream(await request.send());
        return _response(response, showRes);
      } else {
        const duration = Duration(seconds: _timeOut);

        final method = isDelete
            ? http.delete
            : isPut
            ? http.put
            : http.post;

        final res = method(uri, headers: headers, body: payload);
        final response = await res.timeout(duration);

        return _response(response, showRes);
      }
    } on SocketException {
      throw FetchDataException('No Internet Connection', '$uri');
    } on TimeoutException {
      throw ApiNotRespondingException('API Not Responding', '$uri');
    }
  }

  dynamic _response(
    http.Response response,
    bool showRes, {
    bool decode = true,
  }) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return _processResponse(response, false, showRes, decode: decode);
      case 400:
      case 401:
      case 403:
      case 500:
      default:
        return _processResponse(response, true, showRes, decode: decode);
    }
  }

  dynamic _processResponse(
    http.Response response,
    bool isError,
    bool showRes, {
    bool decode = true,
  }) {
    final sts = isError ? '\x1B[31m' : '\x1B[32m';
    const uClr = '\x1B[33m';
    const dClr = '\x1B[35m';
    const stp = '\x1B[0m';

    final rStCode = response.statusCode; //request status code
    final rUrl = response.request?.url;

    Platform.isAndroid
        ? printData(
            title: '${sts}status $rStCode$stp$uClr url : $rUrl$stp\n',
            data: showRes ? '$dClr ${response.body} $stp' : '',
          )
        : printData(
            title: 'status $rStCode url : $rUrl\n',
            data: showRes ? response.body : '',
          );

    final body = response.body;
    final data = decode ? json.decode(body) : response;
    return data;
  }
}
