import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_frontend/models/category.dart';
import 'package:wallet_frontend/repositories/category_repository.dart';

// Fake CategoryDao behaviors by subclassing repository methods instead of hitting DB.
class _MemoryCategoryRepo extends CategoryRepository {
  final List<Category> _cats = [];
  int _id = 0;

  _MemoryCategoryRepo() : super(dao: null);

  @override
  Future<int> add(Category c) async {
    if (_cats.any((e) => e.name.toLowerCase() == c.name.toLowerCase())) {
      throw ArgumentError('duplicate name');
    }
    _id += 1;
    _cats.add(c.copyWith(id: _id));
    return _id;
  }

  @override
  Future<int> update(Category c) async {
    final idx = _cats.indexWhere((e) => e.id == c.id);
    if (idx < 0) return 0;
    _cats[idx] = c;
    return 1;
  }

  @override
  Future<int> remove(int id) async {
    _cats.removeWhere((e) => e.id == id);
    return 1;
  }

  @override
  Future<List<Category>> list() async => _cats;

  @override
  Future<Category?> getById(int id) async => _cats.firstWhere((e) => e.id == id);
}

void main() {
  test('CRUD flow', () async {
    final repo = _MemoryCategoryRepo();

    final id = await repo.add(Category(name: 'Test', colorValue: 0xFF000000, iconName: 'category'));
    expect(id, 1);

    var list = await repo.list();
    expect(list.length, 1);

    await repo.update(Category(id: id, name: 'Test2', colorValue: 0xFF000000, iconName: 'category'));
    list = await repo.list();
    expect(list.first.name, 'Test2');

    await repo.remove(id);
    list = await repo.list();
    expect(list.isEmpty, true);
  });

  test('Cannot add duplicate name', () async {
    final repo = _MemoryCategoryRepo();
    await repo.add(Category(name: 'Food', colorValue: 0xFF000000, iconName: 'category'));
    expect(
      () => repo.add(Category(name: 'Food', colorValue: 0xFF000000, iconName: 'category')),
      throwsArgumentError,
    );
  });
}
