import 'package:flutter/material.dart';
import 'log_controller.dart';
import '../onboarding/onboarding_view.dart';
import './models/log_model.dart';
import 'package:intl/intl.dart';

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
                // TASK 3: Loading State atau Empty State
                if (currentLogs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // Atau gambar contentsnotfound.png
                }

                // HOMEWORK: Pull-to-Refresh
                return RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await _controller.loadFromDisk();
                    } catch (e) {
                      // HOMEWORK: Connection Guard (Offline Warning)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Koneksi terputus! Anda sedang offline.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: ListView.builder(
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];

                      // HOMEWORK: Timestamp Formatting (Contoh: 25 Jan 2026)
                      DateTime parsedDate = DateTime.parse(log.date);
                      String formattedDate = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(parsedDate);

                      return Card(
                        color: _getCategoryColor(log.category),
                        child: ListTile(
                          leading: const Icon(
                            Icons.cloud_done,
                            color: Colors.green,
                          ),
                          title: Text(log.title),
                          // Menampilkan deskripsi dan waktu yang sudah diformat
                          subtitle: Text("${log.description}\n$formattedDate"),
                          isThreeLine: true,
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showEditLogDialog(index, log),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _controller.removeLog(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
