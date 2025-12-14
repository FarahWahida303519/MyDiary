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
  //read input
  TextEditingController searchController = TextEditingController();

  //pagination
  int curpageno = 1;
  int limit = 5;
  String status = "Loading...";

  bool isSearching = false;
  String lastSearchKeyword = ""; //store last search keyword

  @override
  void initState() {
    super.initState();
    loadData(); //to load data from db
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //button to add new diary
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE06092),
        elevation: 6,
        //navigate to DiaryPage Screen
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiaryPage()),
          );
          loadData(); //reload data after run
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      //BG color
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCE1F3), Color(0xFFD2E4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    //Title
                    "My Diary 📔",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB03A75),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    //Sub text under the title
                    "A safe place for your memories",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // SEARCH BAR
                  GestureDetector(
                    onTap: showSearchDialog, //to open the search dialog
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

                      //search icon & text
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search your diary...",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //back button
                  if (isSearching)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            lastSearchKeyword = "";
                          });
                          loadData(); //reload the full list
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
                  ? _emptyState() //to show the empty ui
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: diarList.length,
                      itemBuilder: (context, index) {
                        final item = diarList[index]; //to get one record

                        // TAP LIST TO OPEN & UPDATE
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DiaryPage(),
                                settings: RouteSettings(arguments: item),
                              ),
                            );
                            loadData(); //reload after udate the diary
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
                                //Left Bar
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

                                //Diary content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //diary image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: _loadImage(item.imagename),
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
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item.date,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFFB03A75,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),

                                                  //Delete diary
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
                                                //Title in diary page
                                                item.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                //Diary content
                                                item.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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

  // Display when no any diary record
  Widget _emptyState() {
    //to set content as center in the screen
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Icon for diary in list empty
          Icon(Icons.menu_book_rounded, size: 90, color: Colors.pink.shade200),

          //space icon &text
          const SizedBox(height: 20),
          //Message
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

  // to loa and display imge
  Widget _loadImage(String imagename) {
    //if no image saved,then display placeholder!
    if (imagename == "NA") {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    final file = File(imagename); //create file use img path
    return file
            .existsSync() //checkk if image file exists
        ? Image.file(file, fit: BoxFit.cover) //if exist,display img
        : const Icon(Icons.broken_image); //if not,show broken img
  }

  // Load data from sqflite db
  Future<void> loadData() async {
    setState(() {
      //to update ui before load data
      status = "Loading...";
      diarList = []; //clear existing list
    });

    //Fetch diary data with pagination from database
    diarList = await DatabaseHelper().getMyListsPaginated(
      limit,
      (curpageno - 1) * limit,
    );

    //if not return ,update status msg
    if (diarList.isEmpty) status = "No diary yet";
    setState(() {}); //refresh ui after load data
  }

  // confirmation before delete
  void deleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //Title dialog
        title: const Text("Delete Entry?"),
        //msg warning
        content: const Text("This action cannot be undone."),
        actions: [
          //cancel buton
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //delete btn
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            //operation delete
            onPressed: () async {
              await DatabaseHelper().deleteMyList(id);
              if (context.mounted) Navigator.pop(context);
              loadData(); //reload diary list
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // SEARCH
  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //dialo title
        title: const Text("Search Diary"),

        //field input
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search title or description",
          ),
        ),
        actions: [
          //cancel btn
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //search btn
          ElevatedButton(
            onPressed: () async {
              //final keyword
              final keyword = searchController.text.trim();

              //if input empty,disply error msg
              if (keyword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a keyword to search"),
                  ),
                );
                return;
              }

              //search records from db
              diarList = await DatabaseHelper().searchMyList(keyword);

              //Update 
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
