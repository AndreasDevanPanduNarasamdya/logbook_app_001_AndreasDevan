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
                onPressed: () async {
                  await _controller.updateLog(
                    index,
                    _titleController.text,
                    _contentController.text,
                    selectedCategory,
                  );
                  _titleController.clear();
                  _contentController.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Catatan?"),
        content: const Text(
          "Apakah kamu yakin ingin menghapus catatan ini? Data tidak bisa dikembalikan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _controller.removeLog(index); // Jalankan fungsi hapus
              if (context.mounted) {
                Navigator.pop(context); // Tutup popup
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
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
                onPressed: () async {
                  await _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    selectedCategory,
                  );
                  _titleController.clear();
                  _contentController.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isOffline,
            builder: (context, isOffline, child) {
              if (!isOffline)
                return const SizedBox.shrink(); // Hilang jika online

              return Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  "Mode Offline: Menunggu Koneksi Internet...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
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
                  // Cek apakah kosong karena database benar-benar kosong,
                  // ATAU karena hasil pencarian tidak menemukan kecocokan.
                  final isDatabaseEmpty =
                      _controller.logsNotifier.value.isEmpty;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          isDatabaseEmpty
                              ? 'lib/assets/contentsmissing.png'
                              : 'lib/assets/contentsnotfound.png',
                          width: isDatabaseEmpty ? 80 : 200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isDatabaseEmpty
                              ? "Belum ada catatan."
                              : "Catatan tidak ditemukan.",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    try {
                      // Nanti kita ganti ini untuk fetch dari MongoDB
                      await _controller.loadFromDisk();
                    } catch (e) {
                      // Print error aslinya ke terminal!
                      print("ERROR SAAT REFRESH: $e");

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            // Tampilkan pesan error aslinya di layar untuk sementara
                            content: Text("Error: $e"),
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

                      DateTime parsedDate = DateTime.parse(log.date);
                      String formattedDate = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(parsedDate);

                      return Card(
                        color: _getCategoryColor(log.category),
                        child: ListTile(
                          leading: Icon(
                            log.isSynced ? Icons.cloud_done : Icons.cloud_off,
                            color: log.isSynced ? Colors.green : Colors.grey,
                          ),
                          title: Text(log.title),
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
                                onPressed: () => _confirmDelete(index),
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
