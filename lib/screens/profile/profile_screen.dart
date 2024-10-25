import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novel_app/core/service/auth_service.dart';
import 'package:novel_app/data/model/user.dart';
import 'package:novel_app/data/repo/user_repo.dart';
import 'package:novel_app/screens/profile/edit_profile_screen.dart';
import 'package:novel_app/utils/app_colors.dart';
import 'package:novel_app/utils/app_loading.dart';
import 'package:novel_app/utils/app_text_styles.dart';
import 'package:novel_app/widgets/app_appbar.dart';
import 'package:novel_app/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});
  static const route = "Profile";
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepo = UserRepo();
  AppUser? _user;
  String? _joinedDate;
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _getUser();
  }

  void _getUser() async {
    setState(() => _isLoading = true);
    if (widget.userId!.isNotEmpty) {
      final user = await _userRepo.getUserById(widget.userId!);
      if (user != null) {
        setState(() {
          _user = user;
          _joinedDate = _formatJoinedDate(user.joinedDate);
          _isLoading = false;
        });
      }
    } else {
      _userRepo.getUserStream().listen((user) {
        if (user != null) {
          setState(() {
            _user = user;
            _userId = AuthService().getUid();
            _joinedDate = _formatJoinedDate(user.joinedDate);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  void _editProfile() {
    if (_user != null) {
      context.pushNamed(
        EditProfileScreen.route,
        pathParameters: {'userId': _userId!},
        extra: {
          'name': _user!.name,
          'profilePicture': _user!.profilePicture ?? '',
          'quote': _user!.quote ?? "No quote yet",
          'selectedGenres': _user!.favouriteGenres,
          'dob': _user!.dob,
        },
      );
    } else {
      debugPrint("User data not available. Cannot edit profile.");
    }
  }

  String _formatJoinedDate(String? dateTimeString) {
    if (dateTimeString == null) return "";

    try {
      final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy HH:mm:ss');
      final DateTime dateTime = dateTimeFormat.parse(dateTimeString);
      return DateFormat('MMMM yyyy').format(dateTime);
    } catch (e) {
      debugPrint("Error formatting joined date: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppAppbar(),
        drawer: const AppDrawer(),
        backgroundColor: AppColors.mystery,
        body: _isLoading
            ? const AppLoading()
            : Container(
                margin: const EdgeInsets.all(30),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: _user != null &&
                                          _user!.profilePicture != null &&
                                          _user!.profilePicture!.isNotEmpty
                                      ? Image.network(
                                          _user!.profilePicture!,
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
                                )),
                          ),
                          const SizedBox(height: 30),
                          Text("${_user?.name}",
                              style: AppTextStyles.italic_bold_24
                                  .copyWith(color: AppColors.white)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 250,
                            child: Card(
                              elevation: 10,
                              shadowColor: AppColors.white,
                              color: AppColors.mulberry,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    _user?.quote != null
                                        ? "${_user?.quote}"
                                        : "You have no quote yet",
                                    textAlign:
                                        TextAlign.center, // Center the text
                                    style: AppTextStyles.italic_bold_14
                                        .copyWith(color: AppColors.yellow),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          widget.userId!.isEmpty
                              ? Text("Born In: ${_user?.dob}",
                                  style: AppTextStyles.bold_16)
                              : const Text(""),
                          const SizedBox(height: 20),
                          Text("Joined: $_joinedDate",
                              style: AppTextStyles.bold_16),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 350,
                            child: Text(
                              "Favourite Genres: \n${_user?.favouriteGenres.join(", ")}",
                              textAlign: TextAlign
                                  .center, // Center the favorite genres text
                              style: AppTextStyles.bold_16,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 100,
                      right: 100,
                      child: OutlinedButton(
                        onPressed: () {
                          _editProfile();
                        },
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
              ));
  }
}
