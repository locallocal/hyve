part of 'desktop_layout.dart';

extension _DesktopLayoutResizing on _DesktopLayoutState {
  void _resizeSidebar(
    double delta, {
    required double availableWidth,
    required bool dockInspector,
    required double inspectorWidth,
  }) {
    final reserved =
        HyveDesktopThemeSpec.detailMinWidth +
        (dockInspector ? inspectorWidth : 0) +
        HyveDesktopThemeSpec.splitterHitWidth * (dockInspector ? 2 : 1);
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

  void _resizeInspector(
    double delta, {
    required double availableWidth,
    required double sidebarWidth,
  }) {
    final maxWidth = math.min(
      HyveDesktopThemeSpec.inspectorMaxWidth,
      math.max(
        HyveDesktopThemeSpec.inspectorMinWidth,
        availableWidth -
            sidebarWidth -
            HyveDesktopThemeSpec.detailMinWidth -
            HyveDesktopThemeSpec.splitterHitWidth * 2,
      ),
    );
    final effectiveWidth =
        _inspectorWidth
            .clamp(HyveDesktopThemeSpec.inspectorMinWidth, maxWidth)
            .toDouble();
    _updateState(() {
      _inspectorWidth = (effectiveWidth + delta).clamp(
        HyveDesktopThemeSpec.inspectorMinWidth,
        maxWidth,
      );
    });
  }

  void _resetInspectorWidth() {
    _updateState(() => _inspectorWidth = HyveDesktopThemeSpec.inspectorWidth);
  }
}
