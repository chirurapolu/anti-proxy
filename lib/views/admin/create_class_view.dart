import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/class_model.dart';
import '../../services/class_service.dart';

class CreateClassView extends ConsumerStatefulWidget {
  const CreateClassView({super.key});

  @override
  ConsumerState<CreateClassView> createState() => _CreateClassViewState();
}

class _CreateClassViewState extends ConsumerState<CreateClassView> {
  void _showAddEditDialog([ClassModel? existingClass]) {
    final yearController = TextEditingController(text: existingClass?.year);
    final branchController = TextEditingController(text: existingClass?.branch);
    final sectionController = TextEditingController(text: existingClass?.section);
    final isEditing = existingClass != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Create Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: branchController,
                  decoration: const InputDecoration(labelText: 'Branch'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final classModel = ClassModel(
                  id: existingClass?.id ?? '',
                  year: yearController.text.trim(),
                  branch: branchController.text.trim(),
                  section: sectionController.text.trim(),
                );
                
                if (isEditing) {
                  await ref.read(classServiceProvider).updateClass(classModel);
                } else {
                  await ref.read(classServiceProvider).addClass(classModel);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Register'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final classService = ref.watch(classServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<ClassModel>>(
        stream: classService.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classes = snapshot.data ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('No classes found. Add one!'));
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return ListTile(
                title: Text('${classItem.year} - ${classItem.branch}'),
                subtitle: Text('Section: ${classItem.section}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditDialog(classItem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
