import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// Local copy of the store's products (POS grid + barcode lookup while offline). Mirrors `LocalProduct` in offline-db.ts.
@DataClassName('LocalProduct')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get barcode => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get inStock => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Credit customers (registered, with an account) and the store's own unregistered ("pending") customers.
@DataClassName('LocalCustomer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  /// 'registered' | 'pending'
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get accountId => text().nullable()();
  RealColumn get balance => real().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Offline POS outbox. One row per operation; `payload` is the JSON envelope pos-outbox posts verbatim.
@DataClassName('OutboxOp')
class Outbox extends Table {
  TextColumn get id => text()();
  /// 'sale' | 'new_product'
  TextColumn get kind => text()();
  /// ISO-8601, used for FIFO ordering (same as the IndexedDB index).
  TextColumn get createdAt => text()();
  TextColumn get payload => text()();
  /// 'pending' | 'failed'
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get tries => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MetaRow')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

extension OutboxOpJson on OutboxOp {
  Map<String, dynamic> get payloadMap => jsonDecode(payload) as Map<String, dynamic>;
  bool get isFailed => status == 'failed';
}

@DriftDatabase(tables: [Products, Customers, Outbox, Meta])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// On-device database (sqlite file `wasl_pos`).
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'wasl_pos'));

  @override
  int get schemaVersion => 1;

  // ---------- products ----------
  Future<void> putProducts(List<LocalProduct> items) async {
    if (items.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(products, items));
  }

  Future<void> putProduct(LocalProduct item) => into(products).insertOnConflictUpdate(item);

  Future<List<LocalProduct>> productsByStore(String storeId) =>
      (select(products)..where((p) => p.storeId.equals(storeId))..orderBy([(p) => OrderingTerm.asc(p.name)])).get();

  /// Removes the store's rows whose id is neither in the fresh server list nor in [keepIds] (products created offline).
  Future<void> pruneProducts(String storeId, Set<String> keepIds) =>
      (delete(products)..where((p) => p.storeId.equals(storeId) & p.id.isNotIn(keepIds.toList()))).go();

  // ---------- customers ----------
  Future<void> putCustomers(List<LocalCustomer> items) async {
    if (items.isEmpty) return;
    await batch((b) => b.insertAllOnConflictUpdate(customers, items));
  }

  Future<List<LocalCustomer>> customersByStore(String storeId) =>
      (select(customers)..where((c) => c.storeId.equals(storeId))..orderBy([(c) => OrderingTerm.asc(c.name)])).get();

  // ---------- outbox ----------
  Future<void> outboxAdd(OutboxOp op) => into(outbox).insertOnConflictUpdate(op);

  /// All ops, oldest first.
  Future<List<OutboxOp>> outboxAll() => (select(outbox)..orderBy([(o) => OrderingTerm.asc(o.createdAt)])).get();

  Future<void> outboxDelete(String id) => (delete(outbox)..where((o) => o.id.equals(id))).go();

  Future<void> outboxUpdate(OutboxOp op) => update(outbox).replace(op);

  Future<int> outboxCount() async {
    final c = outbox.id.count();
    final row = await (selectOnly(outbox)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  // ---------- meta ----------
  Future<String?> metaGet(String key) async {
    final row = await (select(meta)..where((m) => m.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> metaSet(String key, String value) => into(meta).insertOnConflictUpdate(MetaRow(key: key, value: value));
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});
