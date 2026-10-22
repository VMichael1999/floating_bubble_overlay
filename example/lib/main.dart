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
  final _bubble = FloatingBubbleOverlay.instance;

  /// Whether the bubble uses the Flutter asset icon or the app icon.
  bool _useAssetIcon = true;

  /// Shape of the background behind the icon (null: no background).
  BubbleShape? _shape;

  /// Index in [_fills] of the background fill.
  int _fill = 0;

  static const _shapeNames = {
    null: 'None',
    BubbleShape.circle: 'Circle',
    BubbleShape.roundedSquare: 'Rounded',
    BubbleShape.square: 'Square',
  };

  static const _fills = [
    (name: 'White', color: Color(0xFFFFFFFF), image: null),
    (name: 'Blue', color: Color(0xFF0A66C2), image: null),
    (name: 'Yellow', color: Color(0xFFFFCA28), image: null),
    (name: 'Image', color: null, image: 'assets/bubble_bg.png'),
  ];

  BubbleBackground? get _background {
    final shape = _shape;
    if (shape == null) return null;
    final fill = _fills[_fill];
    return BubbleBackground(
      shape: shape,
      color: fill.color,
      imageAsset: fill.image,
      padding: 6,
      cornerRadius: 14,
      borderColor:
          fill.name == 'White' ? const Color(0xFF0A66C2) : Colors.white,
      borderWidth: 2,
    );
  }

  BubbleOptions get _bubbleOptions => BubbleOptions(
    // A Flutter asset declared in pubspec.yaml (new in 1.1.0). When it is
    // null, the bubble falls back to the app icon.
    bubbleIconAsset: _useAssetIcon ? 'assets/bubble.png' : null,
    // Optional background behind the icon (new in 1.1.0).
    bubbleBackground: _background,
    closeIconAsset: 'assets/close.png',
    closeIconSize: 56,
    startLocationX: 0,
    startLocationY: 100,
    bubbleSize: 60,
    closeBehavior: CloseBehavior.following,
  );

  static const _notificationOptions = NotificationOptions(
    id: 1,
    title: 'Floating Bubble Panel',
    body: 'Tap to open the app',
    channelId: 'floating_bubble_overlay_example',
    channelName: 'Floating Bubble',
    showStopAction: true,
    stopActionLabel: 'Close bubble',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The app can be cold-started by tapping the bubble (e.g. after Android
    // restored it), and no `resumed` event is sent then: hide it here too.
    _bubble.hideBubble();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App goes to background -> show the bubble (start it the first time).
    if (state == AppLifecycleState.paused) _showOrStartBubble();

    // App comes back -> hide the bubble but keep the service and its callbacks.
    if (state == AppLifecycleState.resumed) _bubble.hideBubble();
  }

  Future<void> _showOrStartBubble() async {
    if (!await _bubble.hasOverlayPermission()) return;
    if (await _bubble.isRunning()) {
      await _bubble.showBubble();
    } else if (mounted) {
      await _startBubble(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _ActionTile(
        icon: Icons.layers_rounded,
        title: 'Overlay\nPermission',
        onTap:
            () => _run(
              context,
              _bubble.requestOverlayPermission,
              (ok) =>
                  ok
                      ? 'Overlay permission granted'
                      : 'Overlay permission not granted',
            ),
      ),
      _ActionTile(
        icon: Icons.verified_user_rounded,
        title: 'Has\nPermission?',
        secondary: true,
        onTap:
            () => _run(
              context,
              _bubble.hasOverlayPermission,
              (ok) =>
                  ok
                      ? 'Overlay permission granted'
                      : 'Overlay permission not granted',
            ),
      ),
      _ActionTile(
        icon: Icons.notifications_active_rounded,
        title: 'Notification\nPermission',
        onTap:
            () => _run(
              context,
              _bubble.requestPostNotificationsPermission,
              (ok) =>
                  ok
                      ? 'Notification permission granted'
                      : 'Notification permission not granted',
            ),
      ),
      _ActionTile(
        icon: Icons.notifications_rounded,
        title: 'Notifications\nEnabled?',
        secondary: true,
        onTap:
            () => _run(
              context,
              _bubble.hasPostNotificationsPermission,
              (ok) =>
                  ok
                      ? 'Notification permission granted'
                      : 'Notification permission not granted',
            ),
      ),
      _ActionTile(
        icon: Icons.play_circle_fill_rounded,
        title: 'Is Bubble\nActive?',
        secondary: true,
        onTap: () async {
          final running = await _bubble.isRunning();
          final visible = await _bubble.isBubbleVisible();
          if (!context.mounted) return;
          _logMessage(
            context: context,
            message:
                running
                    ? 'Bubble is active (${visible ? 'visible' : 'hidden'})'
                    : 'Bubble is not active',
          );
        },
      ),
      _ActionTile(
        icon: Icons.apps_rounded,
        title: 'Use App\nIcon',
        secondary: true,
        selected: !_useAssetIcon,
        onTap: () => _selectIcon(context, useAsset: false),
      ),
      _ActionTile(
        icon: Icons.image_rounded,
        title: 'Use Asset\nIcon',
        secondary: true,
        selected: _useAssetIcon,
        onTap: () => _selectIcon(context, useAsset: true),
      ),
      _ActionTile(
        icon: Icons.crop_square_rounded,
        title: 'Shape:\n${_shapeNames[_shape]}',
        secondary: true,
        onTap: () {
          final shapes = _shapeNames.keys.toList();
          setState(
            () => _shape = shapes[(shapes.indexOf(_shape) + 1) % shapes.length],
          );
          _applyChange(context, 'shape: ${_shapeNames[_shape]}');
        },
      ),
      _ActionTile(
        icon: Icons.format_color_fill_rounded,
        title: 'Fill:\n${_fills[_fill].name}',
        secondary: true,
        onTap: () {
          setState(() => _fill = (_fill + 1) % _fills.length);
          _applyChange(
            context,
            _shape == null
                ? 'fill: ${_fills[_fill].name} (pick a shape to see it)'
                : 'fill: ${_fills[_fill].name}',
          );
        },
      ),
      _ActionTile(
        icon: Icons.play_arrow_rounded,
        title: 'Start\nBubble',
        onTap: () => _startBubble(context),
      ),
      _ActionTile(
        icon: Icons.visibility_off_rounded,
        title: 'Hide\nBubble',
        secondary: true,
        onTap:
            () => _run(
              context,
              _bubble.hideBubble,
              (ok) => ok ? 'Bubble hidden' : 'Bubble is not visible',
            ),
      ),
      _ActionTile(
        icon: Icons.visibility_rounded,
        title: 'Show\nBubble',
        secondary: true,
        onTap:
            () => _run(
              context,
              _bubble.showBubble,
              (ok) => ok ? 'Bubble shown' : 'Bubble is not hidden',
            ),
      ),
      _ActionTile(
        icon: Icons.stop_circle_rounded,
        title: 'Stop\nBubble',
        danger: true,
        onTap:
            () => _run(
              context,
              _bubble.stopBubble,
              (ok) => ok ? 'Bubble stopped' : 'Bubble did not stop',
            ),
      ),
    ];

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
              const _Header(),
              const SizedBox(height: 16),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return GridView.count(
                      crossAxisCount: c.maxWidth >= 520 ? 3 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.6,
                      children: tiles,
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

  /// Runs a plugin call and shows its result (or error) in a snackbar.
  Future<void> _run(
    BuildContext context,
    Future<bool> Function() method,
    String Function(bool result) describe,
  ) async {
    try {
      final result = await method();
      if (!context.mounted) return;
      _logMessage(context: context, message: describe(result));
    } catch (error) {
      log(name: 'Floating Bubble Overlay Playground', error.toString());
      if (!context.mounted) return;
      SnackBars.show(
        context: context,
        status: SnackBarStatus.error,
        message: 'Error: ${error.runtimeType}',
      );
    }
  }

  /// Switches between the app icon and the asset icon. A running bubble is
  /// restarted so the new icon is applied right away.
  Future<void> _selectIcon(
    BuildContext context, {
    required bool useAsset,
  }) async {
    if (_useAssetIcon == useAsset) return;
    setState(() => _useAssetIcon = useAsset);
    await _applyChange(context, useAsset ? 'the asset icon' : 'the app icon');
  }

  /// Restarts a running bubble so a new option ([change]) is applied right
  /// away; otherwise it is used by the next start.
  Future<void> _applyChange(BuildContext context, String change) async {
    if (!await _bubble.isRunning()) {
      if (!context.mounted) return;
      _logMessage(context: context, message: 'Next bubble will use $change');
      return;
    }

    await _bubble.stopBubble();
    // The service stops asynchronously: wait until it is gone.
    for (var i = 0; i < 20 && await _bubble.isRunning(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (!context.mounted) return;
    await _startBubble(context);
    if (!context.mounted) return;
    _logMessage(context: context, message: 'Bubble restarted with $change');
  }

  Future<void> _startBubble(BuildContext context) {
    return _run(
      context,
      () => _bubble.startBubble(
        bubbleOptions: _bubbleOptions,
        notificationOptions: _notificationOptions,
        onTap: () => _logMessage(context: context, message: 'Bubble tapped'),
        onTapDown:
            (x, y) => log(
              name: 'FloatingBubbleOverlayPlayground',
              'Bubble pressed at: ${_format(x, y)}',
            ),
        onTapUp:
            (x, y) => _logMessage(
              context: context,
              message: 'Bubble released at: ${_format(x, y)}',
            ),
        onMove:
            (x, y) => log(
              name: 'FloatingBubbleOverlayPlayground',
              'Bubble moved to: ${_format(x, y)}',
            ),
        onClose:
            () => _logMessage(
              context: context,
              message: 'Bubble closed by the user',
            ),
      ),
      (ok) => ok ? 'Bubble started' : 'Bubble did not start',
    );
  }

  void _logMessage({required BuildContext context, required String message}) {
    log(name: 'FloatingBubbleOverlayPlayground', message);
    if (!context.mounted) return;

    SnackBars.show(
      context: context,
      status: SnackBarStatus.success,
      message: message,
    );
  }

  String _format(double x, double y) {
    return '${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}';
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.bubble_chart_rounded, color: primary, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floating Bubble Overlay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'The bubble shows when you leave the app and hides when you come back.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool secondary;
  final bool danger;

  /// Highlights the tile as the current choice.
  final bool selected;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.secondary = false,
    this.danger = false,
    this.selected = false,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: selected ? BorderSide(color: primary, width: 2) : BorderSide.none,
      ),
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
                  color: fg.withValues(alpha: secondary ? 0.12 : 0.18),
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
              if (selected)
                Icon(Icons.check_circle_rounded, color: primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
