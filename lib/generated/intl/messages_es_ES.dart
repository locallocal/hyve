// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es_ES locale. All the
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
  String get localeName => 'es_ES';

  static String m0(name) => "Bot \"${name}\" ha sido añadido";

  static String m1(botName) => "\"${botName}\" ha sido eliminado";

  static String m2(botName) =>
      "¡Hola! Soy ${botName}, un asistente de IA. Puedes hacerme cualquier pregunta y haré lo posible por ayudarte.";

  static String m3(botName) => "${botName} está escribiendo...";

  static String m4(botName) => "Bot ${botName} ha sido actualizado";

  static String m5(botName) => "Chat con ${botName} eliminado";

  static String m6(botName) =>
      "¿Estás seguro de que quieres borrar todo el historial de chat con \"${botName}\"? Esta acción no se puede deshacer.";

  static String m7(botName) =>
      "Eliminar el bot también eliminará todos los chats asociados. ¿Estás seguro de que quieres eliminar ${botName}?";

  static String m8(botName) =>
      "Eliminar el chat borrará todo el historial de conversación. ¿Estás seguro de que quieres eliminar el chat con ${botName}?";

  static String m9(name) =>
      "¿Desinstalar ${name}? También se eliminarán las vinculaciones con bots.";

  static String m10(name) =>
      "Permitir que ${name} registre sus scripts declarados como herramientas. Cada llamada seguirá requiriendo aprobación.";

  static String m11(language) => "Idioma cambiado a ${language}";

  static String m12(minutes) => "hace ${minutes} minutos";

  static String m13(count) => "Se han recuperado ${count} modelos con éxito";

  static String m14(count) => "${count} ejecuciones de comandos";

  static String m15(duration) => "Duración ${duration}";

  static String m16(count) => "${count} cambios de archivos";

  static String m17(count) => "${count} llamadas a herramientas";

  static String m18(error) => "Error al obtener respuesta: ${error}";

  static String m19(error) => "No se pudo importar la habilidad: ${error}";

  static String m20(duration) => "Pensamiento completado · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Acerca de Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Añadir bot"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Añadir habilidad"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamaño de fuente de la aplicación",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamaño de fuente",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Se añadieron todas las habilidades instaladas.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Siempre activa"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Inserta esta habilidad en cada solicitud de texto.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Siempre activa"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Dirección API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("Clave API"),
    "apiType": MessageLookupByLibrary.simpleMessage("Tipo de API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Una aplicación de chat con IA simple pero potente que te permite chatear con inteligencia artificial en cualquier momento y lugar.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - Asistente de chat IA",
    ),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automática"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permite que los modelos compatibles activen esta habilidad según su descripción.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Este proveedor solo admite habilidades manuales.",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar del bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("Nombre del bot"),
    "botSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Elige las instrucciones reutilizables disponibles para este bot.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Cambiar avatar"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "Estado de ejecución del chat",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "Historial de chat borrado",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "clear": MessageLookupByLibrary.simpleMessage("Borrar"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Limpiar chat"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Borrar historial de chat",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Borrar habilidades fijadas",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Haz clic en + en la esquina superior derecha para añadir un bot",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Haz clic en Nuevo chat para crear una conversación",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Ejecuciones de comandos",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Confirmar eliminación",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Información de contacto (opcional)",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Equipo Stars"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Proveedor personalizado...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
    "deepThinking": MessageLookupByLibrary.simpleMessage(
      "Razonamiento profundo",
    ),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Eres un asistente de IA útil. Por favor, responde en español.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Eliminar bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Eliminar chat"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "Acerca de e información legal",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Apariencia e idioma",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Cambia tu avatar y nombre para mostrar.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("General"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Ayuda y soporte",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Información personal",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Los cambios se aplican de inmediato y se guardan localmente.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Gestiona tu perfil, apariencia, idioma y soporte de la aplicación.",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Detalles"),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Desactivar scripts",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editBot": MessageLookupByLibrary.simpleMessage("Editar bot"),
    "editName": MessageLookupByLibrary.simpleMessage("Editar nombre"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Error al obtener respuesta: el servidor devolvió una respuesta vacía",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Activar scripts",
    ),
    "enableSkillScriptsDescription": m10,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "¿Activar scripts aislados?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "Introducir dirección API...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage(
      "Introducir clave API...",
    ),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "Introduzca el nombre del bot...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Introduce un nombre para mostrar",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduce un nuevo nombre",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Introduzca el nombre del proveedor...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Introducir prompt del sistema...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Error al cargar el contenido, por favor intente más tarde.",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage(
      "Estado de ejecución",
    ),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Por favor, ingrese el contenido de los comentarios",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Por favor, cuéntenos sus pensamientos, problemas o sugerencias para ayudarnos a mejorar la aplicación",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Ingrese sus comentarios aquí...",
    ),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Información sobre comentarios",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Error al enviar, por favor intente más tarde",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "¡Gracias por sus comentarios!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Obtener lista de modelos",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Por favor, obtenga primero la lista de modelos",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("Estado de archivos"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Música"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Voz"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Por favor, complete el nombre del bot, dirección API y clave API",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage(
      "Tamaño de fuente",
    ),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Tamaño de fuente actualizado",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Error de generación",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Error de generación · Se conserva la respuesta parcial",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Ayuda y Comentarios",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Inicio"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importar carpeta de habilidades",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importar ZIP de habilidades",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importando habilidad…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Tokens de entrada"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Instalar actualización",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Ahora mismo"),
    "languageChanged": m11,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Ajustes de idioma",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Por mensaje"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Selecciona la habilidad en el campo de mensaje cuando la necesites.",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Servidores MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Conecta herramientas MCP remotas y controla cuáles pueden usar los agentes.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Escribe un mensaje...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "minutesAgo": m12,
    "model": MessageLookupByLibrary.simpleMessage("Modelo"),
    "modelsRetrievedSuccess": m13,
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nombre actualizado"),
    "newChat": MessageLookupByLibrary.simpleMessage("Nuevo chat"),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "No se añadieron habilidades",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Añade las habilidades instaladas que necesite este bot.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "No hay bots disponibles",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Aún no hay chats"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "No se devolvió contenido",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "No se encontraron habilidades coincidentes",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "No se han recuperado modelos",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "No hay habilidades instaladas",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Importa una carpeta de Agent Skills o un ZIP que contenga SKILL.md.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Tokens de salida"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Respuesta parcial",
    ),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Pausar generación",
    ),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fijar selección en esta conversación",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fijada"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca primero la clave API",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Vista previa del texto",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "processCommandCount": m14,
    "processDuration": m15,
    "processFileCount": m16,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Información del proceso",
    ),
    "processToolCount": m17,
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Proporcione sus sugerencias y comentarios",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Proveedor"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Razonamiento completado",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Razonamiento en curso",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Razonamiento interrumpido",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualizar catálogos",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualizando catálogos…",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Quitar habilidad"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "Respuesta cancelada",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Detenido · Se conserva la respuesta parcial",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Restablecer valores predeterminados",
    ),
    "responseError": m18,
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Ejecutar prueba",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Guardar cambios"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Buscar habilidades"),
    "selectBot": MessageLookupByLibrary.simpleMessage("Seleccionar bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Seleccionar idioma",
    ),
    "selectModel": MessageLookupByLibrary.simpleMessage("Seleccionar modelo:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Seleccionar proveedor:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Seleccionar tema"),
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Mostrar detalles de ejecución en los mensajes de la conversación.",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Recursos disponibles",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage(
      "Compatibilidad",
    ),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Este ejemplo debe activar la habilidad",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Solicitud de usuario de ejemplo",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Resultado de activación",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de la habilidad",
    ),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Huella del contenido"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Desactivada"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Activada"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Archivos"),
    "skillImportFailed": m19,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Habilidad importada",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Instala instrucciones reutilizables y vincúlalas a tus bots.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "Esta versión no ejecuta scripts ni comandos de las habilidades.",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Editor"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Archivos de referencia disponibles",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md se carga únicamente como una instrucción controlada; los scripts, comandos y herramientas externas permanecen desactivados.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Entorno aislado de scripts disponible",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Los scripts permanecen desactivados hasta que los apruebes. Cada ejecución sigue requiriendo aprobación.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Scripts de habilidades no disponibles",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Esta plataforma no ofrece el aislamiento necesario. Las instrucciones y recursos siguen disponibles.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Configuración de scripts actualizada.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Los scripts están instalados, pero su ejecución está desactivada.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Scripts activados",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Firma"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Firma no válida",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Editor desconocido",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage("Sin firma"),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Firma verificada",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Origen"),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("Automática"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Actualización disponible",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("Notificar"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Fijada"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Política de actualización",
    ),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Usuario"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Notas de validación",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Versión"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envía un mensaje en el campo de texto de abajo para comenzar a chatear",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Empieza a chatear"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Adjuntado"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Completado"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Fallido"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Generado"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("En curso"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Registrado"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Ejecutándose"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Información estructurada del proceso",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage(
      "Enviar Comentarios",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt del sistema"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Probar descripción",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Tema configurado en modo oscuro",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Tema configurado en modo claro",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Tema configurado para seguir el sistema",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("Ajustes de tema"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Pensamiento completado",
    ),
    "thinkingCompletedWithDuration": m20,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Pensando…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage(
      "Llamadas a herramientas",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Escribiendo..."),
    "uninstall": MessageLookupByLibrary.simpleMessage("Desinstalar"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Desinstalar habilidad",
    ),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Subir archivo"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Subir imagen"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Acuerdo de usuario"),
    "version": MessageLookupByLibrary.simpleMessage("Versión 1.0.0"),
  };
}
