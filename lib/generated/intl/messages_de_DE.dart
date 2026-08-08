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

  static String m10(name) =>
      "${name} darf deklarierte Skripte als Tools registrieren. Jeder Aufruf erfordert weiterhin eine Genehmigung.";

  static String m11(language) => "Sprache auf ${language} eingestellt";

  static String m12(minutes) => "vor ${minutes} Minuten";

  static String m13(count) => "Erfolgreich ${count} Modelle abgerufen";

  static String m14(count) => "${count} Befehlsausführungen";

  static String m15(duration) => "Dauer ${duration}";

  static String m16(count) => "${count} Dateiänderungen";

  static String m17(count) => "${count} Tool-Aufrufe";

  static String m18(error) => "Antwort konnte nicht abgerufen werden: ${error}";

  static String m19(error) =>
      "Fähigkeit konnte nicht importiert werden: ${error}";

  static String m20(duration) => "Denken abgeschlossen · ${duration}";

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
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automatisch"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Unterstützte Modelle können diese Fähigkeit anhand ihrer Beschreibung aktivieren.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Dieser Anbieter unterstützt nur manuelle Fähigkeiten.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Automatische Erinnerung",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "Automatische Zusammenfassungen können ungenau sein. Die aktuelle Nachricht hat Vorrang.",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Bot-Avatar"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "MCP-Tools für diesen Agenten aktivieren. Tool-Aufrufe müssen standardmäßig bestätigt werden.",
    ),
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
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Automatische Erinnerung löschen",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Chat-Verlauf löschen",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Anheftungen des Gesprächs löschen",
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
    "compactNow": MessageLookupByLibrary.simpleMessage("Jetzt komprimieren"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Kontext wird organisiert…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "Komprimierungsstatus",
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
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Kontext und Erinnerung",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "Kontext komprimiert",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage("Kontextfenster"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Gesprächszusammenfassung",
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
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Ohne Bestätigung für alle deaktivieren",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Alle Tools deaktivieren",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Skripte deaktivieren",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "editBot": MessageLookupByLibrary.simpleMessage("Bot bearbeiten"),
    "editMemory": MessageLookupByLibrary.simpleMessage("Erinnerung bearbeiten"),
    "editName": MessageLookupByLibrary.simpleMessage("Name bearbeiten"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Antwort konnte nicht abgerufen werden: Server hat eine leere Antwort zurückgegeben",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Ohne Bestätigung für alle aktivieren",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Alle Tools aktivieren",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Skripte aktivieren",
    ),
    "enableSkillScriptsDescription": m10,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "Isolierte Skill-Skripte aktivieren?",
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
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Geschätzte Nutzung",
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
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Feedback-Informationen",
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
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Vergessen"),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen · Teilantwort beibehalten",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Hilfe & Feedback"),
    "home": MessageLookupByLibrary.simpleMessage("Startseite"),
    "idle": MessageLookupByLibrary.simpleMessage("Leerlauf"),
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
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Aktualisierung installieren",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Die Zusammenfassung hat die Prüfung nicht bestanden",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Gerade eben"),
    "languageChanged": m11,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Spracheinstellungen",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Helles Design"),
    "manageMemory": MessageLookupByLibrary.simpleMessage(
      "Erinnerung verwalten",
    ),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Pro Nachricht"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie die Fähigkeit bei Bedarf im Nachrichtenfeld aus.",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Ohne Bestätigung",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP-Server"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "MCP-Server verbinden und ihre Tool-Kataloge entdecken. Tools werden nach dem Erstellen eines Agenten konfiguriert.",
    ),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Artefakt"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "Erinnerung geändert; bitte erneut versuchen",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Korrektur"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Entscheidung"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Fakt"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Präferenz"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("Offene Frage"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Aufgabe"),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Nachricht eingeben...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "minutesAgo": m12,
    "model": MessageLookupByLibrary.simpleMessage("Modell"),
    "modelsRetrievedSuccess": m13,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Name aktualisiert"),
    "newChat": MessageLookupByLibrary.simpleMessage("Neuer Chat"),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "Keine verbundenen MCP-Tools verfügbar.",
    ),
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
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Es ist noch keine Gesprächszusammenfassung verfügbar.",
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
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Nicht genügend älterer Kontext zum Komprimieren",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Ausgabe-Token"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Teilantwort"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Generierung pausieren",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Anheften"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Auswahl für dieses Gespräch anheften",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Angeheftet"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie zuerst den API-Schlüssel ein",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("Texteffekt-Vorschau"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "processCommandCount": m14,
    "processDuration": m15,
    "processFileCount": m16,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Prozessinformationen",
    ),
    "processToolCount": m17,
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
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Neu erstellen"),
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Kataloge aktualisieren",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Kataloge werden aktualisiert…",
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
    "responseError": m18,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Beibehaltene letzte Runden",
    ),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Test ausführen",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Änderungen speichern"),
    "searchMemory": MessageLookupByLibrary.simpleMessage(
      "Erinnerung durchsuchen",
    ),
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
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Dieses Beispiel soll die Fähigkeit aktivieren",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Beispielanfrage",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Aktivierungsergebnis",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage("Fähigkeitsdetails"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Inhalts-Hash"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Deaktiviert"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Aktiviert"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Dateien"),
    "skillImportFailed": m19,
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
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Herausgeber"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Referenzdateien verfügbar",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md wird nur als kontrollierte Prompt-Anweisung geladen; Skripte, Befehle und externe Tools bleiben deaktiviert.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Desktop-Skript-Sandbox verfügbar",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Skripte bleiben pro Skill deaktiviert, bis Sie sie freigeben. Jeder Aufruf benötigt weiterhin eine Genehmigung.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Skill-Skripte nicht verfügbar",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Diese Plattform bietet keine ausreichende isolierte Hilfsumgebung. Anweisungen und Ressourcen bleiben verfügbar.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Skill-Skripteinstellung aktualisiert.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Skripte sind installiert, ihre Ausführung ist jedoch deaktiviert.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Skripte aktiviert",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Signatur"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige Signatur",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Unbekannter Herausgeber",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage(
      "Nicht signiert",
    ),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Signatur verifiziert",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Quelle"),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("Automatisch"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Aktualisierung verfügbar",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Manuell"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigen",
    ),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Fixiert"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Aktualisierungsrichtlinie",
    ),
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
    "statusActivated": MessageLookupByLibrary.simpleMessage("Aktiviert"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Angehängt"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "Wartet auf Bestätigung",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Abgebrochen"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Abgelehnt"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("Doppelter Aufruf"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Generiert"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("In Bearbeitung"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Erfasst"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Angefordert"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Wird ausgeführt"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Übersprungen"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage(
      "Zeitüberschreitung",
    ),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Strukturierte Prozessinformationen",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Feedback senden"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Zusammengefasste Nachrichten",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("System-Prompt"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Beschreibung testen",
    ),
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
    "thinkingCompletedWithDuration": m20,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Denkt nach…"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Einmal erlaubt",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Abgelehnt"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Tool-Aufrufe"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("Destruktiv"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage(
      "Schreibgeschützt",
    ),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Schreiben"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Integriert"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Skill-Skript",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Schreibt..."),
    "uninstall": MessageLookupByLibrary.simpleMessage("Deinstallieren"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Fähigkeit deinstallieren",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Lösen"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Datei hochladen"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Bild hochladen"),
    "userAgreement": MessageLookupByLibrary.simpleMessage(
      "Benutzervereinbarung",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
    "viewSummary": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassung anzeigen",
    ),
  };
}
