import 'package:go_router/go_router.dart';
import 'package:novel_app/screens/auth/auth_gate.dart';
import 'package:novel_app/screens/auth/login/login_screen.dart';
import 'package:novel_app/screens/auth/register/register_screen.dart';
import 'package:novel_app/screens/auth/register/register_screen_2.dart';
import 'package:novel_app/screens/edit_book/edit_book_screen.dart';
import 'package:novel_app/screens/library/library_screen.dart';
import 'package:novel_app/screens/profile/edit_profile_screen.dart';
import 'package:novel_app/screens/profile/profile_screen.dart';
import 'package:novel_app/screens/read/read_screen.dart';
import 'package:novel_app/screens/tab_container_screen.dart';
import 'package:novel_app/screens/view_book.dart/view_book_screen.dart';
import 'package:novel_app/screens/write/write_screen.dart';
import 'package:novel_app/screens/your_books/your_books_screen.dart';

class Navigation {
  static final routes = [
    GoRoute(
      path: '/auth',
      builder: (_, __) => const AuthGate(),
    ),
    GoRoute(
        path: "/login",
        name: LoginScreen.route,
        builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: "/register",
        name: RegisterScreen.route,
        builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: "/register2",
      name: RegisterScreen2.route,
      builder: (_, state) {
        final args = state.extra as Map<String, dynamic>?;

        return RegisterScreen2(
          name: args?['name'] as String? ?? '',
          gender: args?['gender'] as String? ?? '',
          genres: List<String>.from(args?['genres'] ?? []),
          dob: args?['dob'] as String? ?? '',
        );
      },
    ),
    GoRoute(
        path: '/home',
        name: TabContainerScreen.route,
        builder: (_, __) => const TabContainerScreen()),
    GoRoute(
        path: '/library',
        name: LibraryScreen.route,
        builder: (_, __) => const LibraryScreen()),
    GoRoute(
      path: '/write/:bookId/:chapterId',
      name: WriteScreen.route,
      builder: (_, state) {
        final Map<String, dynamic> args =
            state.extra as Map<String, dynamic>? ??
                {
                  'newBook': false,
                  'chapterTitle': 'New Chapter',
                };

        final String? bookId = state.pathParameters['bookId'];
        final chapterId =
            int.tryParse(state.pathParameters['chapterId']!) ?? -1;
        final String chapterTitle =
            args['chapterTitle'] as String? ?? 'New Chapter';
        final bool newBook = args['newBook'] as bool? ?? false;

        return WriteScreen(
          bookId: bookId,
          chapterId: chapterId,
          chapterTitle: chapterTitle,
          newBook: newBook,
        );
      },
    ),
    GoRoute(
        path: '/yourBooks',
        name: YourBooksScreen.route,
        builder: (_, __) => const YourBooksScreen()),
    GoRoute(
      path: '/profile',
      name: ProfileScreen.route,
      builder: (_, state) => ProfileScreen(
        userId: state.extra as String,
      ),
    ),
    GoRoute(
      path: '/read/:bookId/:chapterId',
      name: ReadScreen.route,
      builder: (_, state) {
        final bookId = state.pathParameters['bookId']!;
        final chapterId =
            int.tryParse(state.pathParameters['chapterId']!) ?? -1;
        final Map<String, dynamic> args =
            state.extra as Map<String, dynamic>? ?? {'clickFromHome': false};

        final bool clickFromHome = args['clickFromHome'] as bool? ?? false;

        return ReadScreen(
          bookId: bookId,
          chapterId: chapterId,
          clickFromHome: clickFromHome,
        );
      },
    ),
    GoRoute(
      path: '/view_book/:bookId',
      name: ViewBookScreen.route,
      builder: (_, state) {
        final bookId = state.pathParameters['bookId']!;
        final extraMap = state.extra! as Map<String, dynamic>;
        final isAuthor = extraMap['isAuthor'] as bool;
        final isSaved = extraMap['isSaved'] as bool;
        final isWriting = extraMap['isWriting'] as bool;

        return ViewBookScreen(
          bookId: bookId,
          isAuthor: isAuthor,
          isSaved: isSaved,
          isWriting: isWriting,
        );
      },
    ),
    GoRoute(
        path: '/edit_book/:bookId',
        name: EditBookScreen.route,
        builder: (_, state) {
          final bookId = state.pathParameters['bookId']!;
          return EditBookScreen(bookId: bookId);
        }),
    GoRoute(
        path: '/edit_profile/:userId',
        name: EditProfileScreen.route,
        builder: (_, state) {
          final userId = state.pathParameters['userId']!;
          final extra = state.extra as Map<String, dynamic>;
          final name = extra['name'] as String;
          final profilePicture = extra['profilePicture'] as String;
          final quote = extra['quote'] as String;
          final dob = extra['dob'] as String;
          final selectedGenres =
              List<String>.from(extra['selectedGenres'] as List);

          return EditProfileScreen(
            userId: userId,
            name: name,
            profilePicture: profilePicture,
            quote: quote,
            dob: dob,
            selectedGenres: selectedGenres,
          );
        })
  ];
}
