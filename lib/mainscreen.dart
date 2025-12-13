import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylistdata.dart';
import 'package:mydiary/newitemscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<DiaryListData> diarList = [];
  int curpageno = 1;
  int limit = 5;
  int pages = 1;
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE9F3), // soft diary pink

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE06092),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewItemScreen()),
          );
          loadData();
        },
      ),

      body: Column(
        children: [
          // ==========================================================
          // SOFT-PINK DIARY HEADER
          // ==========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 55, bottom: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE9F3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      "My Diary Entries",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ===================== Search Field =====================
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),

                      const SizedBox(width: 8),

                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: showSearchDialog,
                          decoration: const InputDecoration(
                            hintText: "Search diary entries...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Search reset")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // CONTENT LIST AREA
          // ==========================================================
          Expanded(
            child: diarList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 90,
                          color: Colors.pink.shade200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          status,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Start writing your beautiful moments...",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: diarList.length,
                    itemBuilder: (_, index) {
                      final item = diarList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ================= IMAGE =================
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: loadImageWidget(item.imagename),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ================= TEXT SECTION =================
                            Expanded(
                              child: InkWell(
                                onTap: () => showDetailsDialog(item),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.description.isEmpty
                                          ? "No description"
                                          : item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.date,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ================= ACTION BUTTONS =================
                            Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 22),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NewItemScreen(),
                                            settings: RouteSettings(
                                              arguments: item,
                                            ),
                                          ),
                                        );
                                        loadData(); // refresh list after update
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 22,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => deleteDialog(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // =============== PAGE NAVIGATION ===============
          if (diarList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: curpageno > 1
                        ? () {
                            curpageno--;
                            loadData();
                          }
                        : null,
                  ),
                  Text(
                    "Page $curpageno of $pages",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: curpageno < pages
                        ? () {
                            curpageno++;
                            loadData();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // IMAGE LOADER
  // ---------------------------------------------------------
  Widget loadImageWidget(String imagename) {
    if (imagename == "NA") {
      return const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      );
    }
    final file = File(imagename);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.broken_image, size: 40, color: Colors.grey);
  }

  // ---------------------------------------------------------
  // LOAD DATA + PAGINATION
  // ---------------------------------------------------------
  Future<void> loadData() async {
    setState(() {
      status = "Loading...";
      diarList = [];
    });

    final total = await DatabaseHelper().getTotalCount();
    pages = (total / limit).ceil();

    int offset = (curpageno - 1) * limit;
    diarList = await DatabaseHelper().getMyListsPaginated(limit, offset);

    if (diarList.isEmpty) status = "Not Available.";
    setState(() {});
  }

  // ---------------------------------------------------------
  // DELETE ITEM
  // ---------------------------------------------------------
  void deleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  "Delete Entry?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  "This action cannot be undone.\nAre you sure you want to remove this entry from your list?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await DatabaseHelper().deleteMyList(id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Entry deleted successfully"),
                              ),
                            );
                          }
                          loadData();
                        },
                        child: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // EDIT ITEM
  // ---------------------------------------------------------
  void editItemDialog(DiaryListData item) {
    TextEditingController titleController = TextEditingController(
      text: item.title,
    );

    TextEditingController descriptionController = TextEditingController(
      text: item.description,
    );

    bool isCompleted = item.status == "Completed";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------
                    // TITLE
                    // ---------------------------------------------------
                    const Text(
                      "Edit Entry",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------------------------------
                    // TITLE INPUT
                    // ---------------------------------------------------
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------
                    // DESCRIPTION INPUT
                    // ---------------------------------------------------
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description",
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ---------------------------------------------------
                    // STATUS SWITCH
                    // ---------------------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.pending_outlined,
                            color: isCompleted
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isCompleted ? "Completed" : "Pending",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isCompleted,
                            activeThumbColor: Colors.green,
                            onChanged: (val) {
                              setState(() => isCompleted = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------
                    // ACTION BUTTONS
                    // ---------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE06092),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update"),
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Title cannot be empty."),
                                ),
                              );
                              return;
                            }

                            item.title = titleController.text.trim();
                            item.description = descriptionController.text
                                .trim();
                            item.status = isCompleted ? "Completed" : "Pending";

                            await DatabaseHelper().updateMyList(item);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            loadData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // DETAILS DIALOG
  // ---------------------------------------------------------
  void showDetailsDialog(DiaryListData item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: loadImageWidget(item.imagename),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _infoChip(
                        Icons.check_circle,
                        item.status,
                        item.status == "Completed"
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 10),
                      _infoChip(
                        Icons.calendar_today,
                        item.date,
                        Colors.blueGrey[700],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE06092),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String text, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // SEARCH DIALOG
  // ---------------------------------------------------------
  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -------------------------------------------
                // TITLE
                // -------------------------------------------
                const Text(
                  "Search List",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // -------------------------------------------
                // SEARCH BAR
                // -------------------------------------------
                TextField(
                  controller: searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(searchController.text),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    hintText: "Search by title or description...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -------------------------------------------
                // BUTTONS
                // -------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE06092),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text("Search"),
                      onPressed: () {
                        _performSearch(searchController.text);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch(String keyword) async {
    diarList = await DatabaseHelper().searchMyList(keyword.trim());
    status = diarList.isEmpty ? "No task match your search." : "";
    setState(() {});
  }
}
