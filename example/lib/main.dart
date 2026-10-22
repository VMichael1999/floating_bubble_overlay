import 'dart:developer';
import 'package:flutter/material.dart';
import 'snackbars.dart';
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0A66C2);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Floating Bubble Panel',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          background: const Color(0xFFF2F4F8),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF0A66C2),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0A66C2)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: Colors.black12,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Prevent repeated start/stop calls.
  bool _autoRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app goes background -> start bubble.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _startBubbleIfPossible(auto: true);
    }

    // When app returns foreground -> stop bubble.
    if (state == AppLifecycleState.resumed) {
      _stopBubbleIfPossible(auto: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Floating Bubble Panel'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.bubble_chart_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Floating Bubble Overlay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage permissions and service status.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // Grid profesional
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final crossAxisCount = c.maxWidth >= 520 ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.6,
                      children: [
                        _ActionTile(
                          icon: Icons.layers_rounded,
                          title: 'Overlay\nPermission',
                          onTap: () => _requestOverlayPermission(context),
                        ),
                        _ActionTile(
                          icon: Icons.verified_user_rounded,
                          title: 'Has\nPermission?',
                          onTap: () => _hasOverlayPermission(context),
                          secondary: true,
                        ),
                        _ActionTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Notification\nPermission',
                          onTap:
                              () =>
                                  _requestPostNotificationsPermission(context),
                        ),
                        _ActionTile(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications\nEnabled?',
                          onTap: () => _hasPostNotificationsPermission(context),
                          secondary: true,
                        ),
                        _ActionTile(
                          icon: Icons.play_circle_fill_rounded,
                          title: 'Is Bubble\nActive?',
                          onTap: () => _isRunning(context),
                          secondary: true,
                        ),
                        _ActionTile(
                          icon: Icons.play_arrow_rounded,
                          title: 'Start\nBubble',
                          onTap: () {
                            _startBubble(
                              context,
                              bubbleOptions: BubbleOptions(
                                bubbleIcon: null,
                                startLocationX: 0,
                                startLocationY: 100,
                                bubbleSize: 60,
                                opacity: 1,
                                enableClose: true,
                                closeBehavior: CloseBehavior.following,
                                distanceToClose: 100,
                                enableAnimateToEdge: true,
                                enableBottomShadow: true,
                                keepAliveWhenAppExit: false,
                              ),
                              notificationOptions: NotificationOptions(
                                id: 1,
                                title: 'Floating Bubble Panel',
                                body: 'Floating bubble service is active',
                                channelId:
                                    'floating_bubble_overlay_notification',
                                channelName: 'Floating Bubble Notification',
                              ),
                              onTap:
                                  () => _logMessage(
                                    context: context,
                                    message: 'Bubble tapped',
                                  ),
                              onTapDown:
                                  (x, y) => _logMessage(
                                    context: context,
                                    message:
                                        'Bubble pressed at: ${_getRoundedCoordinatesAsString(x, y)}',
                                  ),
                              onTapUp:
                                  (x, y) => _logMessage(
                                    context: context,
                                    message:
                                        'Bubble released at: ${_getRoundedCoordinatesAsString(x, y)}',
                                  ),
                              onMove:
                                  (x, y) => _logMessage(
                                    context: context,
                                    message:
                                        'Bubble moved to: ${_getRoundedCoordinatesAsString(x, y)}',
                                  ),
                            );
                          },
                        ),
                        _ActionTile(
                          icon: Icons.stop_circle_rounded,
                          title: 'Stop\nBubble',
                          onTap: () => _stopBubble(context),
                          danger: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runMethod(
    BuildContext context,
    Future<void> Function() method,
  ) async {
    try {
      await method();
    } catch (error) {
      log(name: 'Floating Bubble Overlay Playground', error.toString());

      SnackBars.show(
        context: context,
        status: SnackBarStatus.error,
        message: 'Error: ${error.runtimeType}',
      );
    }
  }

  Future<void> _requestOverlayPermission(BuildContext context) async {
    await _runMethod(context, () async {
      final isGranted =
          await FloatingBubbleOverlay.instance.requestOverlayPermission();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message:
            isGranted
                ? 'Overlay permission granted'
                : 'Overlay permission not granted',
      );
    });
  }

  Future<void> _hasOverlayPermission(BuildContext context) async {
    await _runMethod(context, () async {
      final hasPermission =
          await FloatingBubbleOverlay.instance.hasOverlayPermission();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message:
            hasPermission
                ? 'Overlay permission granted'
                : 'Overlay permission not granted',
      );
    });
  }

  Future<void> _requestPostNotificationsPermission(BuildContext context) async {
    await _runMethod(context, () async {
      final isGranted =
          await FloatingBubbleOverlay.instance
              .requestPostNotificationsPermission();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message:
            isGranted
                ? 'Notification permission granted'
                : 'Notification permission not granted',
      );
    });
  }

  Future<void> _hasPostNotificationsPermission(BuildContext context) async {
    await _runMethod(context, () async {
      final hasPermission =
          await FloatingBubbleOverlay.instance.hasPostNotificationsPermission();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message:
            hasPermission
                ? 'Notification permission granted'
                : 'Notification permission not granted',
      );
    });
  }

  Future<void> _isRunning(BuildContext context) async {
    await _runMethod(context, () async {
      final isRunning = await FloatingBubbleOverlay.instance.isRunning();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message: isRunning ? 'Bubble is active' : 'Bubble is not active',
      );
    });
  }

  // Auto-start helper: checks permission and avoids duplicates.
  Future<void> _startBubbleIfPossible({bool auto = false}) async {
    if (_autoRunning) return;

    final hasPermission =
        await FloatingBubbleOverlay.instance.hasOverlayPermission();
    if (!hasPermission) {
      if (auto && mounted) {
        _logMessage(
          context: context,
          message: 'Overlay permission is not granted',
        );
      }
      return;
    }

    _autoRunning = true;
    await _startBubble(
      context,
      bubbleOptions: BubbleOptions(
        bubbleIcon: null,
        startLocationX: 0,
        startLocationY: 100,
        bubbleSize: 60,
        opacity: 1,
        enableClose: true,
        closeBehavior: CloseBehavior.following,
        distanceToClose: 100,
        enableAnimateToEdge: true,
        enableBottomShadow: true,
        keepAliveWhenAppExit: false,
      ),
      notificationOptions: NotificationOptions(
        id: 1,
        title: 'Floating Bubble Panel',
        body: 'Floating bubble service is active',
        channelId: 'floating_bubble_overlay_notification',
        channelName: 'Floating Bubble Notification',
      ),
    );
  }

  // Auto-stop helper.
  Future<void> _stopBubbleIfPossible({bool auto = false}) async {
    if (!_autoRunning) {
      // Even if we think it's stopped, ensure native service is stopped.
      await FloatingBubbleOverlay.instance.stopBubble();
      return;
    }
    _autoRunning = false;
    await _stopBubble(context);
  }

  Future<void> _startBubble(
    BuildContext context, {
    BubbleOptions? bubbleOptions,
    NotificationOptions? notificationOptions,
    VoidCallback? onTap,
    Function(double x, double y)? onTapDown,
    Function(double x, double y)? onTapUp,
    Function(double x, double y)? onMove,
  }) async {
    await _runMethod(context, () async {
      final hasStarted = await FloatingBubbleOverlay.instance.startBubble(
        bubbleOptions: bubbleOptions,
        notificationOptions: notificationOptions,
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onMove: onMove,
      );

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message: hasStarted ? 'Bubble started' : 'Bubble did not start',
      );
    });
  }

  Future<void> _stopBubble(BuildContext context) async {
    await _runMethod(context, () async {
      final hasStopped = await FloatingBubbleOverlay.instance.stopBubble();

      SnackBars.show(
        context: context,
        status: SnackBarStatus.success,
        message: hasStopped ? 'Bubble stopped' : 'Bubble did not stop',
      );
    });
  }

  void _logMessage({required BuildContext context, required String message}) {
    log(name: 'FloatingBubbleOverlayPlayground', message);

    SnackBars.show(
      context: context,
      status: SnackBarStatus.success,
      message: message,
    );
  }

  String _getRoundedCoordinatesAsString(double x, double y) {
    return '${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool secondary;
  final bool danger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.secondary = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg =
        danger
            ? const Color(0xFFFFE8E8)
            : secondary
            ? Colors.white
            : primary;

    final fg =
        danger
            ? const Color(0xFFB3261E)
            : secondary
            ? primary
            : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      elevation: secondary ? 1 : 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: fg.withOpacity(secondary ? 0.12 : 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: fg, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
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
