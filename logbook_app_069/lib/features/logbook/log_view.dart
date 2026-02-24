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
// Border radius constants
const _kInputRadius = 12.0;
const _kCardRadius = 16.0;
const _kDialogRadius = 20.0;
const _kButtonRadius = 10.0;

// Category items untuk dropdown
const _categoryItems = [
  {'name': 'Pekerjaan', 'icon': Icons.work_rounded, 'color': Colors.blue},
  {'name': 'Pribadi', 'icon': Icons.person_rounded, 'color': Colors.green},
  {'name': 'Urgent', 'icon': Icons.priority_high_rounded, 'color': Colors.red},
];

// Helper: Border shortcut for InputDecoration
OutlineInputBorder _oBorder(Color c, double w) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(_kInputRadius),
  borderSide: BorderSide(color: c, width: w),
);

// Helper: Category lookup from _categoryItems
Map<String, dynamic> _catLookup(String name) =>
    _categoryItems.firstWhere((c) => c['name'] == name, orElse: () => _categoryItems[1]);

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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi ☀️";
    if (hour < 15) return "Selamat Siang 🌤️";
    if (hour < 18) return "Selamat Sore 🌅";
    return "Selamat Malam 🌙";
  }

  // Helper: Input decoration builder
  InputDecoration _buildInputDecoration(String label, IconData icon, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20, color: kTextGrey),
    labelStyle: TextStyle(color: kTextGrey),
    hintStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: _oBorder(Colors.grey[300]!, 1),
    focusedBorder: _oBorder(kPrimary, 2),
    errorBorder: _oBorder(Colors.red[300]!, 1),
    focusedErrorBorder: _oBorder(Colors.red[400]!, 2),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // Helper: Centered status popup (auto-dismiss)
  void _showStatusPopup(String message, {IconData icon = Icons.check_circle_rounded, Color? color}) {
    final c = color ?? Colors.green[600]!;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return Dialog(
          backgroundColor: kPrimaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kDialogRadius)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: c, size: 36),
                ),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper: Confirmation dialog (returns true if confirmed)
  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Ya',
    Color? confirmColor,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kPrimaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kDialogRadius)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kTextGrey,
              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
            ),
            child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  // Merged add/edit dialog
  void _showLogDialog({int? editIndex, LogModel? existingLog}) {
    final isEdit = editIndex != null && existingLog != null;
    if (isEdit) {
      _titleController.text = existingLog.title;
      _contentController.text = existingLog.description;
    } else {
      _titleController.clear();
      _contentController.clear();
    }
    String selectedCategory = isEdit ? existingLog.category : 'Pribadi';
    final accent = isEdit ? Colors.blue : kPrimary;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: kPrimaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kDialogRadius)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon bulat di atas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: accent.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(isEdit ? Icons.edit_rounded : Icons.add_rounded, color: accent, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  isEdit ? "Edit Catatan" : "Tambah Catatan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: _buildInputDecoration("Judul Catatan", Icons.title_rounded),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: _buildInputDecoration("Isi Deskripsi", Icons.notes_rounded),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Kategori", style: TextStyle(fontSize: 13, color: kTextGrey, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                // Category pills
                Row(
                  children: _categoryItems.map((cat) {
                    final isSelected = selectedCategory == cat['name'];
                    final catColor = cat['color'] as Color;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => selectedCategory = cat['name'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: cat == _categoryItems.last ? 0 : 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? catColor.withOpacity(0.12) : Colors.white,
                            borderRadius: BorderRadius.circular(_kInputRadius),
                            border: Border.all(color: isSelected ? catColor : Colors.grey[300]!, width: isSelected ? 1.5 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(cat['icon'] as IconData, size: 20, color: isSelected ? catColor : kTextGrey),
                              const SizedBox(height: 4),
                              Text(cat['name'] as String, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? catColor : kTextGrey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Inline error message
                if (errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(_kButtonRadius),
                      border: Border.all(color: Colors.red[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 18, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(errorMsg!, style: TextStyle(fontSize: 13, color: Colors.red[700], fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Buttons full width
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kTextGrey,
                          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
                        ),
                        child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kButtonRadius)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = _titleController.text.trim();
                          final content = _contentController.text.trim();
                          if (title.isEmpty || content.isEmpty) {
                            setDialogState(() => errorMsg = "Judul dan isi tidak boleh kosong");
                            return;
                          }
                          Navigator.pop(context);
                          if (isEdit) {
                            if (await _showConfirmDialog(
                              title: "Update Catatan?",
                              content: "Apakah Anda yakin ingin menyimpan perubahan?",
                              confirmText: "Ya, Update",
                              confirmColor: Colors.blue[400],
                            )) {
                              _controller.updateLog(editIndex, title, content, selectedCategory);
                              _titleController.clear(); _contentController.clear();
                              _showStatusPopup("Catatan berhasil diupdate!", icon: Icons.edit_rounded, color: Colors.blue);
                            }
                          } else {
                            _controller.addLog(title, content, selectedCategory);
                            _titleController.clear(); _contentController.clear();
                            _showStatusPopup("Catatan berhasil ditambahkan!");
                          }
                        },
                        child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(int index) async {
    if (await _showConfirmDialog(
      title: "Hapus Catatan?",
      content: "Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak bisa dibatalkan.",
      confirmText: "Ya, Hapus",
      confirmColor: Colors.red[400],
    )) {
      _controller.removeLog(index);
      _showStatusPopup("Catatan berhasil dihapus!", icon: Icons.delete_rounded, color: Colors.orange[700]);
    }
  }

  void _showLogoutConfirm() async {
    if (await _showConfirmDialog(
      title: "Konfirmasi Logout",
      content: "Apakah Anda yakin ingin keluar? Sesi Anda akan diakhiri.",
      confirmText: "Ya, Keluar",
      confirmColor: Colors.red[400],
    )) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingView()),
          (route) => false,
        );
      }
    }
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
        children: [
          // ===== HEADER GOLD PANEL =====
          ValueListenableBuilder<List<LogModel>>(
            valueListenable: _controller.logsNotifier,
            builder: (context, logs, _) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTimeGreeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${logs.length} catatan tersimpan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(_kCardRadius),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // ===== SEARCH BAR =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => _controller.searchLog(value),
                decoration: InputDecoration(
                  hintText: "Cari catatan...",
                  hintStyle: TextStyle(color: kTextGrey.withOpacity(0.6), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: kTextGrey, size: 22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),
          const Expanded(
            child: _LogListSection(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogDialog,
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
        elevation: 4,
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
      valueListenable: state._controller.filteredLogs,
      builder: (context, currentLogs, child) {
        if (currentLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryLight,
                        kPrimary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Belum ada catatan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tekan tombol Tambah untuk\nmulai mencatat aktivitas Anda!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: currentLogs.length,
          itemBuilder: (context, index) {
            final log = currentLogs[index];
            final cat = _catLookup(log.category);
            final color = cat['color'] as Color;
            final actualIndex = state._controller.logsNotifier.value
                .indexWhere((l) => l.date == log.date);
            return Dismissible(
              key: Key(log.date),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.red[600]!],
                  ),
                  borderRadius: BorderRadius.circular(_kCardRadius),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                    SizedBox(height: 4),
                    Text("Hapus", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              confirmDismiss: (_) => state._showConfirmDialog(
                title: "Hapus Catatan?",
                content: "Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak bisa dibatalkan.",
                confirmText: "Ya, Hapus",
                confirmColor: Colors.red[400],
              ),
              onDismissed: (direction) {
                if (actualIndex != -1) {
                  state._controller.removeLog(actualIndex);
                }
                state._showStatusPopup("Catatan berhasil dihapus!", icon: Icons.delete_rounded, color: Colors.orange[700]);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_kCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(_kCardRadius),
                    onTap: () => state._showLogDialog(
                        editIndex: actualIndex != -1 ? actualIndex : index,
                        existingLog: log),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.15),
                                  color.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(_kInputRadius),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + Category Badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: kTextDark,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: color.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        log.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Description
                                Text(
                                  log.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kTextGrey,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Popup Menu
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: kTextGrey, size: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_kInputRadius),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                state._showLogDialog(
                                    editIndex: actualIndex != -1 ? actualIndex : index,
                                    existingLog: log);
                              } else if (value == 'delete') {
                                if (actualIndex != -1) {
                                  state._showDeleteConfirm(actualIndex);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, size: 18, color: Colors.blue[600]),
                                    const SizedBox(width: 12),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_rounded, size: 18, color: Colors.red[600]),
                                    const SizedBox(width: 12),
                                    const Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
