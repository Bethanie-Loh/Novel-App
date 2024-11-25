import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_app/constants/app_strings.dart';
import 'package:novel_app/core/service/storage_service.dart';
import 'package:novel_app/data/genres.dart';
import 'package:novel_app/screens/profile/edit_profile_controller.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_date_picker.dart';
import 'package:novel_app/utils/app_genre_picker.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_drawer.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String quote;
  final String dob;
  final String profilePicture;
  final List<String> selectedGenres;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.profilePicture,
    required this.dob,
    required this.quote,
    required this.selectedGenres,
  });

  static const route = 'edit_profile';
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _editProfileController = EditProfileController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quoteController = TextEditingController();
  List<String> _selectedGenres = [];
  String? _dob;
  String? _imageUrl;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    setState(() {
      _nameController.text = widget.name;
      _quoteController.text = widget.quote;
      _selectedGenres = widget.selectedGenres;
      _imageUrl = widget.profilePicture;

      if (widget.dob.isNotEmpty) {
        final parts = widget.dob.split('/');
        if (parts.length == 3) {
          _dob = "${parts[2]}-${parts[1]}-${parts[0]}";
        } else {
          _dob = widget.dob;
        }
      }
    });
  }

  void _editProfile() async {
    await _editProfileController.updateUser(_nameController.text, _imageUrl!,
        _dob!, _quoteController.text, _selectedGenres, context);
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _uploadBookCover(WidgetRef ref) async {
    final storageService = ref.read(storageProvider.notifier);
    String imageUrl = await storageService.uploadImage();

    if (imageUrl != 'null' && mounted) {
      final res = await _editProfileController.updateCover(imageUrl, context);
      res == AppStrings.success ? setState(() => _imageUrl = imageUrl) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isUploading = ref.watch(storageProvider).isUploading;
      return Scaffold(
          appBar: const AppAppbar(),
          drawer: const AppDrawer(),
          backgroundColor: AppColors.mystery,
          body: Container(
              margin: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.periwinkle.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 3,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: GestureDetector(
                                  onTap: () => _uploadBookCover(ref),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: isUploading
                                        ? const AppLoading()
                                        : _imageUrl == null ||
                                                !_isValidUrl(_imageUrl!)
                                            ? Image.asset(
                                                "assets/images/sky.jpg",
                                                fit: BoxFit.cover,
                                                width: 130,
                                                height: 180,
                                              )
                                            : Image.network(
                                                _imageUrl!,
                                                fit: BoxFit.cover,
                                                width: 130,
                                                height: 180,
                                              ),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 30),
                          AppTextfield(
                              hintText: "Name",
                              obscureText: false,
                              controller: _nameController),
                          // AppDatePicker(
                          //   dob: _dob != null ? DateTime.parse(_dob!) : null,
                          //   hintText: 'D.O.B',
                          //   onDateChanged: (date) {
                          //     setState(() => _dob = date);
                          //   },
                          // ),
                          SizedBox(
                              width: double.infinity,
                              child: AppTextfield(
                                  longText: true,
                                  hintText: "Put a quote to inspire yourself",
                                  obscureText: false,
                                  controller: _quoteController)),
                          AppGenrePicker(
                            editBook: false,
                            genres: genresList,
                            selectedGenres: _selectedGenres,
                            onGenresSelected: (selectedGenres) {
                              setState(() => _selectedGenres = selectedGenres);
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 100,
                      right: 100,
                      child: OutlinedButton(
                        onPressed: () => _editProfile(),
                        style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 0)),
                            side: const WidgetStatePropertyAll(BorderSide.none),
                            backgroundColor: const WidgetStatePropertyAll(
                                AppColors.emerald)),
                        child: const Text("Edit Profile",
                            style: AppTextStyles.italic_bold_16),
                      ),
                    ),
                  ],
                ),
              )));
    });
  }
}
