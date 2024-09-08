import 'package:clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final sl = GetIt.instance;

Future<void> initialzeDependecies() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  //dio
  sl.registerSingleton<Dio>(Dio());

  //Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  //repositoryimpl
  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  //UseCase
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  //blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  //Get Saved Article
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  //Save Article
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  //Remove Article
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
}
