import 'package:clean_architecture/features/daily_news/data/models/article.dart';
import 'package:flutter/material.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../../core/constant/constant.dart';
import 'package:dio/dio.dart';
part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIBaseURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('/top-headlines')
  Future<HttpResponse<List<ArticleModel>>> getNewsArticles({
    @Query("apiKey") String? apiKey,
    @Query("country") String? country,
    @Query("category") String? category,
  });
}

class ParseErrorLogger {
  void logError(
      Object error, StackTrace stackTrace, RequestOptions requestOptions) {
    // Log error details for debugging
    debugPrint('Error: $error');
    debugPrint('Request URL: ${requestOptions.uri}');
    debugPrint('StackTrace: $stackTrace');
  }
}
