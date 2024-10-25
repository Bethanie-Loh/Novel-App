import 'package:flutter/material.dart';
import 'package:novel_app/screens/auth/register/register_screen_2.dart';
import 'package:novel_app/utils/app_button.dart';
import 'package:novel_app/utils/app_date_picker.dart';
import 'package:novel_app/utils/app_dropdown.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_validator.dart';
import 'package:novel_app/utils/app_genre_picker.dart';
import 'package:novel_app/utils/app_text_field.dart';
import 'package:novel_app/data/genres.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const route = "Register";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;
  String? _dob;
  List<String> _selectedGenres = [];
  bool _isLoading = false;

  void proceed() async {
    if (!AppValidator.checkInputIfEmpty([
      _nameController.text,
      _selectedGender ?? '',
      _dob ?? '',
      ..._selectedGenres
    ], context)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for the process (e.g., network request)
    await Future.delayed(const Duration(seconds: 2));

    debugPrint('Name: ${_nameController.text}');
    debugPrint('Gender: $_selectedGender');
    debugPrint('Genres: $_selectedGenres');
    debugPrint('Date of Birth: $_dob');

    if (mounted) {
      context.pushNamed(
        RegisterScreen2.route,
        extra: {
          'name': _nameController.text,
          'gender': _selectedGender!,
          'genres': _selectedGenres,
          'dob': _dob!,
        },
      );
    }

    setState(() {
      _isLoading = false; // End loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.galaxy,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 55),
                  child: const Column(
                    children: [
                      Text(
                        'DREAM',
                        style: AppTextStyles.appName,
                      ),
                      Text(
                        'Dare to dream, dare to write',
                        style: AppTextStyles.italic_bold_16,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    'Tell us something about yourself',
                    style: AppTextStyles.italic_bold_16,
                  ),
                ),
                AppTextfield(
                  hintText: 'Name e.g: Barbara Palvins',
                  obscureText: false,
                  controller: _nameController,
                ),
                AppDropdown(
                  label: 'Gender',
                  items: const ['Male', 'Female'],
                  selectedItem: _selectedGender,
                  onChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),
                AppDatePicker(
                  hintText: 'D.O.B',
                  onDateChanged: (date) {
                    setState(() {
                      _dob = date;
                    });
                  },
                ),
                AppGenrePicker(
                  editBook: false,
                  genres: genresList,
                  selectedGenres: _selectedGenres,
                  onGenresSelected: (selectedGenres) {
                    setState(() {
                      _selectedGenres = selectedGenres;
                    });
                  },
                ),
                const SizedBox(height: 25),
                AppButton(
                  label: 'PROCEED',
                  onPressed: () {
                    proceed();
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Align(
              alignment: Alignment.center,
              child: AppLoading(),
            ),
        ],
      ),
    );
  }
}
