import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_frontend/models/transaction.dart';
import 'package:wallet_frontend/repositories/transaction_repository.dart';

// A minimal fake DAO via repository injection is simpler by extending repository,
// but here we rely on repository behavior without actual DB by stubbing via an
// in-memory implementation (compose by wrapping TransactionRepository?).
// To keep simple without external mocking libs, we simulate using a fake repository class.

class _FakeTransactionRepo extends TransactionRepository {
  final List<WalletTransaction> _store = [];

  _FakeTransactionRepo() : super(dao: null);

  @override
  Future<int> add(WalletTransaction t) async {
    final id = _store.length + 1;
    _store.add(t.copyWith(id: id));
    return id;
  }

  @override
  Future<int> update(WalletTransaction t) async {
    final idx = _store.indexWhere((e) => e.id == t.id);
    if (idx < 0) return 0;
    _store[idx] = t;
    return 1;
  }

  @override
  Future<int> remove(int id) async {
    _store.removeWhere((e) => e.id == id);
    return 1;
  }

  @override
  Future<List<WalletTransaction>> listTransactions({
    int? categoryId,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    Iterable<WalletTransaction> res = _store;
    if (categoryId != null) res = res.where((e) => e.categoryId == categoryId);
    if (type != null) res = res.where((e) => e.type == type);
    if (from != null) res = res.where((e) => e.date.isAfter(from) || e.date.isAtSameMomentAs(from));
    if (to != null) res = res.where((e) => e.date.isBefore(to) || e.date.isAtSameMomentAs(to));
    final list = res.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<int> computeBalance() async {
    int inc = 0;
    int exp = 0;
    for (final t in _store) {
      if (t.type == TransactionType.income) inc += t.amountCents;
      if (t.type == TransactionType.expense) exp += t.amountCents;
    }
    return inc - exp;
  }
}

void main() {
  test('add and compute balance', () async {
    final repo = _FakeTransactionRepo();

    await repo.add(WalletTransaction(
      amountCents: 10000,
      type: TransactionType.income,
      categoryId: 1,
      date: DateTime.now(),
      note: 'Salary',
    ));

    await repo.add(WalletTransaction(
      amountCents: 2500,
      type: TransactionType.expense,
      categoryId: 2,
      date: DateTime.now(),
      note: 'Lunch',
    ));

    final balance = await repo.computeBalance();
    expect(balance, 7500);
  });
}
