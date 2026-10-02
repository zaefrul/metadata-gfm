import 'dart:async';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'gems_chrome.dart';

class BuildDrawer extends StatelessWidget {
  final bool isHome;
  final Function backFunc;
  final String email = "operationalexcellence@globalfm.com.my";

  const BuildDrawer(this.backFunc, {this.isHome = false, super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);

    return FutureBuilder<String?>(
      future: User.getPrefUser,
      builder: (ctx, snapshot) {
        User? currentUser;
        final data = snapshot.data;
        if (data != null) {
          currentUser = User.fromMap(data);
        }

        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/logo-cropped.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Divider(height: 1, color: GemsChrome.border),
                if (currentUser != null)
                  _userRow(currentUser, () {
                    nav.pop();
                    nav.pushNamed("/profile");
                  }),
                _navTile(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  active: isHome,
                  onTap: () {
                    nav.pop();
                    if (!isHome) {
                      Timer(const Duration(milliseconds: 300), () {
                        nav.popUntil(ModalRoute.withName("/homepage"));
                      });
                    }
                  },
                ),
                _navTile(
                  label: 'Profile',
                  icon: Icons.person_outline,
                  onTap: () {
                    nav.pop();
                    nav.pushNamed("/profile");
                  },
                ),
                _navTile(
                  label: 'Track Monitoring',
                  icon: Icons.monitor_heart_outlined,
                  onTap: () {
                    nav.pop();
                    nav.pushNamed("/monitoring");
                  },
                ),
                _navTile(
                  label: 'Return Items',
                  icon: Icons.assignment_return_outlined,
                  onTap: () {
                    nav.pop();
                    nav.pushNamed("/return-item-list");
                  },
                ),
                const Spacer(),
                _navTile(
                  label: 'Support',
                  icon: Icons.support_agent_outlined,
                  onTap: () {
                    nav.pop();
                    nav.pushNamed("/support");
                  },
                ),
                _navTile(
                  label: 'Logout',
                  icon: Icons.logout,
                  onTap: () async {
                    if (currentUser != null) {
                      await currentUser.removeUser();
                    }
                    nav.pop();
                    nav.pushReplacementNamed("/");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    '© 2019 GEMS v2.0',
                    style: GemsChrome.body(size: 11, color: GemsChrome.textSoft),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _userRow(User user, VoidCallback onTap) {
    final parts = [user.userFirstName, user.userLastName]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    final name = parts.isEmpty ? user.username : parts.join(' ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(
          children: [
            _avatar(user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GemsChrome.body(size: 15, weight: FontWeight.w600),
                  ),
                  Text(
                    'View profile',
                    style: GemsChrome.body(size: 12, color: GemsChrome.textSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(User user) {
    final imageUrl = _imageUrl(user);
    final initial = (user.userFirstName.isNotEmpty
            ? user.userFirstName
            : user.username)
        .trim();
    final letter = initial.isEmpty ? '?' : initial[0].toUpperCase();

    return CircleAvatar(
      radius: 20,
      backgroundColor: GemsChrome.primarySoft,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      child: imageUrl == null
          ? Text(
              letter,
              style: GemsChrome.body(
                size: 14,
                weight: FontWeight.w600,
                color: GemsChrome.primary,
              ),
            )
          : null,
    );
  }

  String? _imageUrl(User user) {
    var imageUrl = user.imageUrl.trim();
    if (imageUrl.isEmpty) return null;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      imageUrl = 'https:$imageUrl';
    }
    if (!(Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false)) return null;
    return imageUrl;
  }

  Widget _navTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final color = active ? GemsChrome.text : GemsChrome.textSoft;
    return Material(
      color: active ? const Color(0x1F00ADA8) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: active ? GemsChrome.teal : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(17, 12, 20, 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GemsChrome.body(
                    size: 14,
                    weight: active ? FontWeight.w600 : FontWeight.w500,
                    color: GemsChrome.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
