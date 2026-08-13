part of 'theme.dart';

class StarsDesktopTheme {
  static double get panelRadius => DesktopThemeTokens.panelRadiusValue;
  static double get cardRadius => DesktopThemeTokens.statusRadiusValue;
  static double get bubbleRadius => DesktopThemeTokens.bubbleRadiusValue;
  static double get workspacePadding =>
      DesktopThemeTokens.workspacePadding.left;
  static const double contentMaxWidth = DesktopThemeTokens.contentMaxWidth;
  static const double messageBubbleMaxWidth = 552;
  static const double inputMaxWidth = contentMaxWidth;

  static Color workspaceBackground(BuildContext context) {
    return DesktopThemeTokens.workspaceSurface(context);
  }

  static Color panelBackground(BuildContext context) {
    return DesktopThemeTokens.panelSurface(context);
  }

  static Color elevatedSurface(BuildContext context) {
    return DesktopThemeTokens.secondarySurface(context);
  }

  static Color borderColor(BuildContext context) {
    return DesktopThemeTokens.outline(context);
  }

  static Color mutedText(BuildContext context) {
    return DesktopThemeTokens.mutedText(context);
  }

  static Color subtleText(BuildContext context) {
    return DesktopThemeTokens.softText(context);
  }

  static Color assistantBubble(BuildContext context) {
    return DesktopThemeTokens.panelSurface(context);
  }

  static Color userBubble(BuildContext context) {
    return DesktopThemeTokens.selectedFill(context);
  }

  static Color statusCardBackground(BuildContext context) {
    return DesktopThemeTokens.secondarySurface(context);
  }

  static List<BoxShadow> panelShadow(BuildContext context) {
    return DesktopThemeTokens.panelShadow(context);
  }
}
