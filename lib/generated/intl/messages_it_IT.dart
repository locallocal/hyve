// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it_IT locale. All the
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
  String get localeName => 'it_IT';

  static String m0(name) => "Bot \"${name}\" aggiunto";

  static String m1(botName) => "\"${botName}\" è stato eliminato";

  static String m2(botName) =>
      "Ciao! Sono ${botName}, un assistente AI. Puoi farmi qualsiasi domanda e farò del mio meglio per aiutarti.";

  static String m3(botName) => "${botName} sta scrivendo...";

  static String m4(botName) => "Bot ${botName} aggiornato";

  static String m5(botName) => "Chat con ${botName} eliminata";

  static String m6(botName) =>
      "Sei sicuro di voler cancellare tutta la cronologia chat con \"${botName}\"? Questa azione non può essere annullata.";

  static String m7(botName) =>
      "Eliminare il bot rimuoverà anche tutte le chat associate. Sei sicuro di voler eliminare ${botName}?";

  static String m8(botName) =>
      "Eliminare la chat cancellerà tutta la cronologia delle conversazioni. Sei sicuro di voler eliminare la chat con ${botName}?";

  static String m9(name) =>
      "Disinstallare ${name}? Verranno rimossi anche i collegamenti ai bot.";

  static String m10(year) => "© ${year} Team Stars";

  static String m11(name) =>
      "Consenti a ${name} di registrare gli script dichiarati come strumenti. Ogni chiamata richiederà comunque l’approvazione.";

  static String m12(language) => "Lingua impostata a ${language}";

  static String m13(minutes) => "${minutes} minuti fa";

  static String m14(count) => "${count} modelli recuperati con successo";

  static String m15(count) => "${count} esecuzioni di comandi";

  static String m16(duration) => "Durata ${duration}";

  static String m17(count) => "${count} modifiche ai file";

  static String m18(count) => "${count} chiamate agli strumenti";

  static String m19(error) => "Impossibile ottenere risposta: ${error}";

  static String m20(error) => "Impossibile importare la competenza: ${error}";

  static String m21(duration) => "Elaborazione completata · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bot"),
    "about": MessageLookupByLibrary.simpleMessage("Informazioni"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Informazioni su Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Aggiungi bot"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Aggiungi competenza"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Regola dimensione testo nell\'app",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Regola dimensione testo",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Tutte le competenze installate sono state aggiunte.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Sempre attiva"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisce questa competenza in ogni richiesta di testo.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Sempre attiva"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Indirizzo API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("Chiave API"),
    "apiType": MessageLookupByLibrary.simpleMessage("Tipo API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Un\'app di chat AI semplice ma potente che ti permette di conversare con l\'AI ovunque tu sia.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - Assistente chat AI",
    ),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automatica"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Consente ai modelli supportati di attivare questa competenza dalla sua descrizione.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Questo provider supporta solo competenze manuali.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Memoria automatica",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "I riepiloghi automatici possono essere imprecisi. Il messaggio corrente ha sempre la precedenza.",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Abilita gli strumenti MCP per questo agente. Le chiamate richiedono conferma per impostazione predefinita.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nome bot"),
    "botSkills": MessageLookupByLibrary.simpleMessage("Competenze"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Scegli le istruzioni riutilizzabili disponibili per questo bot.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Cambia avatar"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "Stato di esecuzione della chat",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "Cronologia chat cancellata",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chat"),
    "clear": MessageLookupByLibrary.simpleMessage("Cancella"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Cancella memoria automatica",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Cancella chat"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Cancella cronologia chat",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Rimuovi competenze fissate",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Clicca + nell\'angolo in alto a destra per aggiungere un bot",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Fai clic su Nuova chat per creare una conversazione",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Esecuzioni dei comandi",
    ),
    "compactNow": MessageLookupByLibrary.simpleMessage("Comprimi ora"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Organizzazione del contesto…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Non riuscito"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "Stato compressione",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Conferma"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Conferma eliminazione",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Informazioni di contatto (opzionale)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Contesto e memoria",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "Contesto compresso",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage(
      "Finestra di contesto",
    ),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Riepilogo conversazione",
    ),
    "copyright": m10,
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Fornitore personalizzato...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modalità scura"),
    "deepThinking": MessageLookupByLibrary.simpleMessage(
      "Ragionamento approfondito",
    ),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Sei un assistente AI utile. Per favore, rispondi in italiano.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Elimina"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Elimina bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Elimina chat"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "Informazioni e note legali",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Aspetto e lingua",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Modifica il tuo avatar e il nome visualizzato.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Generali"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Aiuto e supporto",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni personali",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Le modifiche hanno effetto immediato e vengono salvate localmente.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Gestisci il profilo, l’aspetto, la lingua e il supporto dell’app.",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Dettagli"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Disabilita senza conferma per tutti",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Disabilita tutti gli strumenti",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Disattiva script",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Modifica"),
    "editBot": MessageLookupByLibrary.simpleMessage("Modifica bot"),
    "editMemory": MessageLookupByLibrary.simpleMessage("Modifica memoria"),
    "editName": MessageLookupByLibrary.simpleMessage("Modifica nome"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Impossibile ottenere risposta: il server ha restituito una risposta vuota",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Abilita senza conferma per tutti",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Abilita tutti gli strumenti",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage("Attiva script"),
    "enableSkillScriptsDescription": m11,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "Attivare gli script isolati?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "Inserisci indirizzo API...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage(
      "Inserisci chiave API...",
    ),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "Inserisci nome bot...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome visualizzato",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Inserisci nuovo nome",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Inserisci nome fornitore...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Inserisci prompt di sistema...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Errore durante il caricamento del contenuto, riprova più tardi.",
    ),
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Utilizzo stimato",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage(
      "Stato di esecuzione",
    ),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Inserisci il contenuto del feedback",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Raccontaci i tuoi pensieri, problemi o suggerimenti per aiutarci a migliorare l\'app",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il tuo feedback qui...",
    ),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni sul feedback",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Invio fallito, riprova più tardi",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "Grazie per il tuo feedback!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Ottieni lista modelli",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Ottieni prima la lista dei modelli",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("Stato dei file"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Musica"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Voce"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Compila nome bot, indirizzo API e chiave API",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Segui sistema"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage(
      "Dimensione testo",
    ),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Dimensione testo aggiornata",
    ),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Dimentica"),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Generazione non riuscita",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Generazione non riuscita · Risposta parziale conservata",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Aiuto e feedback"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "idle": MessageLookupByLibrary.simpleMessage("Inattivo"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importa cartella delle competenze",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importa ZIP delle competenze",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importazione della competenza…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Token di input"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Installa aggiornamento",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Il riepilogo non ha superato la convalida",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Proprio ora"),
    "languageChanged": m12,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni lingua",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modalità chiara"),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Gestisci memoria"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Per messaggio"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Se necessario, seleziona la competenza nel campo del messaggio.",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Senza conferma",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Server MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Collega server MCP e scopri i relativi cataloghi di strumenti. Configura gli strumenti dopo aver creato un agente.",
    ),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Artefatto"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "La memoria è cambiata; riprova",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Correzione"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Decisione"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Fatto"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Preferenza"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("Domanda aperta"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Attività"),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Inserisci messaggio...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Competenze"),
    "minutesAgo": m13,
    "model": MessageLookupByLibrary.simpleMessage("Modello"),
    "modelsRetrievedSuccess": m14,
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nome aggiornato"),
    "newChat": MessageLookupByLibrary.simpleMessage("Nuova chat"),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "Non sono disponibili strumenti MCP connessi.",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Nessuna competenza aggiunta",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Aggiungi le competenze installate necessarie a questo bot.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Nessun bot disponibile",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Nessuna chat ancora"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Nessun contenuto restituito",
    ),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Non è ancora disponibile un riepilogo della conversazione.",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Nessuna competenza corrispondente trovata",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Nessun modello recuperato",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "Nessuna competenza installata",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Importa una cartella Agent Skills o un file ZIP contenente SKILL.md.",
    ),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Contesto precedente insufficiente da comprimere",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Token di output"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Risposta parziale",
    ),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Pausa generazione",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Fissa"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fissa la selezione per questa conversazione",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fissata"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Inserisci prima la chiave API",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("Anteprima testo"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politica sulla privacy",
    ),
    "processCommandCount": m15,
    "processDuration": m16,
    "processFileCount": m17,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni sul processo",
    ),
    "processToolCount": m18,
    "profile": MessageLookupByLibrary.simpleMessage("Profilo"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Fornisci i tuoi suggerimenti e feedback",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Fornitore"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Ragionamento completato",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Ragionamento in corso",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Ragionamento interrotto",
    ),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Ricostruisci"),
    "refresh": MessageLookupByLibrary.simpleMessage("Aggiorna"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Aggiorna cataloghi",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento cataloghi…",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Rimuovi competenza"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "Risposta annullata",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Interrotto · Risposta parziale conservata",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Ripristina impostazioni predefinite",
    ),
    "responseError": m19,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Ripristina"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Turni recenti mantenuti",
    ),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Esegui verifica",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Salva"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Salva modifiche"),
    "searchMemory": MessageLookupByLibrary.simpleMessage("Cerca nella memoria"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Cerca competenze"),
    "selectBot": MessageLookupByLibrary.simpleMessage("Seleziona bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Seleziona lingua"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Seleziona modello:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Seleziona fornitore:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Seleziona tema"),
    "send": MessageLookupByLibrary.simpleMessage("Invia"),
    "settings": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Mostra i dettagli di esecuzione nei messaggi della conversazione.",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Risorse disponibili",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("Compatibilità"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Questo esempio deve attivare la competenza",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Esempio di richiesta utente",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Risultato attivazione",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage(
      "Dettagli della competenza",
    ),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Digest del contenuto"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Disattivata"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Attivata"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("File"),
    "skillImportFailed": m20,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Competenza importata",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Competenze"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Installa istruzioni riutilizzabili e associale ai bot.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "Questa versione non esegue script o comandi delle competenze.",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Editore"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "File di riferimento disponibili",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md viene caricato solo come istruzione controllata per il prompt; script, comandi e strumenti esterni restano disabilitati.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Sandbox per script desktop disponibile",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Gli script restano disattivati finché non li approvi. Ogni chiamata richiede comunque l’approvazione.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Script delle abilità non disponibili",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Questa piattaforma non offre l’isolamento richiesto. Istruzioni e risorse restano disponibili.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Impostazione degli script aggiornata.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Gli script sono installati, ma la loro esecuzione è disabilitata.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Script attivati",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Firma"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Firma non valida",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Editore sconosciuto",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage(
      "Non firmato",
    ),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Firma verificata",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Origine"),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("Automatico"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento disponibile",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Manuale"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("Notifica"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Bloccato"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Criterio di aggiornamento",
    ),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Utente"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Note di convalida",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Versione"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Invia un messaggio nel campo di testo sotto per iniziare a chattare",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Inizia a chattare"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("Attivato"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Allegato"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "In attesa di approvazione",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Annullato"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Completato"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Negato"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage(
      "Chiamata duplicata",
    ),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Non riuscito"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Generato"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("In corso"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Registrato"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Richiesto"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("In esecuzione"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Ignorato"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("Tempo scaduto"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Sconosciuto"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informazioni strutturate sul processo",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Invia feedback"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Messaggi riassunti",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt di sistema:"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Verifica"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Verifica descrizione",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Tema impostato su scuro",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Tema impostato su chiaro",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Tema impostato su sistema",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("Impostazioni tema"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Elaborazione completata",
    ),
    "thinkingCompletedWithDuration": m21,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Elaborazione…"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Consentito una volta",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Negato"),
    "toolCalls": MessageLookupByLibrary.simpleMessage(
      "Chiamate agli strumenti",
    ),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("Distruttivo"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("Sola lettura"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Scrittura"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Integrato"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Script Skill",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Digitando..."),
    "uninstall": MessageLookupByLibrary.simpleMessage("Disinstalla"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Disinstalla competenza",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Carica file"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Carica immagine"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Accordo utente"),
    "version": MessageLookupByLibrary.simpleMessage("Versione 1.0.0"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Vedi riepilogo"),
  };
}
