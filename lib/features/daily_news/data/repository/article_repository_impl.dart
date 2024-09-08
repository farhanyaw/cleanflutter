import 'dart:io';

import 'package:clean_architecture/core/constant/constant.dart';
import 'package:clean_architecture/core/resources/data_state.dart';
import 'package:clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:clean_architecture/features/daily_news/data/models/article.dart';
import 'package:clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try {
      // Check internet connection
      final bool hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        return DataFailed(
          DioException(
            error: 'No Internet Connection',
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      }

      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        debugPrint(
            'Failed with status code: ${httpResponse.response.statusCode ?? 'Unknown'}');
        debugPrint(
            'Error message: ${httpResponse.response.statusMessage ?? 'Unknown'}');

        return DataFailed(DioException(
          error: httpResponse.response.statusMessage ?? 'Unknown error',
          response: httpResponse.response,
          type: DioExceptionType.badResponse,
          requestOptions: httpResponse.response.requestOptions,
        ));
      }
    } on DioException catch (e) {
      debugPrint('DioException caught: ${e.message ?? 'Unknown error'}');
      debugPrint('Error type: ${e.type}');
      debugPrint('Request URL: ${e.requestOptions.uri}');
      debugPrint('Stack trace: ${e.stackTrace}');
      return DataFailed(e);
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('SocketException caught: $e');
      return false;
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }
}
