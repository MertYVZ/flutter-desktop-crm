import 'package:drift/drift.dart';

import 'package:Ok/feature/notes/models/note_customer_filter.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/tables/customers_table.dart';
import 'package:Ok/product/database/tables/notes_table.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes, Customers])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  Future<List<NoteListItem>> getNotes() => searchNotes();

  Future<List<NoteListItem>> searchNotes({
    String? searchQuery,
    NoteCustomerFilter? customerFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(notes).join([
      leftOuterJoin(
        customers,
        customers.id.equalsExp(notes.customerId),
      ),
    ]);

    query.where(notes.deletedAt.isNull());

    final trimmedSearch = searchQuery?.trim();
    if (trimmedSearch != null && trimmedSearch.isNotEmpty) {
      final pattern = '%${trimmedSearch.toLowerCase()}%';
      query.where(
        notes.title.lower().like(pattern) |
            notes.content.lower().like(pattern) |
            customers.name.lower().like(pattern),
      );
    }

    if (customerFilter == NoteCustomerFilter.general) {
      query.where(notes.customerId.isNull());
    } else if (customerFilter == NoteCustomerFilter.linkedToCustomer) {
      query.where(notes.customerId.isNotNull());
    }

    if (startDate != null) {
      query.where(
        notes.createdAt.isBiggerOrEqualValue(_startOfDay(startDate)),
      );
    }

    if (endDate != null) {
      query.where(
        notes.createdAt.isSmallerOrEqualValue(_endOfDay(endDate)),
      );
    }

    query.orderBy([OrderingTerm.desc(notes.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<List<NoteListItem>> getNotesByCustomerId(String customerId) async {
    final query = select(notes).join([
      leftOuterJoin(
        customers,
        customers.id.equalsExp(notes.customerId),
      ),
    ])
      ..where(
        notes.deletedAt.isNull() & notes.customerId.equals(customerId),
      )
      ..orderBy([OrderingTerm.desc(notes.createdAt)]);

    final rows = await query.get();
    return rows.map(_mapRowToListItem).toList();
  }

  Future<Note?> getNoteById(String id) => (select(notes)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<NoteListItem?> getNoteListItemById(String id) async {
    final query = select(notes).join([
      leftOuterJoin(
        customers,
        customers.id.equalsExp(notes.customerId),
      ),
    ])
      ..where(notes.id.equals(id) & notes.deletedAt.isNull());

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    return _mapRowToListItem(row);
  }

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);

  Future<bool> updateNote(Note note) => update(notes).replace(note);

  Future<int> softDeleteNote(String id) => (update(notes)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .write(NotesCompanion(deletedAt: Value(DateTime.now())));

  NoteListItem _mapRowToListItem(TypedResult row) {
    final note = row.readTable(notes);
    final customer = row.readTableOrNull(customers);

    return NoteListItem(
      id: note.id,
      customerId: note.customerId,
      customerName: customer?.name,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
