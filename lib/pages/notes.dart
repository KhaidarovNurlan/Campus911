import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/colors.dart';
import '../theme/custom_button.dart';
import '../theme/custom_text_field.dart';
import '../data/models.dart';
import '../data/providers.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user?.id;
      if (userId != null) {
        context.read<NotesProvider>().loadNotes(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final notes = notesProvider.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: notes.isEmpty
          ? _EmptyNotes()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return _NoteCard(note: notes[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, [NoteModel? note]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteEditorSheet(note: note),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = context.read<UserProvider>().user?.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                DateFormat('d MMM, HH:mm').format(note.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.7)),
              ),
              if (note.content != null) ...[
                const SizedBox(height: 8),
                Text(
                  note.content!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ]
            ],
          ),
          onTap: () => _editNote(context, note),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () {
              if (userId != null) {
                context.read<NotesProvider>().deleteNote(userId, note.id);
              }
            },
          ),
        ),
      ),
    );
  }

  void _editNote(BuildContext context, NoteModel note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteEditorSheet(note: note),
    );
  }
}

class _NoteEditorSheet extends StatefulWidget {
  final NoteModel? note;
  const _NoteEditorSheet({this.note});

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userId = context.read<UserProvider>().user?.id;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              widget.note == null ? 'New Note' : 'Edit Note',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Title',
              hint: '...',
              controller: _titleController,
              validator: (v) => v!.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Content',
              hint: '...',
              controller: _contentController,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: widget.note == null ? 'Create' : 'Save Changes',
              onPressed: () {
                if (_formKey.currentState!.validate() && userId != null) {
                  final String noteId = widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

                  final newNote = NoteModel(
                    id: noteId,
                    title: _titleController.text,
                    content: _contentController.text.isEmpty ? null : _contentController.text,
                    createdAt: widget.note?.createdAt ?? DateTime.now(),
                  );

                  if (widget.note == null) {
                    context.read<NotesProvider>().addNote(userId, newNote);
                  } else {
                    context.read<NotesProvider>().updateNote(userId, newNote);
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: AppColors.textGrey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No notes yet', style: TextStyle(color: AppColors.textGrey, fontSize: 18)),
        ],
      ),
    );
  }
}