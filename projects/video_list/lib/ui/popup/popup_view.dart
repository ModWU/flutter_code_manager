import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:video_list/resources/res/dimens.dart';

const Duration _kMenuDuration = Duration(milliseconds: 300);
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuHorizontalPadding = 16.0;
const double _kMenuDividerHeight = 16.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 8.0;
const double _kMenuWidthStep = 56.0;
const EdgeInsets _kMenuScreenPadding =
    EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);

typedef PopupViewOuterBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    RenderBox targetBox);

typedef PopupViewItemBuilder<T> = List<PopupViewEntry<T>> Function(
    BuildContext context);

typedef PopupAnimationBuilder = Animation<double> Function(
    Animation<double> parent);

typedef PopupViewItemSelected<T> = void Function(T value);

/// Signature for the callback invoked when a [PopupMenuButton] is dismissed
/// without selecting an item.
///
/// Used by [PopupMenuButton.onCanceled].
typedef PopupViewCanceled = void Function();

enum PopupDirection {
  top,
  bottom,
  //left,
  //right,
}

abstract class PopupViewEntry<T> extends StatefulWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PopupViewEntry({Key key}) : super(key: key);

  /// The amount of vertical space occupied by this entry.
  ///
  /// This value is used at the time the [showMenu] method is called, if the
  /// `initialValue` argument is provided, to determine the position of this
  /// entry when aligning the selected entry over the given `position`. It is
  /// otherwise ignored.
  double get height;

  /// Whether this entry represents a particular value.
  ///
  /// This method is used by [showMenu], when it is called, to align the entry
  /// representing the `initialValue`, if any, to the given `position`, and then
  /// later is called on each entry to determine if it should be highlighted (if
  /// the method returns true, the entry will have its background color set to
  /// the ambient [ThemeData.highlightColor]). If `initialValue` is null, then
  /// this method is not called.
  ///
  /// If the [PopupMenuEntry] represents a single value, this should return true
  /// if the argument matches that value. If it represents multiple values, it
  /// should return true if the argument matches any of them.
  bool represents(T value);
}

/// A horizontal divider in a material design popup menu.
///
/// This widget adapts the [Divider] for use in popup menus.
///
/// See also:
///
///  * [PopupMenuItem], for the kinds of items that this widget divides.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class PopupViewDivider extends PopupMenuEntry<Never> {
  /// Creates a horizontal divider for a popup menu.
  ///
  /// By default, the divider has a height of 16 logical pixels.
  const PopupViewDivider({Key key, this.height = _kMenuDividerHeight})
      : super(key: key);

  /// The height of the divider entry.
  ///
  /// Defaults to 16 pixels.
  @override
  final double height;

  @override
  bool represents(void value) => false;

  @override
  _PopupViewDividerState createState() => _PopupViewDividerState();
}

class _PopupViewDividerState extends State<PopupMenuDivider> {
  @override
  Widget build(BuildContext context) => Divider(height: widget.height);
}

class CheckedPopupViewItem<T> extends PopupViewItem<T> {
  /// Creates a popup menu item with a checkmark.
  ///
  /// By default, the menu item is [enabled] but unchecked. To mark the item as
  /// checked, set [checked] to true.
  ///
  /// The `checked` and `enabled` arguments must not be null.
  const CheckedPopupViewItem({
    Key key,
    T value,
    this.checked = false,
    bool enabled = true,
    Widget child,
  })  : assert(checked != null),
        super(
          key: key,
          value: value,
          enabled: enabled,
          child: child,
        );

  /// Whether to display a checkmark next to the menu item.
  ///
  /// Defaults to false.
  ///
  /// When true, an [Icons.done] checkmark is displayed.
  ///
  /// When this popup menu item is selected, the checkmark will fade in or out
  /// as appropriate to represent the implied new state.
  final bool checked;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text]. An appropriate [DefaultTextStyle] is put in scope for
  /// the child. The text should be short enough that it won't wrap.
  ///
  /// This widget is placed in the [ListTile.title] slot of a [ListTile] whose
  /// [ListTile.leading] slot is an [Icons.done] icon.
  @override
  Widget get child => super.child;

  @override
  _CheckedPopupViewItemState<T> createState() =>
      _CheckedPopupViewItemState<T>();
}

class _CheckedPopupViewItemState<T>
    extends PopupViewItemState<T, CheckedPopupViewItem<T>>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeDuration = Duration(milliseconds: 150);
  AnimationController _controller;
  Animation<double> get _opacity => _controller.view;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _fadeDuration, vsync: this)
      ..value = widget.checked ? 1.0 : 0.0
      ..addListener(() => setState(() {/* animation changed */}));
  }

  @override
  void handleTap() {
    // This fades the checkmark in or out when tapped.
    if (widget.checked)
      _controller.reverse();
    else
      _controller.forward();
    super.handleTap();
  }

  @override
  Widget buildChild() {
    return ListTile(
      enabled: widget.enabled,
      leading: FadeTransition(
        opacity: _opacity,
        child: Icon(_controller.isDismissed ? null : Icons.done),
      ),
      title: widget.child,
    );
  }
}

class PopupMenuView<T> extends StatefulWidget {
  /// Creates a button that shows a popup menu.
  ///
  /// The [itemBuilder] argument must not be null.
  const PopupMenuView({
    Key key,
    this.barrierColor,
    this.barrierDismissible = true,
    this.popupDirection = PopupDirection.bottom,
    this.width,
    this.itemBuilder,
    this.outerBuilder,
    this.transitionDuration = _kMenuDuration,
    this.reverseTransitionDuration = _kMenuDuration,
    this.popupAnimationBuilder,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.keepPopupPadding = true,
    this.tooltip,
    this.elevation,
    this.padding = const EdgeInsets.all(8.0),
    this.menuScreenPadding = _kMenuScreenPadding,
    this.coverTarget = false,
    this.child,
    this.icon,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.enableFeedback,
  })  : assert(barrierDismissible != null),
        assert(popupDirection != null),
        assert(menuScreenPadding != null),
        assert(transitionDuration != null),
        assert(reverseTransitionDuration != null),
        assert(coverTarget != null),
        assert(itemBuilder != null),
        assert(offset != null),
        assert(enabled != null),
        assert(keepPopupPadding != null),
        assert(!(child != null && icon != null),
            'You can only pass [child] or [icon], not both.'),
        super(key: key);

  /// Called when the button is pressed to create the items to show in the menu.
  final PopupViewItemBuilder<T> itemBuilder;

  /// The value of the menu item, if any, that should be highlighted when the menu opens.
  final T initialValue;

  /// Called when the user selects a value from the popup menu created by this button.
  ///
  /// If the popup menu is dismissed without selecting a value, [onCanceled] is
  /// called instead.
  final PopupViewItemSelected<T> onSelected;

  /// Called when the user dismisses the popup menu without selecting an item.
  ///
  /// If the user selects a value, [onSelected] is called instead.
  final PopupViewCanceled onCanceled;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String tooltip;

  /// The z-coordinate at which to place the menu when open. This controls the
  /// size of the shadow below the menu.
  ///
  /// Defaults to 8, the appropriate elevation for popup menus.
  final double elevation;

  /// Matches IconButton's 8 dps padding by default. In some cases, notably where
  /// this button appears as the trailing element of a list item, it's useful to be able
  /// to set the padding to zero.
  final EdgeInsetsGeometry padding;

  /// If provided, [child] is the widget used for this button
  /// and the button will utilize an [InkWell] for taps.
  final Widget child;

  /// If provided, the [icon] is used for this button
  /// and the button will behave like an [IconButton].
  final Widget icon;

  /// The offset applied to the Popup Menu Button.
  ///
  /// When not set, the Popup Menu Button will be positioned directly next to
  /// the button that was used to create it.
  final Offset offset;

  /// Whether this popup menu button is interactive.
  ///
  /// Must be non-null, defaults to `true`
  ///
  /// If `true` the button will respond to presses by displaying the menu.
  ///
  /// If `false`, the button is styled with the disabled color from the
  /// current [Theme] and will not respond to presses or show the popup
  /// menu and [onSelected], [onCanceled] and [itemBuilder] will not be called.
  ///
  /// This can be useful in situations where the app needs to show the button,
  /// but doesn't currently have anything to show in the menu.
  final bool enabled;

  /// If provided, the shape used for the menu.
  ///
  /// If this property is null, then [PopupMenuThemeData.shape] is used.
  /// If [PopupMenuThemeData.shape] is also null, then the default shape for
  /// [MaterialType.card] is used. This default shape is a rectangle with
  /// rounded edges of BorderRadius.circular(2.0).
  final ShapeBorder shape;

  /// If provided, the background color used for the menu.
  ///
  /// If this property is null, then [PopupMenuThemeData.color] is used.
  /// If [PopupMenuThemeData.color] is also null, then
  /// Theme.of(context).cardColor is used.
  final Color color;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  final bool barrierDismissible;

  final Color barrierColor;

  final double width;

  final EdgeInsets menuScreenPadding;

  final bool coverTarget;

  final PopupViewOuterBuilder outerBuilder;

  final bool keepPopupPadding;

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  final PopupAnimationBuilder popupAnimationBuilder;

  final PopupDirection popupDirection;

  @override
  PopupMenuViewState<T> createState() => PopupMenuViewState<T>();
}

/// The [State] for a [PopupMenuButton].
///
/// See [showButtonMenu] for a way to programmatically open the popup menu
/// of your button state.
class PopupMenuViewState<T> extends State<PopupMenuView<T>> {
  /// A method to show a popup menu with the items supplied to
  /// [PopupMenuButton.itemBuilder] at the position of your [PopupMenuButton].
  ///
  /// By default, it is called when the user taps the button and [PopupMenuButton.enabled]
  /// is set to `true`. Moreover, you can open the button by calling the method manually.
  ///
  /// You would access your [PopupMenuButtonState] using a [GlobalKey] and
  /// show the menu of the button with `globalKey.currentState.showButtonMenu`.
  void showViewMenu() {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay.context.findRenderObject() as RenderBox;
    //高多算了一个状态栏的高度：24
    final double statusBarHeight =
        MediaQueryData.fromWindow(window).padding.top;
    final Offset statusBarOffset = Offset(0, statusBarHeight);

    /*final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset - statusBarOffset, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(statusBarOffset) + widget.offset,
            ancestor: overlay),
      ),
      (Offset.zero & (overlay.size - statusBarOffset)),
    );*/
    final Rect buttonRect = Rect.fromPoints(
      button.localToGlobal(widget.offset - statusBarOffset, ancestor: overlay),
      button.localToGlobal(
          button.size.bottomRight(-statusBarOffset) + widget.offset,
          ancestor: overlay),
    );

    final Rect container = (Offset.zero & (overlay.size - statusBarOffset));
    final double left = buttonRect.left - container.left;
    final double top = buttonRect.top - container.top;

    final RelativeRect position = RelativeRect.fromLTRB(
      left,
      top,
      left + button.size.width,
      top + button.size.height,
    );

    //546.7
    print(
        "button=>size:${button.size} buttonRect=>${buttonRect.size} position: $position widget.padding:${widget.menuScreenPadding}");
    final List<PopupViewEntry<T>> items = widget.itemBuilder(context);
    // Only show the menu if there is something to show
    if (items.isNotEmpty) {
      showView<T>(
        context: context,
        elevation: widget.elevation ?? popupMenuTheme.elevation,
        popupDirection: widget.popupDirection,
        items: items,
        targetBox: button,
        keepPopupPadding: widget.keepPopupPadding,
        outerBuilder: widget.outerBuilder,
        transitionDuration: widget.transitionDuration,
        reverseTransitionDuration: widget.reverseTransitionDuration,
        popupAnimationBuilder: widget.popupAnimationBuilder,
        initialValue: widget.initialValue,
        position: position,
        menuScreenPadding: widget.menuScreenPadding,
        coverTarget: widget.coverTarget,
        barrierColor: widget.barrierColor,
        barrierDismissible: widget.barrierDismissible,
        width: widget.width,
        shape: widget.shape ?? popupMenuTheme.shape,
        color: widget.color ?? popupMenuTheme.color,
      ).then<void>((T newValue) {
        if (!mounted) return null;
        if (newValue == null) {
          if (widget.onCanceled != null) widget.onCanceled();
          return null;
        }
        if (widget.onSelected != null) widget.onSelected(newValue);
      });
    }
  }

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled;
      case NavigationMode.directional:
        return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool enableFeedback = widget.enableFeedback ??
        PopupMenuTheme.of(context).enableFeedback ??
        true;

    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null)
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: widget.enabled ? showViewMenu : null,
          canRequestFocus: _canRequestFocus,
          child: widget.child,
          enableFeedback: enableFeedback,
        ),
      );

    return IconButton(
      icon: widget.icon ?? Icon(Icons.adaptive.more),
      padding: widget.padding,
      tooltip:
          widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? showViewMenu : null,
      enableFeedback: enableFeedback,
    );
  }
}

class PopupViewItem<T> extends PopupViewEntry<T> {
  /// Creates an item for a popup menu.
  ///
  /// By default, the item is [enabled].
  ///
  /// The `enabled` and `height` arguments must not be null.
  const PopupViewItem({
    Key key,
    this.value,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
    this.textStyle,
    this.mouseCursor,
    this.child,
  })  : assert(enabled != null),
        assert(height != null),
        super(key: key);

  /// The value that will be returned by [showMenu] if this entry is selected.
  final T value;

  /// Whether the user is permitted to select this item.
  ///
  /// Defaults to true. If this is false, then the item will not react to
  /// touches.
  final bool enabled;

  /// The minimum height of the menu item.
  ///
  /// Defaults to [kMinInteractiveDimension] pixels.
  @override
  final double height;

  /// The text style of the popup menu item.
  ///
  /// If this property is null, then [PopupMenuThemeData.textStyle] is used.
  /// If [PopupMenuThemeData.textStyle] is also null, then [TextTheme.subtitle1]
  /// of [ThemeData.textTheme] is used.
  final TextStyle textStyle;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]:
  ///
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor mouseCursor;

  /// The widget below this widget in the tree.
  ///
  /// Typically a single-line [ListTile] (for menus with icons) or a [Text]. An
  /// appropriate [DefaultTextStyle] is put in scope for the child. In either
  /// case, the text should be short enough that it won't wrap.
  final Widget child;

  @override
  bool represents(T value) => value == this.value;

  @override
  PopupViewItemState<T, PopupViewItem<T>> createState() =>
      PopupViewItemState<T, PopupViewItem<T>>();
}

/// The [State] for [PopupMenuItem] subclasses.
///
/// By default this implements the basic styling and layout of Material Design
/// popup menu items.
///
/// The [buildChild] method can be overridden to adjust exactly what gets placed
/// in the menu. By default it returns [PopupMenuItem.child].
///
/// The [handleTap] method can be overridden to adjust exactly what happens when
/// the item is tapped. By default, it uses [Navigator.pop] to return the
/// [PopupMenuItem.value] from the menu route.
///
/// This class takes two type arguments. The second, `W`, is the exact type of
/// the [Widget] that is using this [State]. It must be a subclass of
/// [PopupMenuItem]. The first, `T`, must match the type argument of that widget
/// class, and is the type of values returned from this menu.
class PopupViewItemState<T, W extends PopupViewItem<T>> extends State<W> {
  /// The menu item contents.
  ///
  /// Used by the [build] method.
  ///
  /// By default, this returns [PopupMenuItem.child]. Override this to put
  /// something else in the menu entry.
  @protected
  Widget buildChild() => widget.child;

  /// The handler for when the user selects the menu item.
  ///
  /// Used by the [InkWell] inserted by the [build] method.
  ///
  /// By default, uses [Navigator.pop] to return the [PopupMenuItem.value] from
  /// the menu route.
  @protected
  void handleTap() {
    Navigator.pop<T>(context, widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    TextStyle style = widget.textStyle ??
        popupMenuTheme.textStyle ??
        theme.textTheme.subtitle1;

    if (!widget.enabled) style = style.copyWith(color: theme.disabledColor);

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        child: buildChild(),
      ),
    );

    if (!widget.enabled) {
      final bool isDark = theme.brightness == Brightness.dark;
      item = IconTheme.merge(
        data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
        child: item,
      );
    }
    final MouseCursor effectiveMouseCursor =
        MaterialStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!widget.enabled) MaterialState.disabled,
      },
    );

    return MergeSemantics(
        child: Semantics(
      enabled: widget.enabled,
      button: true,
      child: InkWell(
        onTap: widget.enabled ? handleTap : null,
        canRequestFocus: widget.enabled,
        mouseCursor: effectiveMouseCursor,
        child: item,
      ),
    ));
  }
}

Future<T> showView<T>({
  BuildContext context,
  RelativeRect position,
  List<PopupViewEntry<T>> items,
  PopupDirection popupDirection,
  PopupViewOuterBuilder outerBuilder,
  Duration transitionDuration = _kMenuDuration,
  Duration reverseTransitionDuration = _kMenuDuration,
  PopupAnimationBuilder popupAnimationBuilder,
  RenderBox targetBox,
  T initialValue,
  double elevation,
  EdgeInsets menuScreenPadding = _kMenuScreenPadding,
  bool coverTarget = false,
  String semanticLabel,
  ShapeBorder shape,
  Color barrierColor,
  bool barrierDismissible = true,
  bool keepPopupPadding = true,
  double width,
  Color color,
  bool useRootNavigator = false,
}) {
  assert(context != null);
  assert(popupDirection != null);
  assert(targetBox != null);
  assert(position != null);
  assert(useRootNavigator != null);
  assert(items != null && items.isNotEmpty);
  assert(transitionDuration != null);
  assert(reverseTransitionDuration != null);
  assert(menuScreenPadding != null);
  assert(coverTarget != null);
  assert(barrierDismissible != null);
  assert(keepPopupPadding != null);
  assert(debugCheckHasMaterialLocalizations(context));

  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      semanticLabel ??= MaterialLocalizations.of(context).popupMenuLabel;
  }

  final NavigatorState navigator =
      Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_PopupViewRoute<T>(
    position: position,
    items: items,
    popupDirection: popupDirection,
    targetBox: targetBox,
    outerBuilder: outerBuilder,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    popupAnimationBuilder: popupAnimationBuilder,
    initialValue: initialValue,
    elevation: elevation,
    semanticLabel: semanticLabel,
    barrierColor: barrierColor,
    menuScreenPadding: menuScreenPadding,
    coverTarget: coverTarget,
    barrierDismissible: barrierDismissible,
    width: width,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    keepPopupPadding: keepPopupPadding,
    shape: shape,
    color: color,
    capturedThemes:
        InheritedTheme.capture(from: context, to: navigator.context),
  ));
}

class _PopupViewRoute<T> extends PopupRoute<T> {
  _PopupViewRoute({
    this.position,
    this.items,
    this.outerBuilder,
    this.popupDirection = PopupDirection.bottom,
    Duration transitionDuration = _kMenuDuration,
    Duration reverseTransitionDuration = _kMenuDuration,
    this.popupAnimationBuilder,
    this.targetBox,
    this.width,
    this.initialValue,
    this.elevation,
    this.barrierLabel,
    this.menuScreenPadding = _kMenuScreenPadding,
    this.keepPopupPadding = true,
    this.coverTarget = false,
    Color barrierColor,
    bool barrierDismissible = true,
    this.semanticLabel,
    this.shape,
    this.color,
    this.capturedThemes,
  })  : assert(barrierDismissible != null),
        assert(popupDirection != null),
        assert(menuScreenPadding != null),
        assert(coverTarget != null),
        assert(transitionDuration != null),
        assert(reverseTransitionDuration != null),
        assert(keepPopupPadding != null),
        assert(targetBox != null),
        _transitionDuration = transitionDuration,
        _reverseTransitionDuration = reverseTransitionDuration,
        _barrierDismissible = barrierDismissible,
        _barrierColor = barrierColor,
        itemSizes = List<Size>.filled(items.length, null);

  final RelativeRect position;
  final List<PopupViewEntry<T>> items;
  final List<Size> itemSizes;
  final T initialValue;
  final double elevation;
  final String semanticLabel;
  final ShapeBorder shape;
  final Color color;
  final CapturedThemes capturedThemes;
  final double width;
  final EdgeInsets menuScreenPadding;
  final PopupViewOuterBuilder outerBuilder;
  final RenderBox targetBox;
  final bool keepPopupPadding;
  final Duration _transitionDuration;
  final Duration _reverseTransitionDuration;
  final PopupDirection popupDirection;

  @override
  Animation<double> createAnimation() {
    final Animation<double> parent = super.createAnimation();
    return popupAnimationBuilder?.call(parent) ??
        CurvedAnimation(
          parent: parent,
          curve: Curves.linear,
          reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd),
        );
  }

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => _barrierColor;

  @override
  final String barrierLabel;

  final Color _barrierColor;

  final bool _barrierDismissible;

  final bool coverTarget;

  final PopupAnimationBuilder popupAnimationBuilder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    int selectedItemIndex;
    if (initialValue != null) {
      for (int index = 0;
          selectedItemIndex == null && index < items.length;
          index += 1) {
        if (items[index].represents(initialValue)) selectedItemIndex = index;
      }
    }

    final Widget menu = _PopupMenu<T>(
        route: this,
        width: width,
        keepPopupPadding: keepPopupPadding,
        targetBox: targetBox,
        outerBuilder: outerBuilder,
        semanticLabel: semanticLabel);

    final Widget themeChild = capturedThemes.wrap(menu);

    return SafeArea(
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              position,
              itemSizes,
              selectedItemIndex,
              Directionality.of(context),
              menuScreenPadding: menuScreenPadding,
              popupDirection: popupDirection,
              coverTarget: coverTarget,
            ),
            child: themeChild,
          );
        },
      ),
    );
  }
}

class _RenderMenuItem extends RenderShiftedBox {
  _RenderMenuItem(this.onLayout, [RenderBox child])
      : assert(onLayout != null),
        super(child);

  ValueChanged<Size> onLayout;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null) {
      return Size.zero;
    }
    return child.getDryLayout(constraints);
  }

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
    } else {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
      final BoxParentData childParentData = child.parentData as BoxParentData;
      childParentData.offset = Offset.zero;
    }
    onLayout(size);
  }
}

class _MenuItem extends SingleChildRenderObjectWidget {
  const _MenuItem({
    Key key,
    this.onLayout,
    Widget child,
  })  : assert(onLayout != null),
        super(key: key, child: child);

  final ValueChanged<Size> onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _PopupMenu<T> extends StatelessWidget {
  const _PopupMenu({
    Key key,
    this.route,
    this.width,
    this.targetBox,
    this.outerBuilder,
    this.keepPopupPadding = true,
    this.semanticLabel,
  })  : assert(targetBox != null),
        assert(keepPopupPadding != null),
        super(key: key);

  final _PopupViewRoute<T> route;
  final String semanticLabel;
  final double width;
  final PopupViewOuterBuilder outerBuilder;
  final RenderBox targetBox;
  final bool keepPopupPadding;

  @override
  Widget build(BuildContext context) {
    final double unit = 1.0 /
        (route.items.length +
            1.5); // 1.0 for the width and 0.5 for the last item's fade.
    final List<Widget> children = <Widget>[];
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);

    for (int i = 0; i < route.items.length; i += 1) {
      final double start = (i + 1) * unit;
      final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
      final CurvedAnimation opacity = CurvedAnimation(
        parent: route.animation,
        curve: Interval(start, end),
      );
      Widget item = route.items[i];
      if (route.initialValue != null &&
          route.items[i].represents(route.initialValue)) {
        item = Container(
          color: Theme.of(context).highlightColor,
          child: item,
        );
      }
      children.add(
        _MenuItem(
          onLayout: (Size size) {
            route.itemSizes[i] = size;
          },
          child: FadeTransition(
            opacity: opacity,
            child: item,
          ),
        ),
      );
    }

    final Widget child = ConstrainedBox(
      constraints: width != null
          ? BoxConstraints(minWidth: this.width, maxWidth: this.width)
          : const BoxConstraints(
              minWidth: _kMenuMinWidth,
              maxWidth: _kMenuMaxWidth,
            ),
      child: IntrinsicWidth(
        stepWidth: _kMenuWidthStep,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: SingleChildScrollView(
            child: ListBody(children: children),
          ),
        ),
      ),
    );

    final Widget finalChild = outerBuilder?.call(
          context,
          route.animation,
          route.secondaryAnimation,
          child,
          targetBox,
        ) ??
        Material(
          shape: route.shape ?? popupMenuTheme.shape,
          color: route.color ?? popupMenuTheme.color,
          type: MaterialType.card,
          elevation: route.elevation ?? popupMenuTheme.elevation ?? 8.0,
          child: keepPopupPadding
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _kMenuHorizontalPadding,
                      vertical: _kMenuVerticalPadding),
                  child: child,
                )
              : child,
        );

    return finalChild;
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(
    this.position,
    this.itemSizes,
    this.selectedItemIndex,
    this.textDirection, {
    this.menuScreenPadding = _kMenuScreenPadding,
    this.popupDirection = PopupDirection.bottom,
    this.coverTarget = false,
  })  : assert(popupDirection != null),
        assert(coverTarget != null),
        assert(menuScreenPadding != null);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The sizes of each item are computed when the menu is laid out, and before
  // the route is laid out.
  List<Size> itemSizes;

  // The index of the selected item, or null if PopupMenuButton.initialValue
  // was not specified.
  final int selectedItemIndex;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final EdgeInsets menuScreenPadding;

  final bool coverTarget;

  final PopupDirection popupDirection;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(
      constraints.biggest -
              Offset(menuScreenPadding.horizontal, menuScreenPadding.vertical)
          as Size,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Size targetSize =
        Size(position.right - position.left, position.bottom - position.top);

    double topOffset = position.top + menuScreenPadding.top;

    if (popupDirection == PopupDirection.bottom) {
      topOffset += (coverTarget ? 0 : targetSize.height);
    } else if (popupDirection == PopupDirection.top) {
      topOffset -= (childSize.height + (coverTarget ? -targetSize.height : 0));
    }

    return Offset(menuScreenPadding.left, topOffset);
  }

  bool _menuScreenPaddingEqual(EdgeInsets oldMenuScreenPadding) {
    return menuScreenPadding.left == oldMenuScreenPadding.left &&
        menuScreenPadding.right == oldMenuScreenPadding.right &&
        menuScreenPadding.top == oldMenuScreenPadding.top &&
        menuScreenPadding.bottom == oldMenuScreenPadding.bottom;
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    // If called when the old and new itemSizes have been initialized then
    // we expect them to have the same length because there's no practical
    // way to change length of the items list once the menu has been shown.
    assert(itemSizes.length == oldDelegate.itemSizes.length);

    bool result = position != oldDelegate.position ||
        !_menuScreenPaddingEqual(oldDelegate.menuScreenPadding) ||
        selectedItemIndex != oldDelegate.selectedItemIndex ||
        textDirection != oldDelegate.textDirection ||
        !listEquals(itemSizes, oldDelegate.itemSizes);
    print(
        "result: $result   new:$menuScreenPadding  old:${oldDelegate.menuScreenPadding}");
    return result;
  }
}
