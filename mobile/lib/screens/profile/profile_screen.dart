import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user?.fullName[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Foydalanuvchi',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user?.phone ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Rol'),
                    subtitle: Text(user?.role == 'client' ? 'Mijoz' : 'Xizmat ko\'rsatuvchi'),
                  ),
                  const Divider(),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text('Qorong\'u rejim'),
                        value: themeProvider.isDarkMode,
                        onChanged: (_) {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Ilova haqida'),
                    subtitle: const Text('Versiya 1.0.0'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Chiqish'),
                    content: const Text('Tizimdan chiqmoqchimisiz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Yo\'q'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          Navigator.pop(context);
                        },
                        child: const Text('Ha'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
              ),
              child: const Text('Chiqish'),
            ),
          ],
        ),
      ),
    );
  }
}
