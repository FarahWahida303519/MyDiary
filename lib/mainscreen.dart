import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylistdata.dart';
import 'package:mydiary/diary_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //store data retrieve from db
  List<DiaryListData> diarList = [];

//pagination
  int curpageno = 1;
  int limit = 5;
  String status = "Loading...";

  bool isSearching = false;
  String lastSearchKeyword = "";//store last search keyword

  @override
  void initState() {
    super.initState();
    loadData();//to load data 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //button to add new diary
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE06092),
        elevation: 6,
        //navigate to 
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiaryPage()),
          );
          loadData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCE1F3),
              Color(0xFFD2E4FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [

            // HEADER (not changed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Diary 📔",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB03A75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "A safe place for your memories",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // SEARCH BAR
                  GestureDetector(
                    onTap: showSearchDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search your diary...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isSearching)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            lastSearchKeyword = "";
                          });
                          loadData();
                        },
                        child: const Text(
                          "← Back ",
                          style: TextStyle(
                            color: Color(0xFFB03A75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: diarList.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: diarList.length,
                      itemBuilder: (context, index) {
                        final item = diarList[index];

                        // TAP LIST TO OPEN & UPDATE
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DiaryPage(),
                                settings:
                                    RouteSettings(arguments: item),
                              ),
                            );
                            loadData();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE06092),
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(22),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child:
                                                _loadImage(item.imagename),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.pink.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      item.date,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFFB03A75),
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),

                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        deleteDialog(item.id),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                item.title,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                item.description,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE (not changed)
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 90, color: Colors.pink.shade200),
          const SizedBox(height: 20),
          Text(
            isSearching ? "No diary found" : status,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB03A75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? "No result for \"$lastSearchKeyword\""
                : "Tap + to start writing 💗",
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  // IMAGE 
  Widget _loadImage(String imagename) {
    if (imagename == "NA") {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    final file = File(imagename);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.broken_image);
  }

  // LOAD DATA 
  Future<void> loadData() async {
    setState(() {
      status = "Loading...";
      diarList = [];
    });

    diarList = await DatabaseHelper()
        .getMyListsPaginated(limit, (curpageno - 1) * limit);

    if (diarList.isEmpty) status = "No diary yet";
    setState(() {});
  }

  // DELETE 
  void deleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Entry?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper().deleteMyList(id);
              if (context.mounted) Navigator.pop(context);
              loadData();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // SEARCH 
  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Diary"),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search title or description",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final keyword = searchController.text.trim();

              if (keyword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a keyword to search"),
                  ),
                );
                return;
              }

              diarList =
                  await DatabaseHelper().searchMyList(keyword);

              setState(() {
                isSearching = true;
                lastSearchKeyword = keyword;
              });

              Navigator.pop(context);
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }
}
