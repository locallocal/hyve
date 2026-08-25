part of 'desktop_layout.dart';

extension _DesktopLayoutResizing on _DesktopLayoutState {
  void _resizeSidebar(double delta, {required double availableWidth}) {
    final reserved =
        HyveDesktopThemeSpec.detailMinWidth +
        HyveDesktopThemeSpec.splitterHitWidth;
    final compactDock = availableWidth < 1200;
    final minWidth = compactDock ? 260.0 : HyveDesktopThemeSpec.sidebarMinWidth;
    final requestedMax =
        compactDock ? 280.0 : HyveDesktopThemeSpec.sidebarMaxWidth;
    final maxWidth = math.min(
      requestedMax,
      math.max(minWidth, availableWidth - reserved),
    );
    final effectiveWidth = _sidebarWidth.clamp(minWidth, maxWidth).toDouble();
    _updateState(() {
      _sidebarWidth = (effectiveWidth + delta).clamp(minWidth, maxWidth);
    });
  }

  void _resetSidebarWidth(double availableWidth) {
    final defaultWidth =
        availableWidth < 1200 ? 280.0 : HyveDesktopThemeSpec.sidebarWidth;
    _updateState(() => _sidebarWidth = defaultWidth);
  }
}
