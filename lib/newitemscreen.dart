import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/mylist.dart';
import 'package:path_provider/path_provider.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  File? image;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE9F3), // soft diary pink
      body: SafeArea(
        child: Column(
          children: [
            // ================== TOP BAR ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 26, color: Colors.black87),
                  ),
                  const Spacer(),

                  // More options (dummy)
                  const Icon(Icons.more_vert, color: Colors.black87),

                  const SizedBox(width: 12),

                  // SAVE BUTTON (TOP RIGHT)
                  ElevatedButton(
                    onPressed: showConfirmDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE06092),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ================== DIARY CONTENT ==================
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== DATE DISPLAY ==========
                      Row(
                        children: [
                          Text(
                            DateFormat("dd")
                                .format(DateTime.now()), // day bold
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat("MMM yyyy")
                                    .format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // EMOJI (optional but shown in UI)
                          const Icon(Icons.emoji_emotions_outlined,
                              color: Colors.black54, size: 28),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ========== TITLE ==========
                      TextField(
                        controller: titleController,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(
                              fontSize: 20, color: Colors.black45),
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ========== DESCRIPTION ==========
                      TextField(
                        controller: descriptionController,
                        maxLines: null,
                        style: const TextStyle(
                            fontSize: 17, color: Colors.black87),
                        decoration: const InputDecoration(
                          hintText: "Write more here...",
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.black38),
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ========== IMAGE PICKER (CLICK TO ADD) ==========
                      GestureDetector(
                        onTap: selectCameraGalleryDialog,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.black26, width: 1.2),
                          ),
                          child: image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt_rounded,
                                        size: 38, color: Colors.black54),
                                    SizedBox(height: 8),
                                    Text(
                                      "Tap to add image",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    image!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ================== BOTTOM TOOLBAR (LOOK ONLY) ==================
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 5)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.brush_outlined),
                  Icon(Icons.image_outlined),
                  Icon(Icons.star_border),
                  Icon(Icons.emoji_emotions_outlined),
                  Icon(Icons.text_fields_outlined),
                  Icon(Icons.format_list_bulleted_rounded),
                  Icon(Icons.label_outline),
                  Icon(Icons.mic_none_rounded),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===================== PICKER SHEET =====================
  void selectCameraGalleryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Image Source",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openCamera();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE06092).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Color(0xFFE06092), size: 40),
                        ),
                        const SizedBox(height: 6),
                        const Text("Camera")
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      openGallery();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE06092).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.photo_library_rounded,
                              color: Color(0xFFE06092), size: 40),
                        ),
                        const SizedBox(height: 6),
                        const Text("Gallery"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.black54)),
              )
            ],
          ),
        );
      },
    );
  }

  // ===================== CAMERA =====================
  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 900);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      cropImage();
    }
  }

  // ===================== GALLERY =====================
  Future<void> openGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      cropImage();
    }
  }

  // ===================== CROP IMAGE =====================
  Future<void> cropImage() async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: const Color(0xFFE06092),
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: "Crop Image")
      ],
    );

    if (cropped != null) {
      image = File(cropped.path);
      setState(() {});
    }
  }

  // ===================== CONFIRM SAVE =====================
  void showConfirmDialog() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE06092).withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.save_rounded,
                        size: 36, color: Color(0xFFE06092))),
                const SizedBox(height: 15),
                const Text("Confirm Save",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Save this diary entry?",
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE06092))),
                        child: const Text("Cancel",
                            style: TextStyle(color: Color(0xFFE06092))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          saveItem();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE06092)),
                        child: const Text("Save",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== SAVE TO DATABASE =====================
  Future<void> saveItem() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String storedImagePath = "NA";

    if (image != null) {
      String imageName = "${DateTime.now().millisecondsSinceEpoch}.png";
      storedImagePath = "${appDir.path}/$imageName";
      await image!.copy(storedImagePath);
    }

    await DatabaseHelper().insertMyList(
      MyList(
        0,
        titleController.text,
        descriptionController.text,
        "Pending",
        formatter.format(DateTime.now()),
        storedImagePath,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry saved successfully")),
      );
      Navigator.pop(context);
    }
  }
}
