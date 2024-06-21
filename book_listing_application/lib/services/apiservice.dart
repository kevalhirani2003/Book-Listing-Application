import 'package:book_listing_application/datamodel/bookmodel.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Result> fetchBook(int p) async {
    try {
      final response = await _dio.get('https://gutendex.com/books/?page=$p');
      return Result.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load book');
    }
  }
}
