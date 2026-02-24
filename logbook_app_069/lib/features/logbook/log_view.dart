import 'package:flutter/material.dart';
import 'package:logbook_app_069/features/logbook/log_controller.dart';
import 'package:logbook_app_069/features/logbook/models/log_model.dart';
import 'package:logbook_app_069/features/onboarding/onboarding_view.dart';

// Warna tema utama (Gold/Amber) agar matching dengan onboarding
const kPrimary = Color(0xFFF59E0B);
const kPrimaryDark = Color(0xFFD97706);
const kPrimaryLight = Color(0xFFFFFBEB);
const kTextDark = Color(0xFF1F2937);
const kTextGrey = Color(0xFF6B7280);

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              );
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Konfirmasi Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah Anda yakin ingin keluar? Sesi Anda akan diakhiri."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: kTextGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingView()),
                    (route) => false,
                  );
                }
              },
              child: const Text("Ya, Keluar"),
            ),
          ],
        );
      },
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _contentController),
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
              );
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 18, color: kPrimaryDark),
            ),
            const SizedBox(width: 8),
            const Text("Logbook", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
              ),
              onPressed: _showLogoutConfirm,
            ),
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: _LogListSection(),
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

class _LogListSection extends StatelessWidget {
  const _LogListSection();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_CounterViewState>()!;

    return ValueListenableBuilder<List<LogModel>>(
      valueListenable: state._controller.logsNotifier,
      builder: (context, currentLogs, child) {
        if (currentLogs.isEmpty) {
          return const Center(child: Text("Belum ada catatan."));
        }
        return ListView.builder(
          itemCount: currentLogs.length,
          itemBuilder: (context, index) {
            final log = currentLogs[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.note),
                title: Text(log.title),
                subtitle: Text(log.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => state._showEditLogDialog(index, log),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => state._controller.removeLog(index),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
