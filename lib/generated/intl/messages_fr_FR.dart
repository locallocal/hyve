// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr_FR locale. All the
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
  String get localeName => 'fr_FR';

  static String m0(name) => "Bot \"${name}\" a été ajouté";

  static String m1(botName) => "\"${botName}\" a été supprimé";

  static String m2(botName) =>
      "Bonjour ! Je suis ${botName}, un assistant IA. N\'hésitez pas à me poser des questions, je ferai de mon mieux pour vous aider.";

  static String m3(botName) => "${botName} est en train d\'écrire...";

  static String m4(botName) => "Bot ${botName} a été mis à jour";

  static String m5(botName) => "Discussion avec ${botName} supprimée";

  static String m6(botName) =>
      "La suppression du bot supprimera également toutes les discussions associées. Êtes-vous sûr de vouloir supprimer ${botName}?";

  static String m7(botName) =>
      "La suppression de la discussion effacera tout l\'historique des conversations. Êtes-vous sûr de vouloir supprimer la discussion avec ${botName}?";

  static String m8(name) =>
      "Supprimer ${name} ? Son catalogue d\'outils mis en cache et ses informations d\'identification sécurisées seront également supprimés.";

  static String m9(name) =>
      "Désinstaller ${name} ? Les associations aux Bots seront également supprimées.";

  static String m10(year) => "© ${year} Équipe Hyve";

  static String m11(error) => "Impossible de créer le chat : ${error}";

  static String m12(error) => "Impossible de créer le projet : ${error}";

  static String m13(error) => "Impossible de supprimer le chat : ${error}";

  static String m14(milliseconds) => "${milliseconds} ms";

  static String m15(seconds) => "${seconds}s";

  static String m16(name) =>
      "Autoriser ${name} à enregistrer ses scripts déclarés comme outils. Chaque appel nécessitera toujours une approbation.";

  static String m17(count) => "${count} fichiers";

  static String m18(error) => "Échec de la génération de l\'image : ${error}";

  static String m19(error) => "Impossible de générer de la musique : ${error}";

  static String m20(error) => "Impossible de générer la parole : ${error}";

  static String m21(error) => "Impossible de générer la vidéo : ${error}";

  static String m22(count) => "${count} articles";

  static String m23(language) => "Langue définie sur ${language}";

  static String m24(error) => "Échec de la connexion MCP : ${error}";

  static String m25(count) => "${count} configuré (valeurs masquées)";

  static String m26(minutes) => "il y a ${minutes} minutes";

  static String m27(count) => "${count} modèles récupérés avec succès";

  static String m28(count) => "${count} exécutions de commandes";

  static String m29(duration) => "Durée ${duration}";

  static String m30(count) => "${count} modifications de fichiers";

  static String m31(count) => "${count} appels d’outil";

  static String m32(id) => "Agent ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Artefact ${artifactId}";

  static String m34(code) => "L\'opération de l\'artefact a échoué (${code})";

  static String m35(ids) => "Versions d\'artefacts : ${ids}";

  static String m36(index) => "Pièce jointe ${index}";

  static String m37(count) => "${count} en attente";

  static String m38(path) =>
      "Supprimer toutes les versions de ${path} ? Les artefacts référencés par un message ou une diffusion ne peuvent pas être supprimés.";

  static String m39(depth) => "Profondeur de livraison : ${depth}";

  static String m40(id, status) => "Cycle de livraison : ${id} · ${status}";

  static String m41(value) => "Durée : ${value}";

  static String m42(value) => "Erreur : ${value}";

  static String m43(id) => "Événement : ${id}";

  static String m44(sequence) => "Événement #${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} artefact', other: '${count} artefacts')}";

  static String m46(code) => "Échec de la mise à jour du membre (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} est passé de ${previous} à ${current}";

  static String m48(agentId, current) => "${agentId} est maintenant ${current}";

  static String m49(id) => "Identifiant du message : ${id}";

  static String m50(code) => "Échec de l\'envoi du message (${code})";

  static String m51(sequence) => "Message #${sequence}";

  static String m52(processed, latest) =>
      "Traité ${processed} / dernier ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} destinataire', other: '${count} destinataires')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} message de référence', other: '${count} messages de référence')}";

  static String m55(name) => "Supprimer ${name} ?";

  static String m56(name) => "Faites glisser pour réorganiser ${name}";

  static String m57(sequence) => "Répondre au message #${sequence}";

  static String m58(id) => "Exécution racine : ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} exécution', other: '${count} exécutions')}";

  static String m60(runId) => " · exécution ${runId}";

  static String m61(value) => "Source : ${value}";

  static String m62(id) => "Exécution source : ${id}";

  static String m63(value) => "Exécutions cibles : ${value}";

  static String m64(input, output) => "Entrée ${input} · sortie ${output}";

  static String m65(id, status) => "Tournez : ${id} · ${status}";

  static String m66(mime, digest) =>
      "L\'aperçu dans l\'application n\'est pas pris en charge pour ce type. \n MIME : ${mime} \n SHA-256 : ${digest}";

  static String m67(version, actor, run) =>
      "Version ${version} · agent ${actor}${run}";

  static String m68(error) => "Échec de récupération de la réponse: ${error}";

  static String m69(error) => "Impossible d\'enregistrer l\'image : ${error}";

  static String m70(count) => "${count} sélectionné";

  static String m71(error) => "Impossible de partager l\'image : ${error}";

  static String m72(error) => "Impossible d’importer la compétence : ${error}";

  static String m73(duration) => "Réflexion terminée · ${duration}";

  static String m74(error) => "Erreur de lecture vidéo : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("À propos de Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "La demande active ne peut pas être annulée. Attendez que ça se termine.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "La demande active ne peut pas être arrêtée",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Pièce jointe"),
    "addBot": MessageLookupByLibrary.simpleMessage("Ajouter un Bot"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage(
      "Ajouter un serveur MCP",
    ),
    "addSkill": MessageLookupByLibrary.simpleMessage("Ajouter une compétence"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajuster la taille de police de l\'application",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajuster la Taille de Police",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ouvrez un projet utilisant cet agent pour consulter et gérer son contexte et sa mémoire.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Mémoire de l’agent"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Évolution automatique de la mémoire",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "La mémoire à long terme appartient à cet agent et peut être réutilisée entre les projets.",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Toutes les compétences installées ont été ajoutées.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Toujours active"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Insère cette compétence dans chaque requête textuelle.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Toujours active"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Adresse API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("Clé API"),
    "apiType": MessageLookupByLibrary.simpleMessage("Type d\'API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Une application de chat IA simple mais puissante qui vous permet de discuter avec l\'IA n\'importe quand, n\'importe où.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Hyve - Assistant de Chat IA",
    ),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "Prompt système",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Géré par Hyve et ajouté à chaque requête au modèle. Les identifiants de l’agent et de la conversation en cours sont ajoutés à l’exécution et ne sont pas modifiables.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("Fichiers joints"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("Images jointes"),
    "attachments": MessageLookupByLibrary.simpleMessage("Pièces jointes"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automatique"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permet aux modèles compatibles d’activer cette compétence à partir de sa description.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ce fournisseur ne prend en charge que les compétences manuelles.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Mémoire automatique",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "Les résumés automatiques peuvent être inexacts. Le message actuel est toujours prioritaire.",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Retour à l\'utilisation quotidienne",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Informations de base",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar du Bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage(
      "Informations sur le bot",
    ),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Activez les outils MCP pour cet agent. Les appels nécessitent une confirmation par défaut.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nom du Bot"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "La recherche filtre la liste par nom de bot.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Compétences"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Choisissez les instructions réutilisables disponibles pour ce Bot.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Ce bot est indisponible",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Modifier l’avatar"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Enregistré"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "La recherche correspond aux noms des robots et au dernier message.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Discussions"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage(
      "Effacer les pièces jointes",
    ),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Effacer la mémoire automatique",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Effacer la Discussion"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Effacer les compétences épinglées",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Effacer la recherche"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez un jour pour afficher l\'utilisation horaire",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Cliquez sur + en haut à droite pour ajouter un bot",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Cliquez sur Nouvelle discussion pour créer une conversation",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Exécutions de commandes",
    ),
    "compactNow": MessageLookupByLibrary.simpleMessage("Compresser maintenant"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Organisation du contexte…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "État de compression",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Confirmer la suppression",
    ),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Informations de contact (facultatif)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Contexte et mémoire",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "Contexte compressé",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage(
      "Fenêtre de contexte",
    ),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Résumé de la conversation",
    ),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Part des jetons par conversation",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("Copier la clé API"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Copier l\'emplacement d\'installation",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Créer un projet"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Créer…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Temps de création"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Fournisseur personnalisé...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Utilisation quotidienne",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Mode Sombre"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Cette base de données a été créée par une version plus récente de Hyve. Mettez l’application à jour avant de l’ouvrir.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "Le contrôle d’intégrité de la base de données a échoué et la restauration depuis la sauvegarde de cette version n’a pas abouti.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage(
      "Réflexion approfondie",
    ),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Vous êtes un assistant IA utile. Veuillez répondre en français.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Supprimer le bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage(
      "Supprimer la Discussion",
    ),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "Supprimer le serveur MCP",
    ),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "À propos et mentions légales",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Apparence et langue",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Modifiez votre avatar et votre nom d’affichage.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Général"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Aide et assistance",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Informations personnelles",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Les modifications prennent effet immédiatement et sont enregistrées localement.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Gérez votre profil, l’apparence, la langue et l’assistance de l’application.",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Détails"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("Prêt à jouer"),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Prêt à prévisualiser",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Désactiver sans confirmation pour tous",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Désactiver tous les outils",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Désactiver les scripts",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "editBot": MessageLookupByLibrary.simpleMessage("Modifier le Bot"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "Modifier le serveur MCP",
    ),
    "editMemory": MessageLookupByLibrary.simpleMessage("Modifier la mémoire"),
    "editName": MessageLookupByLibrary.simpleMessage("Modifier le Nom"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Échec de récupération de la réponse: le serveur a renvoyé une réponse vide",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Activer sans confirmation pour tous",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Activer tous les outils",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Activer les scripts",
    ),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "Activer les scripts isolés ?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'adresse API...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage("Entrez la clé API..."),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom du bot...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Saisissez un nom d’affichage",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un nouveau nom",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom du fournisseur...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'invite système...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Erreur lors du chargement du contenu, veuillez réessayer plus tard.",
    ),
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Utilisation estimée",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage("État d’exécution"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le contenu des commentaires",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Veuillez nous faire part de vos réflexions, problèmes ou suggestions pour nous aider à améliorer l\'application",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Entrez vos commentaires ici...",
    ),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Informations sur les commentaires",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'envoi, veuillez réessayer plus tard",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "Merci pour vos commentaires !",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Récupérer la liste des modèles",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord récupérer la liste des modèles",
    ),
    "fileAttachment": MessageLookupByLibrary.simpleMessage("Fichier joint"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Résultat du fichier"),
    "fileStatus": MessageLookupByLibrary.simpleMessage("État des fichiers"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Musique"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Voix"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Vidéo"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Veuillez remplir le nom du bot, l\'adresse API et la clé API",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Suivre le Système"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage(
      "Taille de Police",
    ),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Taille de police mise à jour",
    ),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Oublier"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("Image générée"),
    "generating": MessageLookupByLibrary.simpleMessage("Générer…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Génération d\'image, veuillez patienter...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la génération",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Échec de la génération · Réponse partielle conservée",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Aide et Commentaires",
    ),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("Masquer la clé API"),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Masquer les informations du robot",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Masquer la barre latérale",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Accueil"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Utilisation horaire",
    ),
    "idle": MessageLookupByLibrary.simpleMessage("Inactif"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage(
      "Pièce jointe d\'image",
    ),
    "imageResult": MessageLookupByLibrary.simpleMessage("Résultat de l\'image"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Image enregistrée dans la galerie",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Taille de l\'image"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Style d\'image"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importer un dossier de compétences",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importer un ZIP de compétences",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importation de la compétence…",
    ),
    "includesDuration": MessageLookupByLibrary.simpleMessage(
      "Comprend la durée",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Jetons d’entrée"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Installer la mise à jour",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Le résumé généré n’a pas passé la validation",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("Aller au dernier"),
    "justNow": MessageLookupByLibrary.simpleMessage("À l\'instant"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de Langue",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Mode Clair"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'ouvrir ce lien.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "Les serveurs MCP locaux basés sur les processus restent désactivés en attendant un examen de la sécurité de la plateforme.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Gérer la mémoire"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Par message"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Si nécessaire, sélectionnez la compétence dans la zone de message.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "Jeton d\'accès OAuth/Bearer",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Arguments"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Saisissez un argument par ligne.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage(
      "Authentification",
    ),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation requise",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Commande"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Nom de l\'exécutable ou chemin absolu. La commande s\'exécute directement sans shell.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de communication",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("Connecté"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Connexion"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Erreur de connexion",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("Connexion"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Déconnecté"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Point de terminaison HTTP diffusable",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage(
      "Variables d\'environnement",
    ),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Entrez une KEY=VALUE par ligne. Les valeurs sont stockées dans le magasin d\'informations d\'identification sécurisé du système d\'exploitation ; laissez vide lors de l\'édition pour conserver les valeurs existantes.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Les points de terminaison MCP distants doivent utiliser HTTPS.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "Les variables d\'environnement doivent utiliser une entrée KEY=VALUE par ligne.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "Les serveurs stdio exécutent des commandes sur cet ordinateur. Ajoutez uniquement des serveurs et des variables d\'environnement en qui vous avez confiance.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Sécurité des processus locaux",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Sans confirmation",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Aucun"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Les points de terminaison MCP privés, locaux et lien-local sont bloqués.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage(
      "ID de processus (PID)",
    ),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage(
      "Ne fonctionne pas",
    ),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage(
      "En cours d\'exécution",
    ),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("Commencé à"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage(
      "État du processus",
    ),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Les magasins Hyve ont découvert les catalogues d\'outils. Activer les outils individuels lors de la modification d\'un agent ; seul cet agent peut les exposer au modèle.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "La requête MCP a expiré.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Variables d\'environnement sécurisées",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage(
      "Détails du serveur",
    ),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("Nom du serveur"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Serveurs MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Connectez des serveurs MCP et découvrez leurs catalogues d’outils. Configurez les outils après avoir créé un agent.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (canaux du système d\'exploitation)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Processus local et communication",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "La commande stdio MCP n\'a pas pu être démarrée.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Laissez vide pour conserver les informations d\'identification sécurisées existantes.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Stocké dans le magasin d\'informations d\'identification sécurisé du système d\'exploitation.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Cet outil a un schéma d\'entrée non pris en charge et ne peut pas être sélectionné.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Outils"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Transports"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (processus local)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "Le serveur MCP utilise une version de protocole non prise en charge.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Mémoire"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Artefact"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "La mémoire a changé ; réessayez",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Correction"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Décision"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Fait"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Préférence"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("Question ouverte"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Tâche"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Utilisez @ pour mentionner au moins un agent de projet.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Message copié dans le presse-papiers",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Saisissez un message et mentionnez des agents avec @...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Compétences"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("Fichier"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Image"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Multimodal"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Musique"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("Temps réel"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Discours"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Texte"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Vidéo"),
    "model": MessageLookupByLibrary.simpleMessage("Modèle"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuration du modèle",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Taille du contexte du modèle",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Entrée"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Sortie"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage(
      "Heure de modification",
    ),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Musique générée"),
    "musicResult": MessageLookupByLibrary.simpleMessage("Résultat musical"),
    "name": MessageLookupByLibrary.simpleMessage("Nom"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nom mis à jour"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Les nouveaux robots restent dans l\'espace de travail pour être modifiés.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Nouvelle Discussion"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Un nouveau chat s\'ouvre directement dans l\'espace de travail.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Nouveau projet"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "Cet agent ne possède pas encore de mémoire à long terme.",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "Aucun outil MCP connecté n’est disponible.",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Aucune compétence ajoutée",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Ajoutez les compétences installées dont ce Bot a besoin.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Aucun bot disponible",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage(
      "Pas encore de discussions",
    ),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Aucun contenu renvoyé",
    ),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Aucun résumé de la conversation n’est encore disponible.",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "Aucun robot correspondant trouvé",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "Aucun chat correspondant trouvé",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "Aucun serveur MCP correspondant trouvé",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "Aucun outil correspondant trouvé",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Aucune compétence correspondante trouvée",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Aucun serveur MCP"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Ajoutez un serveur Streamable HTTP ou Desktop Stdio pour découvrir son catalogue d\'outils.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "Aucun outil découvert. Vérifiez la connexion et actualisez.",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Aucun modèle récupéré",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "Aucune compétence installée",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Importez un dossier Agent Skills ou un fichier ZIP contenant SKILL.md.",
    ),
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "Aucune utilisation de jeton enregistrée",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("Non pris en charge"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Pas assez d’ancien contexte à compresser",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Supprimez ce chat orphelin ou recréez le bot manquant.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Jetons de sortie"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Réponse partielle",
    ),
    "pauseAudio": MessageLookupByLibrary.simpleMessage(
      "Mettre l’audio en pause",
    ),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Mettre en pause la génération",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Épingler"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Épingler la sélection pour cette conversation",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Épinglée"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Lire l’audio"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord saisir la clé API",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une description pour la génération d\'images",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Entrez une description pour la génération de musique",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Entrez une description pour la génération vocale",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Entrez une description pour la génération vidéo",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Aperçu de l\'effet du texte",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de Confidentialité",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informations sur le processus",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Actif"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Rattraper son retard",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("Rattrapé"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("Décider"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("En pause"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("Répondre"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("Sauté"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage(
      "Répondra",
    ),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Ajouter un agent"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Recherchez un agent disponible et ajoutez-le à ce projet.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Ajouter une pièce jointe",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Agent"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Mémoire de l\'agent",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Tous types"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "Cet artefact est référencé et ne peut pas être supprimé.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage(
      "Archives",
    ),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Pièce jointe",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Code"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Ensemble de données",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Document",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Généré",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("Image"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("Autre"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Vidéo"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Ce chemin de projet existe déjà.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Utilisez un chemin relatif au projet valide.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Tous les artefacts",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "Le fichier dépasse la taille limite de l\'artefact.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "Les liens symboliques ne peuvent pas être importés.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "La version actuelle a changé. Rouvrez-le avant de le modifier.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Versions d\'artefacts",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Artefacts du projet",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Parcourez les fichiers de projet, prévisualisez l\'historique des versions et ouvrez les fichiers avec les applications système.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Détails de l\'audit",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Événements d\'audit",
    ),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Retour aux messages",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Retour au dossier parent",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Tapez un message. Sans @, il sera diffusé à tous les agents actifs.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Annuler la chaîne racine",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "Les exécutions actives dans cette chaîne de messages racine, y compris les livraisons descendantes, s\'arrêteront. D\'autres chaînes continueront.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "Annuler cette chaîne de messages racine ?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage(
      "Annuler l\'exécution",
    ),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Seule cette exécution s\'arrêtera. Les autres exécutions actives du tour continueront.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "Annuler cette exécution ?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage(
      "Annuler le tour",
    ),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Chaque exécution active de ce tour s\'arrêtera. Les résultats terminés seront conservés.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "Annuler ce tour ?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Fermer"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Contenu"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Rapport de contexte",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Couvert par message",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Créer"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Nouveau texte"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Créer une version",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Décision annulée",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "La demande de décision a échoué",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Réponse de décision invalide",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "Décision expirée",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Décisions"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'artefact ?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Les agents, les compétences, la configuration et la mémoire à long terme ne sont pas supprimés.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "Agent supprimé",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Déposez les fichiers ici pour les importer",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Envoyez un message pour commencer à collaborer. Les messages sans @ sont diffusés.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Pas encore de messages",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Livraison des agents",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Message de l\'agent",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "Artefact modifié",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "Adhésion modifiée",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Décision de participation",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "Statut d\'exécution modifié",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Avis système",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Message utilisateur",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Consultez l\'historique des exécutions, les décisions de participation, l\'utilisation des jetons et les événements d\'audit.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Détails d\'exécution",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "Historique d\'exécution",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage(
      "Importer des fichiers",
    ),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Aller au dernier",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Charger les événements antérieurs",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Chargement du projet",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("Membres du projet"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Surveillez le traitement et gérez l\'ordre des agents, l\'accès aux artefacts et la participation.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Révision de la mémoire",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Un agent mentionné n\'est plus actif. Supprimez-le ou sélectionnez-le à nouveau.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Déplacer ou renommer",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Nom du projet"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Entrez un nom de projet",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Entrez un nom de projet.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Nouvel artefact de texte",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "Ce projet n\'a aucun agent actif. Les messages sont enregistrés, mais aucune réponse ne sera générée.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Aucun agent actif",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "Aucun artefact de projet correspondant",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Aucun événement d\'audit pour l\'instant",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Aucun agent n\'est disponible pour ajouter",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Aucun enregistrement d\'exécution pour l\'instant",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "Aucun agent correspondant",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Aucun membre du projet pour l\'instant",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "Aucun agent n\'a besoin d\'ajouter quoi que ce soit à ce message.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Ouvrir avec l\'application système",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("Ignorer"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Répondre",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Ignoré"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("En pause"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Aperçu et historique des versions",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Seuls les 32 premiers Ko sont affichés. Les agents peuvent continuer à lire par morceaux.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Chemin relatif au projet",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Relâchez pour importer",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "L\'agent a une exécution active. Le supprimer annule cette exécution ; d\'autres agents continuent.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "L\'agent cessera de recevoir de nouveaux messages de projet.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Réponse publique demandée",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Reprendre"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Diffusion",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("Livraison"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("Ciblé"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("Terminé"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Décider"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage(
      "En cours de livraison",
    ),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "ID d\'exécution",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("Interrompu"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Limite dépassée",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Ignoré"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("Décision"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage(
      "Livraison",
    ),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Répondre"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Préparation"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage(
      "En file d\'attente",
    ),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage(
      "En cours d\'exécution",
    ),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage("Délai expiré"),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Exécutions"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Enregistrer en tant qu\'artefact de projet",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Sera enregistré en tant qu\'artefact de projet",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage(
      "Rechercher des agents",
    ),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Rechercher le nom, le chemin et le contenu",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Rechercher les agents disponibles",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Envoi"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Compétences"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Accès aux artefacts",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Aucun"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Lire"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Lire et écrire",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Segments récapitulatifs",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("Système"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("système"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Outils"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("Terminé"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Créé"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Décider"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage(
      "En cours de livraison",
    ),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage(
      "Expédition",
    ),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Partiel"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Répondre"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'ouvrir ce fichier avec une application système.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire cette version",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("inconnu"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Mise à jour de l\'accès aux artefacts",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Utilisateur"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Espace de travail du projet",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Écrire une nouvelle version",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Fournissez vos suggestions et commentaires",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Fournisseur"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Informations sur le fournisseur",
    ),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Raisonnement terminé",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Raisonnement en cours",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Raisonnement interrompu",
    ),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Reconstruire"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage(
      "Audio de référence",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Actualiser les outils",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualiser les catalogues",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualisation des catalogues…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage(
      "MCP distant uniquement",
    ),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Supprimer le fichier",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'image",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Supprimer le serveur MCP",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage(
      "Retirer la compétence",
    ),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("Réponse annulée"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Arrêté · Réponse partielle conservée",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Rétablir les paramètres par défaut",
    ),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Restaurer"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Tours récents conservés",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Lancer le test",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage(
      "Enregistrez et connectez-vous",
    ),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les modifications",
    ),
    "saveImage": MessageLookupByLibrary.simpleMessage("Enregistrer l\'image"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'enregistrer dans la galerie",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Sauvegarde..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Rechercher des bots"),
    "searchChats": MessageLookupByLibrary.simpleMessage(
      "Rechercher des conversations",
    ),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Rechercher des serveurs MCP",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage(
      "Outils de recherche",
    ),
    "searchMemory": MessageLookupByLibrary.simpleMessage(
      "Rechercher dans la mémoire",
    ),
    "searchSkills": MessageLookupByLibrary.simpleMessage(
      "Rechercher des compétences",
    ),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez au moins un bot.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Sélectionner un Bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Sélectionner la Langue",
    ),
    "selectModel": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le modèle:",
    ),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le fournisseur:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le Thème",
    ),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Envoyer"),
    "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "shareImage": MessageLookupByLibrary.simpleMessage("Partager l\'image"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Image de Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage("Afficher la clé API"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Lorsque cette option est activée, les conversations du projet affichent l’utilisation des jetons ainsi que les détails des appels d’outils, MCP et autres pour les messages des agents.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage(
      "Afficher les informations sur le robot",
    ),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Afficher la barre latérale",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Ressources disponibles",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("Compatibilité"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Cet exemple doit activer la compétence",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Exemple de demande utilisateur",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Résultat d’activation",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage(
      "Détails de la compétence",
    ),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Empreinte du contenu"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Désactivée"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Activée"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Fichiers"),
    "skillImportFailed": m72,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Compétence importée",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Compétences"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Installez des instructions réutilisables et associez-les à vos Bots.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "Cette version n’exécute aucun script ni aucune commande provenant des compétences.",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Éditeur"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Fichiers de référence disponibles",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md est chargé uniquement comme instruction contrôlée ; les scripts, commandes et outils externes restent désactivés.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Bac à sable de scripts disponible",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Les scripts restent désactivés jusqu’à votre autorisation. Chaque exécution nécessite toujours une approbation.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Scripts de compétences indisponibles",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Cette plateforme ne fournit pas l’isolation requise. Les instructions et ressources restent disponibles.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Paramètre des scripts mis à jour.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Les scripts sont installés, mais leur exécution est désactivée.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Scripts activés",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Signature"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Signature non valide",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Éditeur inconnu",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage("Non signé"),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Signature vérifiée",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Source"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Emplacement d\'installation",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Emplacement d\'installation copié dans le presse-papiers",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("Automatique"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Mise à jour disponible",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Manuelle"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("Notifier"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Épinglée"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de mise à jour",
    ),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Utilisateur"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Notes de validation",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage("Discours généré"),
    "speechResult": MessageLookupByLibrary.simpleMessage(
      "Résultat de la parole",
    ),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envoyez un message dans le champ de texte ci-dessous pour commencer à discuter",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage(
      "Commencez à discuter",
    ),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "Échec du démarrage. Veuillez réessayer.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("Démarrage…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("Activé"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Joint"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "En attente d’approbation",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Terminé"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Refusé"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("Appel en double"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Échec"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Généré"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("En cours"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Enregistré"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Demandé"),
    "statusRunning": MessageLookupByLibrary.simpleMessage(
      "En cours d’exécution",
    ),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Ignoré"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("Délai dépassé"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Inconnu"),
    "stop": MessageLookupByLibrary.simpleMessage("Arrêtez"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage(
      "Arrêtez et continuez",
    ),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Arrêter la génération avant de partir ?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage(
          "La réponse partielle sera conservée.",
        ),
    "stopping": MessageLookupByLibrary.simpleMessage("Arrêter…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informations structurées sur le processus",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage(
      "Soumettre les Commentaires",
    ),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("Messages résumés"),
    "supported": MessageLookupByLibrary.simpleMessage("Pris en charge"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Prend en charge MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Prend en charge les compétences",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Invite Système"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Appareil photo"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Tester"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Tester la description",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Thème défini sur mode sombre",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Thème défini sur mode clair",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Thème défini pour suivre le système",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage(
      "Paramètres du Thème",
    ),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Réflexion terminée",
    ),
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage(
      "Réflexion en cours…",
    ),
    "tokenUsage": MessageLookupByLibrary.simpleMessage(
      "Utilisation des jetons",
    ),
    "tokens": MessageLookupByLibrary.simpleMessage("jetons"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Autorisé une fois",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Refusé"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Appels d’outils"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("Destructif"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("Lecture seule"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Écriture"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Intégré"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Script de compétence",
    ),
    "totalTokens": MessageLookupByLibrary.simpleMessage("Total de jetons"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Essayez une autre recherche ou créez un nouvel élément.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("En train d\'écrire..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les robots",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les discussions",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les messages",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("Bot indisponible"),
    "uninstall": MessageLookupByLibrary.simpleMessage("Désinstaller"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Désinstaller la compétence",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Désépingler"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Importer un fichier"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Importer une image"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Accord Utilisateur"),
    "version": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Vidéo générée"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger la vidéo",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Résultat vidéo"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Voir le résumé"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Attendez la fin de la génération avant de quitter ce chat.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Attendez la fin de la génération.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Recherche sur le Web"),
  };
}
