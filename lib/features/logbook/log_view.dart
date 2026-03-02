import 'package:flutter/material.dart';
import 'log_controller.dart';
import '../onboarding/onboarding_view.dart';
import './models/log_model.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});
  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final contentSearch = TextEditingController();

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pekerjaan':
        return Colors.blue.shade100;
      case 'Urgent':
        return Colors.red.shade100;
      case 'Pribadi':
      default:
        return Colors.green.shade100;
    }
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    String selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Catatan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController),
                TextField(controller: _contentController),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Kategori"),
                  items: ['Pekerjaan', 'Pribadi', 'Urgent'].map((
                    String category,
                  ) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setStateDialog(() => selectedCategory = newValue);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.updateLog(
                    index,
                    _titleController.text,
                    _contentController.text,
                    selectedCategory,
                  );
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddLogDialog() {
    String selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Tambah Catatan Baru"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "Judul Catatan"),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: "Isi Deskripsi"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Kategori"),
                  items: ['Pekerjaan', 'Pribadi', 'Urgent'].map((
                    String category,
                  ) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setStateDialog(() => selectedCategory = newValue);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    selectedCategory,
                  );
                  _titleController.clear();
                  _contentController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: contentSearch,
              decoration: const InputDecoration(hintText: "Search for Notes"),
              onChanged: (value) => _controller.searchLog(value),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/contentsnotfound.png',
                          width: 200,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada catatan.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    return Card(
                      color: _getCategoryColor(log.category),
                      child: ListTile(
                        leading: const Icon(Icons.note),
                        title: Text(log.title),
                        subtitle: Text(log.description),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditLogDialog(index, log),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _controller.removeLog(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
