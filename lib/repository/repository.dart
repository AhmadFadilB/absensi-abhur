import 'package:absensi/secret.dart';
import 'package:http/http.dart';

class Repository {
  static const url = "https://absenustad.herokuapp.com";

  static Future<Response> postUser(String name, int sesi) async {
    try {
      final res = await post(Uri.parse("$url/api/newAbsen?apiKey=$APIKEY"),
          body: {"peserta": name, "sesi": sesi.toString()});

      return res;
    } catch (e) {
      rethrow;
    }
  }
}
