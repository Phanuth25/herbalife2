import 'package:flutter/material.dart';
import 'package:project2/herbalife/l10n/app_localizations.dart';
import 'package:project2/herbalife/public/page/info.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/widget/welcome.dart';
import 'package:project2/herbalife/public/data/notifier.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:project2/herbalife/public/provider/khqr_provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => Authprovider()),
      ChangeNotifierProvider(create: (_) => KhqrProvider()),
      ChangeNotifierProvider(create: (_) => SecureStorageProvider()),
    ],
    child: const Main(),
  ),
);

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Access dataProvider without listening
    final dataProvider = Provider.of<SecureStorageProvider>(
      context,
      listen: false,
    );

    // Read stored data from Flutter Secure Storage
    final String? savedUserId = await dataProvider.readSecureData('userId');
    final String? savedId = await dataProvider.readSecureData('id');

    // Update global ValueNotifiers so the UI reacts
    if (savedUserId != null) {
      isUser.value = savedUserId;
    }
    if (savedId != null) {
      isId.value = savedId;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.teal)),
        ),
      );
    }

    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, value, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDark,
          builder: (context, isDarkMode, child) {
            return MaterialApp(
              locale: value,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.teal,
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ),
              ),
              home: ValueListenableBuilder(
                valueListenable: isUser,
                builder: (context, userVal, child) {
                  return Scaffold(
                    body: ValueListenableBuilder(
                      valueListenable: isId,
                      builder: (context, idVal, child) {
                        if (isUser.value != "") {
                          return Info(isUser.value);
                        } else {
                          return const Welcome();
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
