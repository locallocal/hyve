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
      "Durch das Löschen des Bots werden alle zugehörigen Chats gelöscht. Möchten Sie ${botName} wirklich löschen?";

  static String m7(botName) =>
      "Durch das Löschen des Chats wird der gesamte Chat-Verlauf gelöscht. Möchten Sie den Chat mit ${botName} wirklich löschen?";

  static String m8(name) =>
      "${name} löschen? Der zwischengespeicherte Tool-Katalog und die sicheren Anmeldeinformationen werden ebenfalls entfernt.";

  static String m9(name) =>
      "${name} deinstallieren? Die Bot-Zuordnungen werden ebenfalls entfernt.";

  static String m10(year) => "© ${year} Hyve-Team";

  static String m11(error) => "Der Chat konnte nicht erstellt werden: ${error}";

  static String m12(error) =>
      "Das Projekt konnte nicht erstellt werden: ${error}";

  static String m13(error) => "Der Chat konnte nicht gelöscht werden: ${error}";

  static String m14(milliseconds) => "${milliseconds} ms";

  static String m15(seconds) => "${seconds} s";

  static String m16(name) =>
      "${name} darf deklarierte Skripte als Tools registrieren. Jeder Aufruf erfordert weiterhin eine Genehmigung.";

  static String m17(count) => "${count} Dateien";

  static String m18(error) => "Bild generieren fehlgeschlagen: ${error}";

  static String m19(error) => "Musik konnte nicht generiert werden: ${error}";

  static String m20(error) => "Konnte keine Sprache erzeugen: ${error}";

  static String m21(error) => "Video konnte nicht generiert werden: ${error}";

  static String m22(count) => "${count} Artikel";

  static String m23(language) => "Sprache auf ${language} eingestellt";

  static String m24(error) => "MCP-Verbindung fehlgeschlagen: ${error}";

  static String m25(count) => "${count} konfiguriert (Werte ausgeblendet)";

  static String m26(minutes) => "vor ${minutes} Minuten";

  static String m27(count) => "Erfolgreich ${count} Modelle abgerufen";

  static String m28(count) => "${count} Befehlsausführungen";

  static String m29(duration) => "Dauer ${duration}";

  static String m30(count) => "${count} Dateiänderungen";

  static String m31(count) => "${count} Tool-Aufrufe";

  static String m32(id) => "Agent ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Artefakt ${artifactId}";

  static String m34(code) => "Artefaktvorgang fehlgeschlagen (${code})";

  static String m35(ids) => "Artefaktversionen: ${ids}";

  static String m36(index) => "Anhang ${index}";

  static String m37(count) => "${count} ausstehend";

  static String m38(path) =>
      "Jede Version von ${path} löschen? Artefakte, auf die in einer Nachricht oder Zustellung verwiesen wird, können nicht gelöscht werden.";

  static String m39(depth) => "Übermittlungstiefe: ${depth}";

  static String m40(id, status) => "Übermittlungsausführung: ${id} · ${status}";

  static String m41(value) => "Dauer: ${value}";

  static String m42(value) => "Fehler: ${value}";

  static String m43(id) => "Ereignis: ${id}";

  static String m44(sequence) => "Ereignis #${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} Artefakt', other: '${count} Artefakte')}";

  static String m46(code) =>
      "Mitgliederaktualisierung fehlgeschlagen (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} geändert von ${previous} zu ${current}";

  static String m48(agentId, current) => "${agentId} ist jetzt ${current}";

  static String m49(id) => "Nachrichten-ID: ${id}";

  static String m50(code) => "Nachricht konnte nicht gesendet werden (${code})";

  static String m51(sequence) => "Nachricht #${sequence}";

  static String m52(processed, latest) =>
      "Verarbeitet ${processed} / spätestens ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} Empfänger', other: '${count} Empfänger')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} referenzierende Nachricht', other: '${count} referenzierende Nachrichten')}";

  static String m55(name) => "${name} entfernen?";

  static String m56(name) => "Zum Neuanordnen ziehen ${name}";

  static String m57(sequence) => "Auf Nachricht #${sequence} antworten";

  static String m58(id) => "Root-Ausführung: ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} Ausführung', other: '${count} Ausführungen')}";

  static String m60(runId) => " · Ausführung ${runId}";

  static String m61(value) => "Quelle: ${value}";

  static String m62(id) => "Quellausführung: ${id}";

  static String m63(value) => "Zielausführungen: ${value}";

  static String m64(input, output) => "Eingang ${input} · Ausgang ${output}";

  static String m65(id, status) => "Drehen: ${id} · ${status}";

  static String m66(mime, digest) =>
      "Die In-App-Vorschau wird für diesen Typ nicht unterstützt. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "Version ${version} · Agent ${actor}${run}";

  static String m68(error) => "Antwort konnte nicht abgerufen werden: ${error}";

  static String m69(error) => "Bild konnte nicht gespeichert werden: ${error}";

  static String m70(count) => "${count} ausgewählt";

  static String m71(error) => "Bild konnte nicht geteilt werden: ${error}";

  static String m72(error) =>
      "Fähigkeit konnte nicht importiert werden: ${error}";

  static String m73(duration) => "Denken abgeschlossen · ${duration}";

  static String m74(error) => "Fehler bei der Videowiedergabe: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("Über"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Über Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "Die aktive Anfrage kann nicht abgebrochen werden. Warten Sie, bis der Vorgang abgeschlossen ist.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "Die aktive Anfrage kann nicht gestoppt werden",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Anhang"),
    "addBot": MessageLookupByLibrary.simpleMessage("Bot hinzufügen"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage(
      "MCP-Server hinzufügen",
    ),
    "addSkill": MessageLookupByLibrary.simpleMessage("Fähigkeit hinzufügen"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "App-Schriftgröße anpassen",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Schriftgröße anpassen",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Öffne ein Projekt, das diesen Agenten verwendet, um seinen Kontext und sein Gedächtnis anzuzeigen und zu verwalten.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Agentengedächtnis"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Automatische Gedächtnisentwicklung",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "Das Langzeitgedächtnis gehört zu diesem Agenten und kann projektübergreifend wiederverwendet werden.",
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Hyve - KI-Chat-Assistent",
    ),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "System-Prompt",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Wird von Hyve verwaltet und jeder Modellanfrage hinzugefügt. Die Kennungen des aktuellen Agenten und der Unterhaltung werden zur Laufzeit ergänzt und können nicht bearbeitet werden.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("Angehängte Dateien"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("Angehängte Bilder"),
    "attachments": MessageLookupByLibrary.simpleMessage("Anhänge"),
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
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Zurück zum täglichen Gebrauch",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Grundlegende Informationen",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Bot-Avatar"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage("Bot-Informationen"),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "MCP-Tools für diesen Agenten aktivieren. Tool-Aufrufe müssen standardmäßig bestätigt werden.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Bot-Name"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "Die Suche filtert die Liste nach Bot-Namen.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie wiederverwendbare Anweisungen für diesen Bot aus.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Dieser Bot ist nicht verfügbar",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Avatar ändern"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Gespeichert"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "Die Suche gleicht Bot-Namen und die neueste Nachricht ab.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage("Anhänge löschen"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Automatische Erinnerung löschen",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Anheftungen des Gesprächs löschen",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Suche löschen"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie einen Tag aus, um die stündliche Nutzung anzuzeigen",
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
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
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
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Token-Anteil nach Konversation",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel kopieren",
    ),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Installationsort kopieren",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Projekt erstellen"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Erstellen…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Schöpfungszeit"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefinierter Anbieter...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("Tägliche Nutzung"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dunkles Design"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Diese Datenbank wurde mit einer neueren Version von Hyve erstellt. Aktualisieren Sie die App, bevor Sie sie öffnen.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "Die Integritätsprüfung der Datenbank ist fehlgeschlagen, und die Wiederherstellung aus der Sicherung dieser Version war nicht möglich.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Tiefes Denken"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Du bist ein hilfreicher KI-Assistent. Bitte antworte auf Deutsch.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Bot löschen"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Chat löschen"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "MCP-Server löschen",
    ),
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
    "details": MessageLookupByLibrary.simpleMessage("Einzelheiten"),
    "directPlayback": MessageLookupByLibrary.simpleMessage(
      "Bereit zum Spielen",
    ),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Bereit zur Vorschau",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Ohne Bestätigung für alle deaktivieren",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Alle Tools deaktivieren",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Skripte deaktivieren",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "editBot": MessageLookupByLibrary.simpleMessage("Bot bearbeiten"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "MCP-Server bearbeiten",
    ),
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
    "enableSkillScriptsDescription": m16,
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
    "fileAttachment": MessageLookupByLibrary.simpleMessage("Dateianhang"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Dateiergebnis"),
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
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("Bild generiert"),
    "generating": MessageLookupByLibrary.simpleMessage("Generieren…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Bild wird generiert, bitte warten...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Generierung fehlgeschlagen · Teilantwort beibehalten",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Hilfe & Feedback"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel ausblenden",
    ),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Bot-Informationen ausblenden",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Seitenleiste ausblenden",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Startseite"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Stündliche Nutzung",
    ),
    "idle": MessageLookupByLibrary.simpleMessage("Leerlauf"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("Bildanhang"),
    "imageResult": MessageLookupByLibrary.simpleMessage("Bildergebnis"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Bild in der Galerie gespeichert",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Bildgröße"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Bildstil"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Fähigkeitsordner importieren",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Fähigkeits-ZIP importieren",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Fähigkeit wird importiert…",
    ),
    "includesDuration": MessageLookupByLibrary.simpleMessage(
      "Beinhaltet die Dauer",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Eingabe-Token"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Aktualisierung installieren",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Die Zusammenfassung hat die Prüfung nicht bestanden",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Zum Neuesten springen",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Gerade eben"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Spracheinstellungen",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Helles Design"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Dieser Link kann nicht geöffnet werden.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "Lokale prozessbasierte MCP-Server bleiben bis zu einer Sicherheitsüberprüfung der Plattform deaktiviert.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage(
      "Erinnerung verwalten",
    ),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Pro Nachricht"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie die Fähigkeit bei Bedarf im Nachrichtenfeld aus.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "OAuth/Bearer-Zugriffstoken",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Argumente"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Geben Sie ein Argument pro Zeile ein.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage(
      "Authentifizierung",
    ),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Genehmigung erforderlich",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Befehl"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Name der ausführbaren Datei oder absoluter Pfad. Der Befehl wird direkt ohne Shell ausgeführt.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Kommunikationskanal",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("Verbunden"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Verbinden"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Verbindungsfehler",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("Verbindung"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Getrennt"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Streambarer HTTP-Endpunkt",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage(
      "Umgebungsvariablen",
    ),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Geben Sie einen KEY=VALUE pro Zeile ein. Werte werden im sicheren Anmeldeinformationsspeicher des Betriebssystems gespeichert; Lassen Sie das Feld beim Bearbeiten leer, um vorhandene Werte beizubehalten.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Remote-MCP-Endpunkte müssen HTTPS verwenden.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "Umgebungsvariablen müssen einen KEY=VALUE-Eintrag pro Zeile verwenden.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "stdio-Server führen Befehle auf diesem Computer aus. Fügen Sie nur Server und Umgebungsvariablen hinzu, denen Sie vertrauen.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Lokale Prozesssicherheit",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Ohne Bestätigung",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Keine"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Private, lokale und verbindungslokale MCP-Endpunkte werden blockiert.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("Prozess-ID (PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("Läuft nicht"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("Laufen"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("Begonnen um"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage("Prozessstatus"),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Hyve-Filialen haben Werkzeugkataloge entdeckt. Aktivieren Sie beim Bearbeiten eines Agenten einzelne Tools. Nur dieser Agent kann sie dem Modell zugänglich machen.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "Die MCP-Anfrage ist abgelaufen.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Sichere Umgebungsvariablen",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage("Serverdetails"),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("Servername"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP-Server"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "MCP-Server verbinden und ihre Tool-Kataloge entdecken. Tools werden nach dem Erstellen eines Agenten konfiguriert.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (Betriebssystem-Pipes)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Lokaler Prozess und Kommunikation",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "Der stdio MCP-Befehl konnte nicht gestartet werden.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Lassen Sie das Feld leer, um die vorhandenen sicheren Anmeldeinformationen beizubehalten.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Wird im sicheren Anmeldeinformationsspeicher des Betriebssystems gespeichert.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Dieses Tool verfügt über ein nicht unterstütztes Eingabeschema und kann nicht ausgewählt werden.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Werkzeuge"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Transport"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (lokaler Prozess)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "Der MCP-Server verwendet eine nicht unterstützte Protokollversion.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Gedächtnis"),
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
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Verwenden Sie @, um mindestens einen Projektagenten zu erwähnen.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Nachricht in die Zwischenablage kopiert",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Nachricht eingeben und Agenten mit @ erwähnen...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("Datei"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Bild"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Multimodal"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Musik"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("Echtzeit"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Rede"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Text"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "model": MessageLookupByLibrary.simpleMessage("Modell"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Modellkonfiguration",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Modellkontextgröße",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Eingabe"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Ausgabe"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage("Änderungszeit"),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Musik generiert"),
    "musicResult": MessageLookupByLibrary.simpleMessage("Musikergebnis"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Name aktualisiert"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Neue Bots bleiben zur Bearbeitung im Arbeitsbereich.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Neuer Chat"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Ein neuer Chat öffnet sich direkt im Arbeitsbereich.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Neues Projekt"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "Dieser Agent hat noch kein Langzeitgedächtnis.",
    ),
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
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Bots gefunden",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Chats gefunden",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "Keine passenden MCP-Server gefunden",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Tools gefunden",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Fähigkeiten gefunden",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Keine MCP-Server"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Fügen Sie einen Streamable HTTP- oder Desktop-Stdio-Server hinzu, um dessen Tool-Katalog zu ermitteln.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "Keine Tools entdeckt. Überprüfen Sie die Verbindung und aktualisieren Sie sie.",
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
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "Keine Token-Nutzung aufgezeichnet",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("Nicht unterstützt"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Nicht genügend älterer Kontext zum Komprimieren",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Löschen Sie diesen verwaisten Chat oder erstellen Sie den fehlenden Bot neu.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Ausgabe-Token"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Teilantwort"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("Audio pausieren"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Generierung pausieren",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Anheften"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Auswahl für dieses Gespräch anheften",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Angeheftet"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Audio abspielen"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie zuerst den API-Schlüssel ein",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie eine Beschreibung für die Bildgenerierung ein",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine Beschreibung für die Musikgenerierung ein",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine Beschreibung für die Sprachgenerierung ein",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine Beschreibung für die Videogenerierung ein",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("Texteffekt-Vorschau"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Prozessinformationen",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Aufholen",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage(
      "Aufgeholt",
    ),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage(
      "Entscheiden",
    ),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage(
      "Fehlgeschlagen",
    ),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("Angehalten"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage(
      "Antworten",
    ),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage(
      "Übersprungen",
    ),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage(
      "Werde antworten",
    ),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Agent hinzufügen"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Suchen Sie nach einem verfügbaren Agenten und fügen Sie ihn diesem Projekt hinzu.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Anhang hinzufügen",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Agent"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Agentenspeicher",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Alle Typen"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "Dieses Artefakt ist referenziert und kann nicht gelöscht werden.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage(
      "Archiv",
    ),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Anhang",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Code"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Datensatz",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Dokument",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Generiert",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("Bild"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage(
      "Sonstiges",
    ),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Dieser Projektpfad existiert bereits.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Verwenden Sie einen gültigen projektrelativen Pfad.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Alle Artefakte",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "Die Datei überschreitet die Artefaktgrößenbeschränkung.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "Symbolische Links können nicht importiert werden.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "Die aktuelle Version hat sich geändert. Öffnen Sie es erneut, bevor Sie es bearbeiten.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Artefaktversionen",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Projektartefakte",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Durchsuchen Sie Projektdateien, zeigen Sie eine Vorschau des Versionsverlaufs an und öffnen Sie Dateien mit System-Apps.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Prüfungsdetails",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Audit-Ereignisse",
    ),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Zurück zu Nachrichten",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Zurück zum übergeordneten Ordner",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine Nachricht ein. Ohne @ wird es an alle aktiven Agenten gesendet.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Wurzelkette abbrechen",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "Aktive Ausführungen in dieser Stammnachrichtenkette, einschließlich nachgelagerter Übermittlungen, werden gestoppt. Andere Ketten werden fortgesetzt.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "Diese Root-Nachrichtenkette abbrechen?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage(
      "Ausführung abbrechen",
    ),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Nur diese Ausführung wird gestoppt. Andere aktive Ausführungen in der Runde werden fortgesetzt.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "Diese Ausführung abbrechen?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage(
      "Wende abbrechen",
    ),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Jede aktive Ausführung in dieser Runde wird gestoppt. Abgeschlossene Ergebnisse bleiben erhalten.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "Diesen Zug abbrechen?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Schließen"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Inhalt"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Kontextbericht",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Durch Nachricht abgedeckt",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Erstellen"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Neuer Text"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Version erstellen",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Entscheidung aufgehoben",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "Entscheidungsanforderung fehlgeschlagen",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige Entscheidungsantwort",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "Zeitüberschreitung bei der Entscheidung",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Entscheidungen"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "Artefakt löschen?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Agenten, Fähigkeiten, Konfiguration und Langzeitgedächtnis werden nicht gelöscht.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "Gelöschter Agent",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Legen Sie Dateien hier ab, um sie zu importieren",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Senden Sie eine Nachricht, um mit der Zusammenarbeit zu beginnen. Nachrichten ohne @ werden gesendet.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Noch keine Nachrichten",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Agentenübermittlung",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Agentennachricht",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "Artefakt geändert",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "Mitgliedschaft geändert",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Teilnahmeentscheidung",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "Ausführungsstatus geändert",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Systemhinweis",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Benutzernachricht",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Prüfen Sie den Ausführungsverlauf, Teilnahmeentscheidungen, die Token-Nutzung und Audit-Ereignisse.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Ausführungsdetails",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "Ausführungsverlauf",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage(
      "Dateien importieren",
    ),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Zum Neuesten springen",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Frühere Ereignisse laden",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Projekt wird geladen",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("Projektmitglieder"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Überwachen Sie die Verarbeitung und verwalten Sie die Agentenreihenfolge, den Artefaktzugriff und die Teilnahme.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Speicherrevision",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Ein erwähnter Agent ist nicht mehr aktiv. Entfernen Sie es oder wählen Sie es erneut aus.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Verschieben oder umbenennen",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Projektname"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie einen Projektnamen ein",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Geben Sie einen Projektnamen ein.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Neues Textartefakt",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "Dieses Projekt hat keine aktiven Agenten. Nachrichten werden gespeichert, es wird jedoch keine Antwort generiert.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Keine Wirkstoffe",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Projektartefakte",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Noch keine Audit-Ereignisse",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Es sind keine Agenten zum Hinzufügen verfügbar",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Noch keine Ausführungsaufzeichnungen",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Agenten",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Noch keine Projektmitglieder",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "Es ist kein Agent erforderlich, um dieser Nachricht etwas hinzuzufügen.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Mit der System-App öffnen",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage(
      "Überspringen",
    ),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Antworten",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Übersprungen"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("Angehalten"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Vorschau und Versionsverlauf",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Es werden nur die ersten 32 KiB angezeigt. Agenten können abschnittsweise weiterlesen.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Projektrelativer Pfad",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Zum Importieren loslassen",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "Der Agent hat eine aktive Ausführung. Durch das Entfernen wird diese Ausführung abgebrochen; andere Agenten fahren fort.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "Der Agent erhält keine neuen Projektnachrichten mehr.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Öffentliche Antwort erbeten",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Fortsetzen"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Übertragung",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage(
      "Übermittlung",
    ),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("Gezielt"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Abgesagt"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage(
      "Abgeschlossen",
    ),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Entscheiden"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage(
      "Wird übermittelt",
    ),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "Ausführungs-ID",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage(
      "Unterbrochen",
    ),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Grenzwert überschritten",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Übersprungen"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage(
      "Entscheidung",
    ),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage(
      "Übermittlung",
    ),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Antworten"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Vorbereiten"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage(
      "In der Warteschlange",
    ),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage(
      "Wird ausgeführt",
    ),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage(
      "Zeitüberschreitung",
    ),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Ausführungen"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Als Projektartefakt speichern",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Wird als Projektartefakt gespeichert",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Suchen"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage(
      "Agenten suchen",
    ),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Suchen Sie nach Name, Pfad und Inhalt",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Suche nach verfügbaren Agenten",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Senden"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Fähigkeiten"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Zugriff auf Artefakte",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Keine"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Lesen"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Lesen und schreiben",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassungssegmente",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("System"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("-System"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Werkzeuge"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Abgesagt"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage(
      "Abgeschlossen",
    ),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Erstellt"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Entscheiden"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage(
      "Wird übermittelt",
    ),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("Versand"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Teilweise"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Antworten"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "Diese Datei kann nicht mit einer System-App geöffnet werden.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "Diese Version kann nicht gelesen werden",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("unbekannt"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Artefaktzugriff aktualisieren",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Benutzer"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Projektarbeitsbereich",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Neue Version schreiben",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Teilen Sie uns Ihre Vorschläge und Feedback mit",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Anbieter"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Anbieterinformationen",
    ),
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
    "referenceAudio": MessageLookupByLibrary.simpleMessage("Referenz-Audio"),
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Tools aktualisieren",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Kataloge aktualisieren",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Kataloge werden aktualisiert…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("Nur Remote-MCP"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Datei entfernen",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Bild entfernen",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Entfernen Sie den MCP-Server",
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
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Beibehaltene letzte Runden",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Wiederholen"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Test ausführen",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage(
      "Speichern und verbinden",
    ),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Änderungen speichern"),
    "saveImage": MessageLookupByLibrary.simpleMessage("Bild speichern"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "Konnte nicht in der Galerie gespeichert werden",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Speichern..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Bots suchen"),
    "searchChats": MessageLookupByLibrary.simpleMessage(
      "Konversationen suchen",
    ),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Durchsuchen Sie MCP-Server",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage("Suchwerkzeuge"),
    "searchMemory": MessageLookupByLibrary.simpleMessage(
      "Erinnerung durchsuchen",
    ),
    "searchSkills": MessageLookupByLibrary.simpleMessage(
      "Fähigkeiten durchsuchen",
    ),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie mindestens einen Bot aus.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Bot auswählen"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Sprache auswählen"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Modell auswählen:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Anbieter auswählen:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Thema auswählen"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Senden"),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "shareImage": MessageLookupByLibrary.simpleMessage("Bild teilen"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Bild von Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage(
      "API-Schlüssel anzeigen",
    ),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Wenn aktiviert, zeigen Projektunterhaltungen für Agentennachrichten die Token-Nutzung sowie Details zu Tool-, MCP- und weiteren Aufrufen an.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage("Bot-Info anzeigen"),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Seitenleiste anzeigen",
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
    "skillImportFailed": m72,
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
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Installationsort",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Installationsort in die Zwischenablage kopiert",
    ),
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
    "speechGenerated": MessageLookupByLibrary.simpleMessage(
      "Sprache generiert",
    ),
    "speechResult": MessageLookupByLibrary.simpleMessage("Sprachergebnis"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Senden Sie eine Nachricht im Eingabefeld unten, um den Chat zu beginnen",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage(
      "Beginnen Sie zu chatten",
    ),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "Start fehlgeschlagen. Bitte erneut versuchen.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage(
      "Hyve wird gestartet…",
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
    "stop": MessageLookupByLibrary.simpleMessage("Stopp"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage(
      "Anhalten und weitermachen",
    ),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Erzeugung stoppen, bevor man geht?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage(
          "Die Teilantwort wird beibehalten.",
        ),
    "stopping": MessageLookupByLibrary.simpleMessage("Stoppen…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Strukturierte Prozessinformationen",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Feedback senden"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Zusammengefasste Nachrichten",
    ),
    "supported": MessageLookupByLibrary.simpleMessage("Unterstützt"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Unterstützt MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Unterstützt Fähigkeiten",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("System-Prompt"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Kamera"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Testen"),
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
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Denkt nach…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Token-Nutzung"),
    "tokens": MessageLookupByLibrary.simpleMessage("Token"),
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
    "totalTokens": MessageLookupByLibrary.simpleMessage("Gesamtzahl der Token"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Versuchen Sie eine andere Suche oder erstellen Sie ein neues Element.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Schreibt..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "Bots können nicht geladen werden",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "Chats können nicht geladen werden",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "Nachrichten können nicht geladen werden",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage(
      "Nicht verfügbarer Bot",
    ),
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
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Video generiert"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Video konnte nicht geladen werden",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Videoergebnis"),
    "viewSummary": MessageLookupByLibrary.simpleMessage(
      "Zusammenfassung anzeigen",
    ),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Warten Sie, bis die Generierung abgeschlossen ist, bevor Sie diesen Chat verlassen.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Warten Sie, bis die Generierung abgeschlossen ist.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Websuche"),
  };
}
