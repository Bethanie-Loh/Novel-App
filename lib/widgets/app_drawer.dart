import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:novel_app/screens/library/library_screen.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/screens/your_books/your_books_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.mystery,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_sparkle1.svg',
                ),
                const SizedBox(width: 10),
                Text(
                  'Dream',
                  style: AppTextStyles.appName
                      .copyWith(fontSize: 40, color: AppColors.white),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(
                  'assets/icons/ic_sparkle2.svg',
                ),
              ],
            ),
          ),
          ListTile(
            title: Text("Write New Book",
                style: AppTextStyles.bold_20.copyWith(color: AppColors.white)),
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 100));
              if (!context.mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
              context.pushNamed(
                WriteScreen.route,
                pathParameters: {
                  'bookId': '-1',
                  'chapterId': '-1',
                },
                extra: {'newBook': true},
              );
            },
          ),
          ListTile(
            title: Text("Your Books",
                style: AppTextStyles.bold_20.copyWith(color: AppColors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
              context.pushNamed(YourBooksScreen.route);
            },
          ),
          ListTile(
            title: Text("Library",
                style: AppTextStyles.bold_20.copyWith(color: AppColors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
              context.pushNamed(LibraryScreen.route);
            },
          ),
        ],
      ),
    );
  }
}
