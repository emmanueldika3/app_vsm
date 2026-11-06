import 'package:flutter/material.dart';

class VsmAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasUnreadNotifications;
  final VoidCallback? onRefresh;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLogoutPressed;

  const VsmAppBar({
    super.key,
    this.title = 'VÉTÉRANS SANTÉ MAHÈN (V.S.M)',
    this.hasUnreadNotifications = true,
    this.onRefresh,
    this.onNotificationPressed,
    this.onSettingsPressed,
    this.onLogoutPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF1E5235);
    const Color goldAccent = Color(0xFFD4AF37);

    return AppBar(
      elevation: 4,
      backgroundColor: greenPrimary,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          // Logo grand format forcé via Transform.scale et conteneur élargi
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Transform.scale(
                scale:
                    1.3, // Ajuste ce zoom si tu veux le grossir encore plus (ex: 1.4)
                child: Image.asset(
                  'assets/images/logo_vsm.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.sports_soccer,
                        size: 28,
                        color: greenPrimary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: goldAccent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'PK11',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Action Rafraîchir
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
          tooltip: 'Rafraîchir',
          onPressed: onRefresh,
        ),
        // Action Notifications
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Notifications',
              onPressed: onNotificationPressed,
            ),
            if (hasUnreadNotifications)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: greenPrimary, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        // Menu d'options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          color: const Color(0xFF0A1E13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: goldAccent, width: 0.5),
          ),
          onSelected: (value) {
            if (value == 'settings' && onSettingsPressed != null) {
              onSettingsPressed!();
            } else if (value == 'logout' && onLogoutPressed != null) {
              onLogoutPressed!();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Paramètres',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
