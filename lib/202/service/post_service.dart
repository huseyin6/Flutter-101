import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/202/service/comment_model.dart';
import 'package:flutter_application_1/202/service/post_model.dart';

abstract class IPostService {
  Future<bool> addItemToService(PostModelApi postModel);
  Future<List<PostModelApi>?> fetchPostItemsAdvance();
  Future<bool> putItemToService(PostModelApi postModel, int id);
  Future<bool> deleteItem(PostModelApi postModel, int id);
  Future<List<CommentModel>?> fetchRelatedCommentsWithPostId(int postId);
}

class PostService implements IPostService {
  final Dio _dio;

  PostService() : _dio = Dio(BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));

  @override
  Future<bool> addItemToService(PostModelApi postModel) async {
    try {
      final response = await _dio.post(_PostServicePaths.posts.name, data: postModel);
      return response.statusCode == HttpStatus.created;
    } on DioException catch (err) {
      _ShowDebug.showDioError(err, this);
    }

    return false;
  }

  @override
  Future<List<PostModelApi>?> fetchPostItemsAdvance() async {
    try {
      final response = await _dio.get(_PostServicePaths.posts.name);
      if (response.statusCode == HttpStatus.ok) {
        final datas = response.data;
        if (datas is List) {
          return datas.map((e) => PostModelApi.fromJson(e)).toList();
        }
      }
    } on DioException catch (err) {
      _ShowDebug.showDioError(err, this);
    }

    return null;
  }

  @override
  Future<bool> putItemToService(PostModelApi postModel, int id) async {
    try {
      final response = await _dio.put("${_PostServicePaths.posts.name}/$id", data: postModel);
      return response.statusCode == HttpStatus.ok;
    } on DioException catch (err) {
      _ShowDebug.showDioError(err, this);
    }

    return false;
  }

  @override
  Future<bool> deleteItem(PostModelApi postModel, int id) async {
    try {
      final response = await _dio.delete("${_PostServicePaths.posts.name}/$id");
      return response.statusCode == HttpStatus.ok;
    } on DioException catch (err) {
      _ShowDebug.showDioError(err, this);
    }

    return false;
  }

  @override
  Future<List<CommentModel>?> fetchRelatedCommentsWithPostId(int postId) async {
    try {
      final response =
          await _dio.get(_PostServicePaths.comments.name, queryParameters: {_PostQueryPaths.postId.name: postId});
      if (response.statusCode == HttpStatus.ok) {
        final datas = response.data;
        if (datas is List) {
          return datas.map((e) => CommentModel.fromJson(e)).toList();
        }
      }
    } on DioException catch (err) {
      _ShowDebug.showDioError(err, this);
    }

    return null;
  }
}

enum _PostServicePaths { posts, comments }

enum _PostQueryPaths { postId }

class _ShowDebug {
  static void showDioError<T>(DioException error, T type) {
    if (kDebugMode) {
      print(error.message);
      print(type);
      print("-------");
    }
  }
}
