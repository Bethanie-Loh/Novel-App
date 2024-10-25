import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_alert_dialog.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppGenrePicker extends StatefulWidget {
  final List<String> genres;
  final List<String> selectedGenres;
  final void Function(List<String>) onGenresSelected;
  final String? errorMessage;
  final bool editBook;

  const AppGenrePicker(
      {super.key,
      required this.genres,
      required this.selectedGenres,
      required this.onGenresSelected,
      this.errorMessage,
      required this.editBook});

  @override
  AppGenrePickerState createState() => AppGenrePickerState();
}

class AppGenrePickerState extends State<AppGenrePicker> {
  late List<String> _selectedGenres;

  @override
  void initState() {
    super.initState();
    _selectedGenres = List.from(widget.selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGenrePickerDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedGenres.isEmpty
                    ? widget.editBook
                        ? 'Select Novel Genres'
                        : 'Favourite Novel Genres'
                    : _selectedGenres.join(', '),
                overflow: TextOverflow.visible,
                style: _selectedGenres.isEmpty
                    ? AppTextStyles.hintInputText
                    : AppTextStyles.inputText,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.gray),
          ],
        ),
      ),
    );
  }

  Future<void> _showGenrePickerDialog(BuildContext context) async {
    final selectedGenres = await showDialog<List<String>>(
      context: context,
      builder: (context) => _GenrePickerDialog(
          genres: widget.genres,
          selectedGenres: _selectedGenres,
          editBook: widget.editBook),
    );

    if (selectedGenres != null && selectedGenres.length >= 3) {
      setState(() {
        _selectedGenres = selectedGenres;
      });
      widget.onGenresSelected(selectedGenres);
    } else if (selectedGenres != null) {
      if (!context.mounted) return;
      _showMinimumSelectionAlert(context);
    }
  }

  void _showMinimumSelectionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Selection'),
        content: const Text('Please select at least 3 genres.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GenrePickerDialog extends StatefulWidget {
  final List<String> genres;
  final List<String> selectedGenres;
  final bool? editBook;
  const _GenrePickerDialog(
      {required this.genres, required this.selectedGenres, this.editBook});

  @override
  _GenrePickerDialogState createState() => _GenrePickerDialogState();
}

class _GenrePickerDialogState extends State<_GenrePickerDialog> {
  late List<String> _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = List.from(widget.selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.editBook!
            ? 'Select 3 genres for your book'
            : 'Select your top 3 favourite genres',
        style: AppTextStyles.bold_18.copyWith(color: AppColors.black),
      ),
      backgroundColor: AppColors.white,
      content: Theme(
        data: ThemeData.light().copyWith(
          primaryColor: AppColors.periwinkle,
          colorScheme: const ColorScheme.light(
            primary: AppColors.periwinkle,
            onPrimary: AppColors.white,
            onSurface: AppColors.mulberry,
          ),
          textTheme: const TextTheme(
            headlineLarge: AppTextStyles.bold_26,
            titleLarge: AppTextStyles.italic_bold_16,
            labelLarge: AppTextStyles.inputText,
            bodyLarge: AppTextStyles.inputText,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: widget.genres.map((genre) {
              return CheckboxListTile(
                title: Text(
                  genre,
                  style: AppTextStyles.inputText,
                ),
                value: _currentSelection.contains(genre),
                onChanged: (isSelected) {
                  setState(() {
                    if (isSelected == true) {
                      if (_currentSelection.length < 3) {
                        _currentSelection.add(genre);
                      }
                    } else {
                      _currentSelection.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTextStyles.italic_bold_16
                .copyWith(color: AppColors.mulberry),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_currentSelection.length >= 3) {
              Navigator.of(context).pop(_currentSelection);
            } else {
              _showMinimumSelectionAlert(context);
            }
          },
          child: Text(
            'OK',
            style: AppTextStyles.italic_bold_16
                .copyWith(color: AppColors.mulberry),
          ),
        ),
      ],
    );
  }

  void _showMinimumSelectionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppAlertDialog(
        title: 'Invalid Selection',
        content: 'Please select at least 3 genres.',
        textOK: 'Ok',
        onOkPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
