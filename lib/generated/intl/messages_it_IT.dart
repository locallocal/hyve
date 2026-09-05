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
      "Eliminare il bot rimuoverà anche tutte le chat associate. Sei sicuro di voler eliminare ${botName}?";

  static String m7(botName) =>
      "Eliminare la chat cancellerà tutta la cronologia delle conversazioni. Sei sicuro di voler eliminare la chat con ${botName}?";

  static String m8(name) =>
      "Eliminare ${name}? Verranno rimossi anche il catalogo degli strumenti memorizzato nella cache e le credenziali sicure.";

  static String m9(name) =>
      "Disinstallare ${name}? Verranno rimossi anche i collegamenti ai bot.";

  static String m10(year) => "© ${year} Team Hyve";

  static String m11(error) => "Impossibile creare la chat: ${error}";

  static String m12(error) => "Impossibile creare il progetto: ${error}";

  static String m13(error) => "Impossibile eliminare la chat: ${error}";

  static String m14(milliseconds) => "${milliseconds} ms";

  static String m15(seconds) => "${seconds} s";

  static String m16(name) =>
      "Consenti a ${name} di registrare gli script dichiarati come strumenti. Ogni chiamata richiederà comunque l’approvazione.";

  static String m17(count) => "${count} file";

  static String m18(error) => "Generazione immagine fallita: ${error}";

  static String m19(error) => "Impossibile generare musica: ${error}";

  static String m20(error) => "Impossibile generare la voce: ${error}";

  static String m21(error) => "Impossibile generare il video: ${error}";

  static String m22(count) => "${count} elementi";

  static String m23(language) => "Lingua impostata a ${language}";

  static String m24(error) => "Connessione MCP fallita: ${error}";

  static String m25(count) => "${count} configurato (valori nascosti)";

  static String m26(minutes) => "${minutes} minuti fa";

  static String m27(count) => "${count} modelli recuperati con successo";

  static String m28(count) => "${count} esecuzioni di comandi";

  static String m29(duration) => "Durata ${duration}";

  static String m30(count) => "${count} modifiche ai file";

  static String m31(count) => "${count} chiamate agli strumenti";

  static String m32(id) => "Agente ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Artefatto ${artifactId}";

  static String m34(code) => "Operazione artefatto non riuscita (${code})";

  static String m35(ids) => "Versioni degli artefatti: ${ids}";

  static String m36(index) => "Allegato ${index}";

  static String m37(count) => "${count} in sospeso";

  static String m38(path) =>
      "Eliminare ogni versione di ${path}? Gli artefatti a cui fa riferimento un messaggio o una consegna non possono essere eliminati.";

  static String m39(depth) => "Profondità di consegna: ${depth}";

  static String m40(id, status) => "Esecuzione di consegna: ${id} · ${status}";

  static String m41(value) => "Durata: ${value}";

  static String m42(value) => "Errore: ${value}";

  static String m43(id) => "Evento: ${id}";

  static String m44(sequence) => "Evento n.${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} artefatto', other: '${count} artefatti')}";

  static String m46(code) => "Aggiornamento membro fallito (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} cambiato da ${previous} a ${current}";

  static String m48(agentId, current) => "${agentId} ora è ${current}";

  static String m49(id) => "ID messaggio: ${id}";

  static String m50(code) => "Impossibile inviare il messaggio (${code})";

  static String m51(sequence) => "Messaggio n. ${sequence}";

  static String m52(processed, latest) =>
      "Elaborato ${processed} / più recente ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} destinatario', other: '${count} destinatari')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} messaggio di riferimento', other: '${count} messaggi di riferimento')}";

  static String m55(name) => "Rimuovere ${name}?";

  static String m56(name) => "Trascina per riordinare ${name}";

  static String m57(sequence) => "Rispondendo al messaggio #${sequence}";

  static String m58(id) => "Esecuzione root: ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} esecuzione', other: '${count} esecuzioni')}";

  static String m60(runId) => " · esecuzione ${runId}";

  static String m61(value) => "Fonte: ${value}";

  static String m62(id) => "Esecuzione sorgente: ${id}";

  static String m63(value) => "Esecuzioni di destinazione: ${value}";

  static String m64(input, output) => "Ingresso ${input} · uscita ${output}";

  static String m65(id, status) => "Gira: ${id} · ${status}";

  static String m66(mime, digest) =>
      "L\'anteprima in-app non è supportata per questo tipo. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "Versione ${version} · agente ${actor}${run}";

  static String m68(error) => "Impossibile ottenere risposta: ${error}";

  static String m69(error) => "Impossibile salvare l\'immagine: ${error}";

  static String m70(count) => "${count} selezionato";

  static String m71(error) => "Impossibile condividere l\'immagine: ${error}";

  static String m72(error) => "Impossibile importare la competenza: ${error}";

  static String m73(duration) => "Elaborazione completata · ${duration}";

  static String m74(error) => "Errore di riproduzione video: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bot"),
    "about": MessageLookupByLibrary.simpleMessage("Informazioni"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Informazioni su Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "La richiesta attiva non può essere annullata. Aspetta che finisca.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "La richiesta attiva non può essere interrotta",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Allegato"),
    "addBot": MessageLookupByLibrary.simpleMessage("Aggiungi bot"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("Aggiungi server MCP"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Aggiungi competenza"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Regola dimensione testo nell\'app",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Regola dimensione testo",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Apri un progetto che utilizza questo agente per visualizzarne e gestirne il contesto e la memoria.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Memoria dell’agente"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Evoluzione automatica della memoria",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "La memoria a lungo termine appartiene a questo agente e può essere riutilizzata tra i progetti.",
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Hyve - Assistente chat AI",
    ),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "Prompt di sistema",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Gestito da Hyve e aggiunto a ogni richiesta al modello. Gli identificatori dell’agente e della conversazione correnti vengono aggiunti in fase di esecuzione e non sono modificabili.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("File allegati"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("Immagini allegate"),
    "attachments": MessageLookupByLibrary.simpleMessage("Allegati"),
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
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Torniamo all\'utilizzo quotidiano",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni di base",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni sul bot",
    ),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Abilita gli strumenti MCP per questo agente. Le chiamate richiedono conferma per impostazione predefinita.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nome bot"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "La ricerca filtra l\'elenco in base al nome del bot.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Competenze"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Scegli le istruzioni riutilizzabili disponibili per questo bot.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Questo bot non è disponibile",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Cambia avatar"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Salvato"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "La ricerca corrisponde ai nomi dei bot e all\'ultimo messaggio.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chat"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Galleria"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage(
      "Cancella allegati",
    ),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Cancella memoria automatica",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Cancella chat"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Rimuovi competenze fissate",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Cancella la ricerca"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Seleziona un giorno per visualizzare l\'utilizzo orario",
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
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Conferma eliminazione",
    ),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
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
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Quota di token per conversazione",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("Copia la chiave API"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Copia il percorso di installazione",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Crea progetto"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Creazione..."),
    "creationTime": MessageLookupByLibrary.simpleMessage(
      "Tempo della creazione",
    ),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Fornitore personalizzato...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Utilizzo quotidiano",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modalità scura"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Questo database è stato creato da una versione più recente di Hyve. Aggiorna l’app prima di aprirlo.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "Il controllo di integrità del database non è riuscito e non è stato possibile ripristinarlo dal backup di questa versione.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage(
      "Ragionamento approfondito",
    ),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Sei un assistente AI utile. Per favore, rispondi in italiano.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Elimina"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Elimina bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Elimina chat"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "Elimina server MCP",
    ),
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
    "directPlayback": MessageLookupByLibrary.simpleMessage(
      "Pronto per giocare",
    ),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Pronto per l\'anteprima",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Disabilita senza conferma per tutti",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Disabilita tutti gli strumenti",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Disattiva script",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Modifica"),
    "editBot": MessageLookupByLibrary.simpleMessage("Modifica bot"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "Modifica server MCP",
    ),
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
    "enableSkillScriptsDescription": m16,
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
    "fileAttachment": MessageLookupByLibrary.simpleMessage("File allegato"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Risultato del file"),
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
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("Immagine generata"),
    "generating": MessageLookupByLibrary.simpleMessage(
      "Generazione in corso...",
    ),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Generazione immagine in corso, attendere prego...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Generazione non riuscita",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Generazione non riuscita · Risposta parziale conservata",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Aiuto e feedback"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("Nascondi chiave API"),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Nascondi informazioni sul bot",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Nascondi barra laterale",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Casa"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("Utilizzo orario"),
    "idle": MessageLookupByLibrary.simpleMessage("Inattivo"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("Allega immagine"),
    "imageResult": MessageLookupByLibrary.simpleMessage("Risultato immagine"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Immagine salvata nella galleria",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Dimensioni immagine"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Stile immagine"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importa cartella delle competenze",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importa ZIP delle competenze",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importazione della competenza…",
    ),
    "includesDuration": MessageLookupByLibrary.simpleMessage(
      "Include la durata",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Token di input"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Installa aggiornamento",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Il riepilogo non ha superato la convalida",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("Vai all\'ultimo"),
    "justNow": MessageLookupByLibrary.simpleMessage("Proprio ora"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni lingua",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modalità chiara"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Impossibile aprire questo collegamento.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "I server MCP basati su processi locali rimangono disabilitati in attesa di una revisione della sicurezza della piattaforma.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Gestisci memoria"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Per messaggio"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Se necessario, seleziona la competenza nel campo del messaggio.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "Token di accesso OAuth/Bearer",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Argomenti"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci un argomento per riga.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("Autenticazione"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Autorizzazione richiesta",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Comando"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Nome dell\'eseguibile o percorso assoluto. Il comando viene eseguito direttamente senza shell.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Canale di comunicazione",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("Connesso"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Connessione"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Errore di connessione",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage(
      "Connessione",
    ),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Disconnesso"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Endpoint HTTP streaming",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage(
      "Variabili d\'ambiente",
    ),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci una CHIAVE=VALORE per riga. I valori vengono archiviati nell\'archivio credenziali sicuro del sistema operativo; lasciare vuoto durante la modifica per mantenere i valori esistenti.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Gli endpoint MCP remoti devono utilizzare HTTPS.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "Le variabili d\'ambiente devono utilizzare una voce CHIAVE=VALORE per riga.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "I server stdio eseguono comandi su questo computer. Aggiungi solo server e variabili di ambiente di cui ti fidi.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Sicurezza del processo locale",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Senza conferma",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Nessuno"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Gli endpoint MCP privati, locali e link-local sono bloccati.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("ID processo (PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("Non corre"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("Correre"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage(
      "Iniziato alle",
    ),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage(
      "Stato del processo",
    ),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "I negozi Hyve hanno scoperto i cataloghi degli strumenti. Abilita singoli strumenti durante la modifica di un agente; solo quell\'agente può esporli al modello.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "La richiesta MCP è scaduta.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Variabili di ambiente sicure",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage(
      "Dettagli del server",
    ),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("Nome del server"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Server MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Collega server MCP e scopri i relativi cataloghi di strumenti. Configura gli strumenti dopo aver creato un agente.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (pipe del sistema operativo)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Processo locale e comunicazione",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "Impossibile avviare il comando stdio MCP.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Lascia vuoto per mantenere le credenziali sicure esistenti.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Memorizzati nell\'archivio credenziali sicuro del sistema operativo.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Questo strumento ha uno schema di input non supportato e non può essere selezionato.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Strumenti"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Trasporti"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (processo locale)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "Il server MCP utilizza una versione del protocollo non supportata.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Memoria"),
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
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Usa @ per menzionare almeno un agente del progetto.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Messaggio copiato negli appunti",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Inserisci un messaggio e menziona gli agenti con @...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Competenze"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("File"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Immagine"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Multimodale"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Musica"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("In tempo reale"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Discorso"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Testo"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "model": MessageLookupByLibrary.simpleMessage("Modello"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configurazione del modello",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Dimensioni del contesto del modello",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Ingresso"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Uscita"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage(
      "Orario di modifica",
    ),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Musica generata"),
    "musicResult": MessageLookupByLibrary.simpleMessage("Risultato musicale"),
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nome aggiornato"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "I nuovi bot rimangono nell\'area di lavoro per la modifica.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Nuova chat"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Una nuova chat si apre direttamente nell\'area di lavoro.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Nuovo progetto"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "Questo agente non ha ancora una memoria a lungo termine.",
    ),
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
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "Nessun bot corrispondente trovato",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "Nessuna chat corrispondente trovata",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "Nessun server MCP corrispondente trovato",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "Nessuno strumento corrispondente trovato",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Nessuna competenza corrispondente trovata",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Nessun server MCP"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Aggiungi un server HTTP streaming o desktop stdio per scoprire il relativo catalogo di strumenti.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "Nessuno strumento scoperto. Controlla la connessione e aggiorna.",
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
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "Nessun utilizzo di token registrato",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("Non supportato"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Contesto precedente insufficiente da comprimere",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Elimina questa chat orfana o ricrea il bot mancante.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Token di output"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Risposta parziale",
    ),
    "pauseAudio": MessageLookupByLibrary.simpleMessage(
      "Metti in pausa l’audio",
    ),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Pausa generazione",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Fissa"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fissa la selezione per questa conversazione",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fissata"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Riproduci audio"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Inserisci prima la chiave API",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci una descrizione per la generazione dell\'immagine",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci una descrizione per la generazione della musica",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci una descrizione per la generazione del parlato",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Inserisci una descrizione per la generazione del video",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("Anteprima testo"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politica sulla privacy",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni sul processo",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Profilo"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Attivo"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Recupero",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("Preso"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("Decidere"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("Fallito"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("In pausa"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("Rispondi"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("Saltato"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage(
      "Risponderò",
    ),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Aggiungi agente"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Cerca un agente disponibile e aggiungilo a questo progetto.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Aggiungi allegato",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Agente"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Memoria dell\'agente",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Tutti i tipi"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "Questo artefatto è referenziato e non può essere eliminato.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage(
      "Archivio",
    ),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Allegato",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Codice"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Set di dati",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Documento",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Generato",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage(
      "Immagine",
    ),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("Altro"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Video"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Il percorso del progetto esiste già.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Utilizzare un percorso relativo al progetto valido.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Tutti gli artefatti",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "Il file supera il limite di dimensione dell\'artefatto.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "I collegamenti simbolici non possono essere importati.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "La versione attuale è cambiata. Riaprilo prima di modificarlo.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Versioni degli artefatti",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Artefatti del progetto",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Sfoglia i file di progetto, visualizza l\'anteprima della cronologia delle versioni e apri i file con le app di sistema.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Dettagli dell\'audit",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Eventi di controllo",
    ),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Torniamo ai messaggi",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Torna alla cartella principale",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Digita un messaggio. Senza @ verrà trasmesso a tutti gli agenti attivi.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Annulla la catena radice",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "Le esecuzioni attive in questa catena di messaggi root, comprese le consegne discendenti, verranno interrotte. Altre catene continueranno.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "Annullare questa catena di messaggi root?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage(
      "Annulla esecuzione",
    ),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Solo questa esecuzione verrà interrotta. Le altre esecuzioni attive nel turno continueranno.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "Annullare questa esecuzione?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage(
      "Annulla il turno",
    ),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Ogni esecuzione attiva in questo turno verrà interrotta. I risultati completati verranno conservati.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "Annullare questo turno?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Chiudi"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Contenuto"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Rapporto sul contesto",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Coperto tramite messaggio",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Crea"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Nuovo testo"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Crea versione",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Decisione annullata",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "Richiesta di decisione fallita",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Risposta decisionale non valida",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "Decisione scaduta",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Decisioni"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "Eliminare l\'artefatto?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Gli agenti, le competenze, la configurazione e la memoria a lungo termine non vengono eliminati.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "Agente eliminato",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Trascina qui i file da importare",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Invia un messaggio per iniziare a collaborare. I messaggi senza @ vengono trasmessi.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Ancora nessun messaggio",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Consegna dell\'agente",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Messaggio dell\'agente",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "L\'artefatto è cambiato",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "L\'iscrizione è cambiata",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Decisione di partecipazione",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "Stato dell\'esecuzione modificato",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Avviso di sistema",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Messaggio utente",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Esamina la cronologia delle esecuzioni, le decisioni sulla partecipazione, l\'utilizzo dei token e gli eventi di controllo.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Dettagli di esecuzione",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "Cronologia esecuzioni",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage("Importa file"),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Vai all\'ultima versione",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Carica gli eventi precedenti",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Caricamento progetto",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage(
      "Membri del progetto",
    ),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Monitorare l\'elaborazione e gestire l\'ordine degli agenti, l\'accesso agli artefatti e la partecipazione.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Revisione della memoria",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Un agente menzionato non è più attivo. Rimuovilo o selezionalo di nuovo.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Sposta o rinomina",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Nome del progetto"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome per il progetto",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome per il progetto.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Nuovo artefatto di testo",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "Questo progetto non ha agenti attivi. I messaggi vengono salvati, ma non verrà generata alcuna risposta.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Nessun agente attivo",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "Nessun artefatto del progetto corrispondente",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Ancora nessun evento di controllo",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Nessun agente disponibile da aggiungere",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Ancora nessun record di esecuzione",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "Nessun agente corrispondente",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Ancora nessun membro del progetto",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "Nessun agente ha avuto bisogno di aggiungere nulla a questo messaggio.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Apri con l\'app di sistema",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("Salta"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Rispondi",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Saltato"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Pausa"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("In pausa"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Anteprima e cronologia delle versioni",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Vengono mostrati solo i primi 32 KiB. Gli agenti possono continuare a leggere in blocchi.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Percorso relativo al progetto",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Rilascia per importare",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "L\'agente ha un\'esecuzione attiva. Rimuovendolo si annulla tale esecuzione; gli altri agenti continuano.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "L\'agente smetterà di ricevere nuovi messaggi di progetto.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Richiesta risposta pubblica",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Riprendi"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Trasmissione",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("Consegna"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("Mirato"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Annullato"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("Completato"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Decidere"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("Consegna"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Fallito"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "ID esecuzione",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("Interrotto"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Limite superato",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Saltato"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage(
      "Decisione",
    ),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("Consegna"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Rispondi"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Preparazione"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("In coda"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("In esecuzione"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage("Timeout"),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Esecuzioni"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Salva come artefatto del progetto",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Verrà salvato come artefatto del progetto",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Cerca"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage("Cerca agenti"),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Cerca nome, percorso e contenuto",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Cerca gli agenti disponibili",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Invio"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Abilità"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Accesso agli artefatti",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Nessuno"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Leggi"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Leggi e scrivi",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Segmenti di riepilogo",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("sistema"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Strumenti"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Annullato"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("Completato"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Creato"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Decidere"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("Consegna"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage(
      "Dispacciamento",
    ),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Fallito"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Parziale"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Rispondi"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "Impossibile aprire questo file con un\'app di sistema.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "Impossibile leggere questa versione",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("sconosciuto"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento dell\'accesso agli artefatti",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Utente"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Area di lavoro del progetto",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Scrivi la nuova versione",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Fornisci i tuoi suggerimenti e feedback",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Fornitore"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Informazioni sul fornitore",
    ),
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
    "referenceAudio": MessageLookupByLibrary.simpleMessage(
      "Audio di riferimento",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Aggiorna"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Aggiorna strumenti",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Aggiorna cataloghi",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento cataloghi…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("Solo MCP remoto"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Rimuovi il file",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Rimuovi l\'immagine",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Rimuovi il server MCP",
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
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Ripristina"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Turni recenti mantenuti",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Esegui verifica",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Salva"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage(
      "Salva e connettiti",
    ),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Salva modifiche"),
    "saveImage": MessageLookupByLibrary.simpleMessage("Salva immagine"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "Impossibile salvare nella galleria",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Salvataggio..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Cerca bot"),
    "searchChats": MessageLookupByLibrary.simpleMessage("Cerca conversazioni"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Cerca server MCP",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage(
      "Strumenti di ricerca",
    ),
    "searchMemory": MessageLookupByLibrary.simpleMessage("Cerca nella memoria"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Cerca competenze"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Seleziona almeno un bot.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Seleziona bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Seleziona lingua"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Seleziona modello:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Seleziona fornitore:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Seleziona tema"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Invia"),
    "settings": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "shareImage": MessageLookupByLibrary.simpleMessage("Condividi l\'immagine"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Immagine da Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage("Mostra chiave API"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Se abilitato, le conversazioni del progetto mostrano l\'utilizzo dei token e i dettagli delle chiamate a strumenti, MCP e altri servizi nei messaggi degli agenti.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage(
      "Mostra informazioni sul bot",
    ),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Mostra barra laterale",
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
    "skillImportFailed": m72,
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
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Luogo di installazione",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Posizione di installazione copiata negli appunti",
    ),
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
    "speechGenerated": MessageLookupByLibrary.simpleMessage(
      "Discorso generato",
    ),
    "speechResult": MessageLookupByLibrary.simpleMessage("Risultato vocale"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Invia un messaggio nel campo di testo sotto per iniziare a chattare",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Inizia a chattare"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "Avvio non riuscito. Riprova.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("Avvio…"),
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
    "stop": MessageLookupByLibrary.simpleMessage("Fermati"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage(
      "Fermati e continua",
    ),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Interrompere la generazione prima di partire?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage(
          "La risposta parziale verrà conservata.",
        ),
    "stopping": MessageLookupByLibrary.simpleMessage("Fermarsi..."),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informazioni strutturate sul processo",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Invia feedback"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Messaggi riassunti",
    ),
    "supported": MessageLookupByLibrary.simpleMessage("Supportato"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Supporta MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Supporta le abilità",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt di sistema:"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Fotocamera"),
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
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Elaborazione…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Utilizzo dei token"),
    "tokens": MessageLookupByLibrary.simpleMessage("token"),
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
    "totalTokens": MessageLookupByLibrary.simpleMessage("Token totali"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Prova una ricerca diversa o crea un nuovo elemento.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Digitando..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare i bot",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare le chat",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare i messaggi",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage(
      "Bot non disponibile",
    ),
    "uninstall": MessageLookupByLibrary.simpleMessage("Disinstalla"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Disinstalla competenza",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Carica file"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Carica immagine"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Accordo utente"),
    "version": MessageLookupByLibrary.simpleMessage("Versione 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Video generato"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare il video",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Risultato video"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Vedi riepilogo"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Aspetta che la generazione finisca prima di lasciare questa chat.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Aspetta che la generazione finisca.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Ricerca sul Web"),
  };
}
