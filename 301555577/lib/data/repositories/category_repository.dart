import 'dart:async';

import '../models/category_model.dart';
import 'db/db_provider.dart';
import 'mappers/category_mapper.dart';

class CategoryRepository {
  final DbProvider dbProvider;

  CategoryRepository(this.dbProvider);

  Future<List<Category>> fetchCategories() async {
    final dbCategories = await dbProvider.categories();
    return dbCategories.map(CategoryMapper.fromDb).toList();
  }

  Future<List<Category>> fetchDefaultCategories() async {
    final dbCategories = await dbProvider.categories(isDefault: true);
    return dbCategories.map(CategoryMapper.fromDb).toList();
  }

  Future<int> addCategory(Category category) async {
    return dbProvider.insertCategory(CategoryMapper.toDb(category));
  }

  Future<int> updateCategory(Category category) async {
    return dbProvider.updateCategory(CategoryMapper.toDb(category));
  }

  Future<int> deleteCategory(Category category) async {
    return dbProvider.deleteCategory(category.id!);
  }
}
