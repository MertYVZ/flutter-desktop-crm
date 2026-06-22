import 'package:Ok/feature/notes/models/note_customer_filter.dart';
import 'package:Ok/feature/notes/models/note_list_item.dart';
import 'package:Ok/product/database/app_database.dart';
import 'package:Ok/product/database/database_service.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

final class NotesService {
  NotesService(this._databaseService);

  final DatabaseService _databaseService;
  static const _uuid = Uuid();

  Future<List<NoteListItem>> getNotes() => _databaseService.notes.getNotes();

  Future<List<NoteListItem>> searchNotes({
    String? searchQuery,
    NoteCustomerFilter? customerFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _databaseService.notes.searchNotes(
      searchQuery: searchQuery,
      customerFilter: customerFilter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<NoteListItem?> getNoteById(String id) =>
      _databaseService.notes.getNoteListItemById(id);

  Future<List<Customer>> getSelectableCustomers() =>
      _databaseService.customers.getSelectableCustomers();

  Future<String> createNote({
    required String title,
    required String content,
    String? customerId,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _databaseService.notes.insertNote(
      NotesCompanion.insert(
        id: id,
        customerId: Value(_nullableCustomerId(customerId)),
        title: title.trim(),
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
    String? customerId,
  }) async {
    final existing = await _databaseService.notes.getNoteById(id);
    if (existing == null) {
      throw StateError('Note not found');
    }

    final updated = existing.copyWith(
      customerId: Value(_nullableCustomerId(customerId)),
      title: title.trim(),
      content: content.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await _databaseService.notes.updateNote(updated);
    if (!success) {
      throw StateError('Note update failed');
    }
  }

  Future<void> deleteNote(String id) async {
    final affectedRows = await _databaseService.notes.softDeleteNote(id);
    if (affectedRows == 0) {
      throw StateError('Note not found');
    }
  }

  String? _nullableCustomerId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }
}
