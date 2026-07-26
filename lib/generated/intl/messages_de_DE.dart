// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_DE locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de_DE';

  static String m0(name) => "Bot \"${name}\" wurde hinzugefügt";

  static String m1(botName) => "\"${botName}\" wurde gelöscht";

  static String m2(botName) =>
      "Hallo! Ich bin ${botName}, ein KI-Assistent. Stellen Sie mir jederzeit Fragen, ich werde mein Bestes tun, um Ihnen zu helfen.";

  static String m3(botName) => "${botName} schreibt...";

  static String m4(botName) => "Bot ${botName} wurde aktualisiert";

  static String m5(botName) => "Chat mit ${botName} wurde gelöscht";

  static String m6(botName) =>
      "Möchten Sie wirklich alle Chat-Verläufe mit \"${botName}\" löschen? Diese Aktion kann nicht rückgängig gemacht werden.";

  static String m7(botName) =>
      "Durch das Löschen des Bots werden alle zugehörigen Chats gelöscht. Möchten Sie ${botName} wirklich löschen?";

  static String m8(botName) =>
      "Durch das Löschen des Chats wird der gesamte Chat-Verlauf gelöscht. Möchten Sie den Chat mit ${botName} wirklich löschen?";

  static String m9(name) =>
      "${name} deinstallieren? Die Bot-Zuordnungen werden ebenfalls entfernt.";

  static String m10(language) => "Sprache auf ${language} eingestellt";

  static String m11(minutes) => "vor ${minutes} Minuten";

  static String m12(count) => "Erfolgreich ${count} Modelle abgerufen";

  static String m13(count) => "${count} Befehlsausführungen";

  static String m14(duration) => "Dauer ${duration}";

  static String m15(count) => "${count} Dateiänderungen";

  static String m16(count) => "${count} Tool-Aufrufe";

  static String m17(error) => "Antwort konnte nicht abgerufen werden: ${error}";

  static String m18(error) =>
      "Fähigkeit konnte nicht importiert werden: ${error}";

  static String m19(duration) => "Denken abgeschlossen · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("Über"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Über Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Bot hinzufügen"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Fähigkeit hinzufügen"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "App-Schriftgröße anpassen",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Schriftgröße anpassen",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Alle installierten Fähigkeiten wurden hinzugefügt.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Immer aktiv"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Diese Fähigkeit wird in jede Textanfrage eingefügt.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Immer aktiv"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("API-Adresse:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API-Schlüssel"),
    "apiType": MessageLookupByLibrary.simpleMessage("API-Typ:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Eine einfache, aber leistungsstarke KI-Chat-Anwendung, mit der Sie jederzeit und überall mit KI chatten können.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - KI-Chat-Assistent",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Bot-Avatar"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("Bot-Name"),
    "botSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie wiederverwendbare Anweisungen für diesen Bot aus.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Avatar ändern"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "Ausführungsstatus des Chats",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "Chat-Verlauf wurde gelöscht",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "clear": MessageLookupByLibrary.simpleMessage("Löschen"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Chat-Verlauf löschen",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Klicken Sie auf + in der oberen rechten Ecke, um einen Bot hinzuzufügen",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Klicken Sie auf Neuer Chat, um eine Unterhaltung zu erstellen",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Befehlsausführungen",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Kontaktinformationen (optional)",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Stars-Team"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefinierter Anbieter...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dunkles Design"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Tiefes Denken"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Du bist ein hilfreicher KI-Assistent. Bitte antworte auf Deutsch.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Bot löschen"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "Info und Rechtliches",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Erscheinungsbild und Sprache",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Ändere deinen Avatar und Anzeigenamen.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Allgemein"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Hilfe und Support",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Persönliche Informationen",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Änderungen werden sofort wirksam und lokal gespeichert.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Verwalte dein Profil, das Erscheinungsbild, die Sprache und den App-Support.",
    ),
    "editBot": MessageLookupByLibrary.simpleMessage("Bot bearbeiten"),
    "editName": MessageLookupByLibrary.simpleMessage("Name bearbeiten"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Antwort konnte nicht abgerufen werden: Server hat eine leere Antwort zurückgegeben",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "API-Adresse eingeben...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel eingeben...",
    ),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "Bot-Namen eingeben...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Anzeigenamen eingeben",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Bitte neuen Namen eingeben",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Anbieternamen eingeben...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "System-Prompt eingeben...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Laden des Inhalts, bitte versuchen Sie es später erneut.",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage(
      "Ausführungsstatus",
    ),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Feedback-Inhalt ein",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Bitte teilen Sie uns Ihre Gedanken, Probleme oder Vorschläge mit, um uns bei der Verbesserung der App zu helfen",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie hier Ihr Feedback ein...",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Übermittlung fehlgeschlagen, bitte versuchen Sie es später erneut",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "Vielen Dank für Ihr Feedback!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Modellliste abrufen",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Bitte zuerst Modellliste abrufen",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("Dateistatus"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Musik"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Sprache"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Bitte Bot-Namen, API-Adresse und API-Schlüssel eingeben",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Systemeinstellung"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("Schriftgröße"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Schriftgröße aktualisiert",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen · Teilantwort beibehalten",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Hilfe & Feedback"),
    "home": MessageLookupByLibrary.simpleMessage("Startseite"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Fähigkeitsordner importieren",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Fähigkeits-ZIP importieren",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Fähigkeit wird importiert…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Eingabe-Token"),
    "justNow": MessageLookupByLibrary.simpleMessage("Gerade eben"),
    "languageChanged": m10,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Spracheinstellungen",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Helles Design"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Pro Nachricht"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie die Fähigkeit bei Bedarf im Nachrichtenfeld aus.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Nachricht eingeben...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "minutesAgo": m11,
    "model": MessageLookupByLibrary.simpleMessage("Modell"),
    "modelsRetrievedSuccess": m12,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Name aktualisiert"),
    "newChat": MessageLookupByLibrary.simpleMessage("Neuer Chat"),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Keine Fähigkeiten hinzugefügt",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Fügen Sie die installierten Fähigkeiten hinzu, die dieser Bot benötigt.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Keine Bots verfügbar",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Noch keine Chats"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Kein Inhalt zurückgegeben",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Fähigkeiten gefunden",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Keine Modelle abgerufen",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "Keine Fähigkeiten installiert",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Importieren Sie einen Agent-Skills-Ordner oder eine ZIP-Datei mit SKILL.md.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Ausgabe-Token"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Teilantwort"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Generierung pausieren",
    ),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie zuerst den API-Schlüssel ein",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("Texteffekt-Vorschau"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "processCommandCount": m13,
    "processDuration": m14,
    "processFileCount": m15,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Prozessinformationen",
    ),
    "processToolCount": m16,
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Teilen Sie uns Ihre Vorschläge und Feedback mit",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Anbieter"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Denkvorgang abgeschlossen",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Denkvorgang läuft",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Denkvorgang unterbrochen",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Fähigkeit entfernen"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "Antwort abgebrochen",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Gestoppt · Teilantwort beibehalten",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Auf Standard zurücksetzen",
    ),
    "responseError": m17,
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Änderungen speichern"),
    "searchSkills": MessageLookupByLibrary.simpleMessage(
      "Fähigkeiten durchsuchen",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Bot auswählen"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Sprache auswählen"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Modell auswählen:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Anbieter auswählen:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Thema auswählen"),
    "send": MessageLookupByLibrary.simpleMessage("Senden"),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Ausführungsdetails in Unterhaltungsnachrichten anzeigen.",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Assets verfügbar",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage(
      "Kompatibilität",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage("Fähigkeitsdetails"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Inhalts-Hash"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Deaktiviert"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Aktiviert"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Dateien"),
    "skillImportFailed": m18,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Fähigkeit importiert",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Wiederverwendbare Anweisungen installieren und Bots zuordnen.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "Diese Version führt keine Skripte oder Befehle aus Fähigkeiten aus.",
    ),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Referenzdateien verfügbar",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md wird nur als kontrollierte Prompt-Anweisung geladen; Skripte, Befehle und externe Tools bleiben deaktiviert.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Skripte sind installiert, ihre Ausführung ist jedoch deaktiviert.",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Quelle"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Benutzer"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Validierungshinweise",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Senden Sie eine Nachricht im Eingabefeld unten, um den Chat zu beginnen",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage(
      "Beginnen Sie zu chatten",
    ),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Angehängt"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Abgebrochen"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Generiert"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("In Bearbeitung"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Erfasst"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Wird ausgeführt"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Strukturierte Prozessinformationen",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Feedback senden"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("System-Prompt"),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Thema auf dunkles Design gesetzt",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Thema auf helles Design gesetzt",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Thema auf Systemeinstellung gesetzt",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage(
      "Thema-Einstellungen",
    ),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Denken abgeschlossen",
    ),
    "thinkingCompletedWithDuration": m19,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Denkt nach…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Tool-Aufrufe"),
    "typing": MessageLookupByLibrary.simpleMessage("Schreibt..."),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Fähigkeit deinstallieren",
    ),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Datei hochladen"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Bild hochladen"),
    "userAgreement": MessageLookupByLibrary.simpleMessage(
      "Benutzervereinbarung",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
  };
}
