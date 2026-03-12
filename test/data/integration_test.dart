import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:campus911/data/providers.dart';
import 'package:campus911/data/services.dart';
import 'package:campus911/data/models.dart';

class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  setUpAll(() {
    registerFallbackValue(NoteModel(
      id: 'fake',
      title: 'fake',
      content: 'fake',
      createdAt: DateTime.now()
    ));
  });

  late UserProvider userProvider;
  late MockFirebaseService mockFirebase;

  setUp(() {
    mockFirebase = MockFirebaseService();
    userProvider = UserProvider(firebase: mockFirebase);
  });

  group('Providers & Services Integration', () {

    test('Successful registration updates user data and loading state', () async {
      when(() => mockFirebase.isHeadmanTaken(any(), any()))
          .thenAnswer((_) async => false);
      when(() => mockFirebase.registerUser(
        email: 'test@mail.com',
        password: 'Password123!',
        name: 'Surname Name',
        college: 'AITU',
        group: 'ПО2303',
        role: 'student',
      )).thenAnswer((_) async => {});

      when(() => mockFirebase.fetchCurrentUser()).thenAnswer((_) async => UserModel(
        id: 'uid_123',
        name: 'Surname Name',
        email: 'test@mail.com',
        college: 'AITU',
        groupName: 'ПО2303',
        role: 'student',
      ));
      when(() => mockFirebase.currentUid).thenReturn('uid_123');

      final future = userProvider.register(
        email: 'test@mail.com',
        password: 'Password123!',
        name: 'Surname Name',
        college: 'AITU',
        group: 'ПО2303',
        role: 'student',
      );

      expect(userProvider.isLoading, true);

      await future;

      expect(userProvider.isLoading, false);
      expect(userProvider.user?.name, 'Surname Name');
      verify(() => mockFirebase.registerUser(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
        college: any(named: 'college'),
        group: any(named: 'group'),
        role: any(named: 'role'),
      )).called(1);
    });

    test('Registration fails if headman is already taken', () async {
      when(() => mockFirebase.isHeadmanTaken('AITU', 'ПО2303'))
          .thenAnswer((_) async => true);

      when(() => mockFirebase.registerUser(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
        college: 'AITU',
        group: 'ПО2303',
        role: 'headman',
      )).thenThrow(Exception('Role "Headman" is already taken'));

      expect(
        () => userProvider.register(
          email: 'test@mail.com',
          password: 'Password123!',
          name: 'Group Headman',
          college: 'AITU',
          group: 'ПО2303',
          role: 'headman',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('NotesProvider integration: loading and adding notes', () async {
      final mockNotesFirebase = MockFirebaseService();
      final notesProvider = NotesProvider(firebase: mockNotesFirebase);
      const userId = 'user_123';

      final existingNote = NoteModel(
        id: 'note_1',
        title: 'Existing Note',
        content: 'Content',
        createdAt: DateTime.now(),
      );

      when(() => mockNotesFirebase.getNotes(userId))
          .thenAnswer((_) async => [existingNote]);

      await notesProvider.loadNotes(userId);

      expect(notesProvider.notes.length, 1);
      expect(notesProvider.notes.first.title, 'Existing Note');

      final newNote = NoteModel(
        id: 'note_2',
        title: 'New Integration Note',
        content: 'Clean Code',
        createdAt: DateTime.now(),
      );

      when(() => mockNotesFirebase.addNote(userId, any()))
          .thenAnswer((_) async => {});

      await notesProvider.addNote(userId, newNote);

      expect(notesProvider.notes.length, 2);
      expect(notesProvider.notes.first.title, 'New Integration Note');

      verify(() => mockNotesFirebase.addNote(userId, any())).called(1);
    });
  });
}