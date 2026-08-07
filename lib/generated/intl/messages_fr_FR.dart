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
      "Êtes-vous sûr de vouloir effacer tout l\'historique de discussion avec \"${botName}\"? Cette action ne peut pas être annulée.";

  static String m7(botName) =>
      "La suppression du bot supprimera également toutes les discussions associées. Êtes-vous sûr de vouloir supprimer ${botName}?";

  static String m8(botName) =>
      "La suppression de la discussion effacera tout l\'historique des conversations. Êtes-vous sûr de vouloir supprimer la discussion avec ${botName}?";

  static String m9(name) =>
      "Désinstaller ${name} ? Les associations aux Bots seront également supprimées.";

  static String m10(name) =>
      "Autoriser ${name} à enregistrer ses scripts déclarés comme outils. Chaque appel nécessitera toujours une approbation.";

  static String m11(language) => "Langue définie sur ${language}";

  static String m12(minutes) => "il y a ${minutes} minutes";

  static String m13(count) => "${count} modèles récupérés avec succès";

  static String m14(count) => "${count} exécutions de commandes";

  static String m15(duration) => "Durée ${duration}";

  static String m16(count) => "${count} modifications de fichiers";

  static String m17(count) => "${count} appels d’outil";

  static String m18(error) => "Échec de récupération de la réponse: ${error}";

  static String m19(error) => "Impossible d’importer la compétence : ${error}";

  static String m20(duration) => "Réflexion terminée · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("À propos de Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Ajouter un Bot"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Ajouter une compétence"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajuster la taille de police de l\'application",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajuster la Taille de Police",
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
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - Assistant de Chat IA",
    ),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automatique"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permet aux modèles compatibles d’activer cette compétence à partir de sa description.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Ce fournisseur ne prend en charge que les compétences manuelles.",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar du Bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Activez les outils MCP pour cet agent. Les appels nécessitent une confirmation par défaut.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nom du Bot"),
    "botSkills": MessageLookupByLibrary.simpleMessage("Compétences"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Choisissez les instructions réutilisables disponibles pour ce Bot.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Modifier l’avatar"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "État d’exécution du chat",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "Historique de discussion effacé",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Discussions"),
    "clear": MessageLookupByLibrary.simpleMessage("Effacer"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Effacer la Discussion"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Effacer l\'historique de discussion",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Effacer les compétences épinglées",
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
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Confirmer la suppression",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Informations de contact (facultatif)",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Équipe Stars"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Fournisseur personnalisé...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Mode Sombre"),
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
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Désactiver sans confirmation pour tous",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Désactiver tous les outils",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Désactiver les scripts",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "editBot": MessageLookupByLibrary.simpleMessage("Modifier le Bot"),
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
    "enableSkillScriptsDescription": m10,
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
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la génération",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Échec de la génération · Réponse partielle conservée",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Aide et Commentaires",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Accueil"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importer un dossier de compétences",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importer un ZIP de compétences",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importation de la compétence…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Jetons d’entrée"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Installer la mise à jour",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("À l\'instant"),
    "languageChanged": m11,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de Langue",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Mode Clair"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Par message"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Si nécessaire, sélectionnez la compétence dans la zone de message.",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Sans confirmation",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Serveurs MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Connectez des serveurs MCP et découvrez leurs catalogues d’outils. Configurez les outils après avoir créé un agent.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage("Tapez un message..."),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Compétences"),
    "minutesAgo": m12,
    "model": MessageLookupByLibrary.simpleMessage("Modèle"),
    "modelsRetrievedSuccess": m13,
    "name": MessageLookupByLibrary.simpleMessage("Nom"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nom mis à jour"),
    "newChat": MessageLookupByLibrary.simpleMessage("Nouvelle Discussion"),
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
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Aucune compétence correspondante trouvée",
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
    "outputTokens": MessageLookupByLibrary.simpleMessage("Jetons de sortie"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Réponse partielle",
    ),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Mettre en pause la génération",
    ),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Épingler la sélection pour cette conversation",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Épinglée"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord saisir la clé API",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Aperçu de l\'effet du texte",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de Confidentialité",
    ),
    "processCommandCount": m14,
    "processDuration": m15,
    "processFileCount": m16,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informations sur le processus",
    ),
    "processToolCount": m17,
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Fournissez vos suggestions et commentaires",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Fournisseur"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Raisonnement terminé",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Raisonnement en cours",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Raisonnement interrompu",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualiser les catalogues",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualisation des catalogues…",
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
    "responseError": m18,
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Lancer le test",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les modifications",
    ),
    "searchSkills": MessageLookupByLibrary.simpleMessage(
      "Rechercher des compétences",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Sélectionner un Bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Sélectionner la Langue",
    ),
    "selectModel": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le modèle:",
    ),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le fournisseur:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le Thème",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Envoyer"),
    "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Afficher les détails d’exécution dans les messages de conversation.",
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
    "skillImportFailed": m19,
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
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envoyez un message dans le champ de texte ci-dessous pour commencer à discuter",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage(
      "Commencez à discuter",
    ),
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
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informations structurées sur le processus",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage(
      "Soumettre les Commentaires",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Invite Système"),
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
    "thinkingCompletedWithDuration": m20,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage(
      "Réflexion en cours…",
    ),
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
    "typing": MessageLookupByLibrary.simpleMessage("En train d\'écrire..."),
    "uninstall": MessageLookupByLibrary.simpleMessage("Désinstaller"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Désinstaller la compétence",
    ),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Importer un fichier"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Importer une image"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Accord Utilisateur"),
    "version": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
  };
}
