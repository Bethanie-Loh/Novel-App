import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/screens/auth/logout.dart';
import 'package:novel_app/screens/profile/profile_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class AppAppbar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppbar({super.key});

  @override
  State<AppAppbar> createState() => _AppAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppAppbarState extends State<AppAppbar> {
  final _userRepo = UserRepo();

  @override
  Widget build(BuildContext context) {
    void handleLogout() {
      showLogoutDialogAndPerformLogout(context);
    }

    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/ic_sparkle1.svg',
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              'Dream',
              style: AppTextStyles.appName
                  .copyWith(fontSize: 30, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/icons/ic_sparkle2.svg',
          ),
        ],
      ),
      backgroundColor: AppColors.mystery,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: StreamBuilder<AppUser?>(
            stream: _userRepo.getUserStream(), // Use the stream directly
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoading();
              } else if (snapshot.hasError) {
                return const Icon(Icons.error, color: Colors.red);
              } else if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!;
                return PopupMenuButton<String>(
                  color: AppColors.periwinkle,
                  onSelected: (value) {
                    if (value == 'Profile') {
                      context.pushNamed(ProfileScreen.route, extra: '');
                    } else if (value == 'Logout') {
                      handleLogout();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Profile',
                        child: Text('Profile', style: AppTextStyles.bold_14),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Logout',
                        child: Text('Logout', style: AppTextStyles.bold_14),
                      ),
                    ];
                  },
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: user.profilePicture != null &&
                              user.profilePicture!.isNotEmpty
                          ? Image.network(
                              user.profilePicture!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.asset(
                              "assets/images/sky.jpg",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                );
              } else {
                return Image.asset(
                  "assets/images/sky.jpg",
                  fit: BoxFit.cover,
                  width: 26,
                  height: 26,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
