import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projek_akhir/task_provider.dart';

class AddNewTask extends StatelessWidget {
  final String? taskId;
  final Map<String, dynamic>? taskData;

  const AddNewTask({super.key, this.taskId, this.taskData});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final titleController = TextEditingController(
      text: taskData?['title'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: taskData?['description'] ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(taskId == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final task = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'creator': FirebaseAuth.instance.currentUser?.uid,
                  'date': DateTime.now().toIso8601String(),
                };
                if (taskId == null) {
                  await taskProvider.addTask(task);
                } else {
                  await taskProvider.updateTask(taskId!, task);
                }
                Navigator.of(context).pop();
              },
              child: Text(taskId == null ? 'Add Task' : 'Update Task'),
            ),
            const SizedBox(height: 20),
            if (taskId != null)
              ElevatedButton(
                onPressed: () async {
                  // Konfirmasi penghapusan task
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                            'Are you sure you want to delete this task?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    await taskProvider.deleteTask(taskId!);
                    Navigator.of(context)
                        .pop(); // Kembali ke halaman sebelumnya setelah penghapusan
                  }
                },
                child: const Text('Delete Task'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors
                      .red, // Menandakan tombol untuk menghapus dengan warna merah
                ),
              ),
          ],
        ),
      ),
    );
  }
}
