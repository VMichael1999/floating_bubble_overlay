<picture>
  <source media="(prefers-color-scheme: dark)" srcset="doc/banner_dark.png">
  <img src="doc/banner_light.png" width="100%" alt="Floating Bubble Overlay banner" />
</picture>

<h2 align="center">
  Floating Bubble Overlay
</h2>

<p align="center">
  <a href="https://pub.dev/packages/floating_bubble_overlay"><img src="https://img.shields.io/pub/v/floating_bubble_overlay?logo=dart&label=pub.dev&color=0175C2" alt="pub version"></a>
  <a href="https://pub.dev/packages/floating_bubble_overlay/score"><img src="https://img.shields.io/pub/points/floating_bubble_overlay?logo=dart&color=0175C2" alt="pub points"></a>
  <a href="https://pub.dev/packages/floating_bubble_overlay/score"><img src="https://img.shields.io/pub/likes/floating_bubble_overlay?logo=dart&color=0175C2" alt="pub likes"></a>
  <br>
  <a href="https://github.com/VMichael1999/floating_bubble_overlay/actions/workflows/ci.yml"><img src="https://github.com/VMichael1999/floating_bubble_overlay/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://codecov.io/gh/VMichael1999/floating_bubble_overlay"><img src="https://codecov.io/gh/VMichael1999/floating_bubble_overlay/branch/main/graph/badge.svg" alt="coverage"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/VMichael1999/floating_bubble_overlay?color=blue" alt="license: MIT"></a>
  <img src="https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white" alt="platform: Android">
  <img src="https://img.shields.io/badge/Flutter-%E2%89%A53.29-02569B?logo=flutter" alt="Flutter 3.29+">
</p>

<p align="center">
  <a href="README.md">English</a> · <b>Español</b>
</p>

---

## 💡 Descripción

**Floating Bubble Overlay** es un plugin de Flutter que muestra una burbuja flotante (chat head) encima de otras apps, como la de Facebook Messenger.
Está construido sobre [Floating-Bubble-View](https://github.com/TorryDo/Floating-Bubble-View).

- 👆 **Toca** la burbuja → trae tu app al frente (configurable con `openAppOnTap`)
- ✋ **Arrastra** la burbuja → muestra una zona "X" para cerrarla (`following` o `fixed`)
- 🖼 **Iconos desde tus `assets/` de Flutter** o drawables de Android (si no, usa el icono de tu app)
- 🎨 **Fondo opcional** detrás del icono: círculo, cuadrado o cuadrado redondeado, con color, imagen y borde
- ❌ **Botón de cierre personalizable**: imagen, tamaño, color y fondo
- 👁 **Ocultar / mostrar** la burbuja sin detener el servicio
- 🔔 **Eventos**: toque, presionar / soltar, mover y **cierre por el usuario**
- 🛎 **Notificación silenciosa** del servicio que abre tu app, con un botón **"Detener"** opcional
- ♻️ **Sobrevive a la muerte del proceso**: si Android cierra tu app, la burbuja vuelve sola

> **Nota:** solo se soporta **Android** (API 21+). En iOS / web / escritorio todos los métodos devuelven `false`.

<br>

<p align="center">
<img src="doc/demo_v1.1.0.gif" width="30%" alt="Floating Bubble Overlay Demo" />
</p>

---

## 🔧 Instalación

```yaml
dependencies:
  floating_bubble_overlay: ^1.1.0
```

El `minSdk` de Android debe ser **21** o superior.

El manifest del plugin ya declara todo lo necesario, así que **no** tienes que agregar nada a tu `AndroidManifest.xml`:

- `SYSTEM_ALERT_WINDOW`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE`
- el servicio en primer plano `BubbleService` (`foregroundServiceType="specialUse"`, con la propiedad de subtipo que exige Android 14+)

### Iconos

Puedes usar un **asset de Flutter** o un **drawable de Android**:

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/bubble.png
    - assets/close.png
```

```dart
const BubbleOptions(
  bubbleIconAsset: 'assets/bubble.png', // Flutter asset (recommended)
  closeIconAsset: 'assets/close.png',
)
```

Los drawables se indican por nombre, sin extensión, y van en tu **app** (`android/app/src/main/res/drawable/my_bubble.png` → `bubbleIcon: 'my_bubble'`).
Si un icono no se puede cargar, se usa el icono de la app (o un icono de cierre por defecto) y se registra un aviso en el log.

### Fondo (forma, color, imagen)

Por defecto el icono se dibuja tal cual, así que un PNG transparente muestra solo la figura.
Agrega un `BubbleBackground` para dibujarlo sobre una forma:

```dart
const BubbleOptions(
  bubbleIconAsset: 'assets/bubble.png',
  bubbleBackground: BubbleBackground(
    shape: BubbleShape.circle,          // circle, square, roundedSquare
    color: Color(0xFF0A66C2),           // fill color
    // imageAsset: 'assets/bg.png',     // or a background image (cropped to fill)
    padding: 6,                         // space around the icon (dp)
    borderColor: Color(0xFFFFFFFF),     // optional border
    borderWidth: 2,
  ),
  // closeIconBackground: BubbleBackground(...) works the same for the close icon.
)
```

| Opción | Descripción | Por defecto |
|---|---|---|
| `shape` | `BubbleShape.circle`, `square` o `roundedSquare` | `circle` |
| `color` | Color de relleno | ninguno |
| `imageAsset` | Asset de Flutter usado como fondo, recortado para cubrir la forma (encima de `color`) | ninguno |
| `padding` | Espacio entre el borde y el icono (dp) | `6` |
| `cornerRadius` | Radio de las esquinas para `roundedSquare` (dp) | `12` |
| `borderColor` / `borderWidth` | Borde (dp); no se dibuja si el color es `null` o el ancho es `0` | ninguno / `0` |

### Botón de cierre

La "X" que aparece al arrastrar también se puede personalizar: usa una imagen (`closeIconAsset` / `closeIcon`), cambia el color de la "X" por defecto con `closeIconColor` y/o dibújala sobre un `closeIconBackground`:

```dart
const BubbleOptions(
  closeIconColor: Color(0xFFFFFFFF),        // white "X"...
  closeIconBackground: BubbleBackground(    // ...on a red circle
    color: Color(0xFFD32F2F),
    padding: 4,
  ),
  closeIconSize: 56,
)
```

> El `icon` de la notificación debe ser un drawable. Android dibuja los iconos pequeños de notificación como una **silueta blanca**, así que usa un icono monocromo con transparencia.

---

## 💻 Uso

```dart
import 'package:floating_bubble_overlay/floating_bubble_overlay.dart';

final bubble = FloatingBubbleOverlay.instance;

// 1. Permissions
if (!await bubble.hasOverlayPermission()) {
  await bubble.requestOverlayPermission(); // opens the system settings screen
}
await bubble.requestPostNotificationsPermission(); // Android 13+

// 2. Start
final started = await bubble.startBubble(
  bubbleOptions: const BubbleOptions(
    bubbleIconAsset: 'assets/bubble.png',
    closeIconAsset: 'assets/close.png',
    bubbleSize: 60,
    closeIconSize: 56,
    closeBehavior: CloseBehavior.following,
  ),
  notificationOptions: const NotificationOptions(
    title: 'Bubble is running',
    body: 'Tap to open the app',
    showStopAction: true,
    stopActionLabel: 'Close bubble',
  ),
  onTap: () => print('tapped'),
  onMove: (x, y) => print('moved to $x, $y'),
  onClose: () => print('the user closed the bubble'),
);

// 3. Hide / show without stopping the service
await bubble.hideBubble();
await bubble.showBubble();

// 4. Stop
await bubble.stopBubble();
```

`startBubble` devuelve `false` si falta el permiso de superposición o si la burbuja ya está activa (en ese caso se conservan los callbacks de la burbuja activa).

### Receta: mostrar la burbuja solo cuando tu app está en segundo plano

```dart
class _MyState extends State<MyPage> with WidgetsBindingObserver {
  final bubble = FloatingBubbleOverlay.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bubble.hideBubble(); // the app may be cold-started by tapping the bubble
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      bubble.isRunning().then((running) =>
          running ? bubble.showBubble() : bubble.startBubble(/* ... */));
    }
    if (state == AppLifecycleState.resumed) bubble.hideBubble();
  }
}
```

La [app de ejemplo](example/lib/main.dart) implementa este patrón.

---

## 📡 Eventos

| Callback | Cuándo |
|---|---|
| `onTap` | Se toca la burbuja |
| `onTapDown(x, y)` / `onTapUp(x, y)` | Se presiona / suelta la burbuja (coordenadas en dp) |
| `onMove(x, y)` | Se arrastra la burbuja |
| `onClose` | El **usuario** cierra la burbuja: arrastrándola a la "X" o con el botón de la notificación. No se llama con `stopBubble()` |

Los callbacks llegan mientras tu app de Flutter está viva. Si la burbuja sobrevive a la app (`keepAliveWhenAppExit: true`), los eventos que ocurren después de cerrar la app se pierden.

## 🧭 API

| Método | Descripción |
|---|---|
| `requestOverlayPermission()` / `hasOverlayPermission()` | Permiso "Mostrar sobre otras apps" |
| `requestPostNotificationsPermission()` / `hasPostNotificationsPermission()` | Permiso de notificaciones (Android 13+) |
| `startBubble(...)` / `stopBubble()` | Iniciar / detener el servicio de la burbuja |
| `hideBubble()` / `showBubble()` | Ocultar / mostrar la burbuja, conservando el servicio y sus callbacks |
| `isRunning()` | Si el servicio está activo (visible u oculto) |
| `isBubbleVisible()` | Si la burbuja está activa **y** visible |

## 🎨 BubbleOptions

| Opción | Descripción | Por defecto |
|-------|-------------|---------|
| `bubbleIconAsset` | Asset de Flutter usado como icono de la burbuja | `null` |
| `bubbleIcon` | Nombre del drawable del icono (si no hay asset) | icono de la app |
| `closeIconAsset` | Asset de Flutter usado como icono de cierre | `null` |
| `closeIcon` | Nombre del drawable del icono de cierre (si no hay asset) | icono de cierre del sistema |
| `bubbleSize` | Ancho y alto de la burbuja (dp), debe ser `> 0` | `60` |
| `closeIconSize` | Ancho y alto del icono de cierre (dp) | `bubbleSize` |
| `bubbleBackground` / `closeIconBackground` | [Fondo](#fondo-forma-color-imagen) opcional detrás del icono | ninguno |
| `closeIconColor` | Color para teñir el icono de cierre ([detalles](#botón-de-cierre)) | ninguno |
| `startLocationX` / `startLocationY` | Posición inicial (dp) | `0` / `200` |
| `opacity` | Transparencia, `0.0` → `1.0` | `1.0` |
| `enableClose` | Mostrar la "X" de cierre al arrastrar | `true` |
| `closeBehavior` | `CloseBehavior.following` (la X sigue a la burbuja) o `CloseBehavior.fixed` (la X fija abajo) | `following` |
| `distanceToClose` | Distancia (dp) a la que la burbuja se engancha a la "X" | `100` |
| `enableAnimateToEdge` | Llevar la burbuja al borde de la pantalla al soltarla | `true` |
| `enableBottomShadow` | Degradado detrás del botón de cierre | `true` |
| `keepAliveWhenAppExit` | Mantener la burbuja al quitar la app de recientes | `false` |
| `openAppOnTap` | Traer la app al frente al tocar la burbuja | `true` |

## 🔔 NotificationOptions

| Opción | Descripción | Por defecto |
|---|---|---|
| `id` | Id de la notificación | `101` |
| `title` / `body` | Textos de la notificación | nombre de la app / ninguno |
| `icon` | Nombre del drawable del icono pequeño | icono de la app |
| `channelId` / `channelName` | Canal de notificación | `bubble_notification` / `Bubble Notification` |
| `showStopAction` | Mostrar un botón que cierra la burbuja (dispara `onClose`) | `false` |
| `stopActionLabel` | Texto de ese botón | `Stop` |

Tocar la notificación abre tu app. El canal se crea con **importancia baja** (sin sonido ni ventana emergente).
Android no permite cambiar la importancia de un canal ya existente: si una versión anterior de tu app ya creó el canal, usa un `channelId` nuevo.

---

## 🏪 Publicar en Google Play

El plugin usa dos capacidades que Google Play revisa:

1. **`SYSTEM_ALERT_WINDOW`** ("mostrar sobre otras apps"): explica en la ficha de la tienda o dentro de la app por qué tu app muestra una burbuja, y pide el permiso solo cuando el usuario active la función.
2. **Servicio en primer plano de tipo `specialUse`** (Android 14+): en Play Console → *Contenido de la app* → *Permisos de servicios en primer plano*, declara el uso especial y describe la función de la burbuja (un video corto ayuda en la revisión).

---

## ❓ Solución de problemas

- **`startBubble` devuelve `false`** → no se concedió el permiso de superposición, o la burbuja ya está activa (revisa `isRunning()`).
- **Sale el icono de la app** → el asset no está declarado en `pubspec.yaml` o el nombre del drawable es incorrecto; busca avisos `FLOATING_BUBBLE_OVERLAY` en logcat.
- **La notificación suena** → el canal lo creó una versión anterior; cambia el `channelId`.
- **No llegan callbacks al reabrir la app** → los callbacks pertenecen a la app de Flutter que llamó a `startBubble`; vuelve a llamarlo o mantén la app viva.

---

## 📱 Compatibilidad

| Plataforma | Soporte |
|---------|---------|
| Android 5.0+ (API 21+) | ✔ — probado en un emulador con API 37 y páginas de 16 KB (Pixel 10 Pro XL) |
| iOS / Web / Escritorio | ❌ los métodos devuelven `false` |

---

## 🧑‍💻 Autor

Desarrollado y mantenido por **Michael Anthony Valdiviezo Maza**.
Licencia MIT. Construido sobre [Floating-Bubble-View](https://github.com/TorryDo/Floating-Bubble-View) de TorryDo.
