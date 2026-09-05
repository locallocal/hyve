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
      "Eliminar el bot también eliminará todos los chats asociados. ¿Estás seguro de que quieres eliminar ${botName}?";

  static String m7(botName) =>
      "Eliminar el chat borrará todo el historial de conversación. ¿Estás seguro de que quieres eliminar el chat con ${botName}?";

  static String m8(name) =>
      "¿Eliminar ${name}? También se eliminarán su catálogo de herramientas almacenado en caché y su credencial segura.";

  static String m9(name) =>
      "¿Desinstalar ${name}? También se eliminarán las vinculaciones con bots.";

  static String m10(year) => "© ${year} Equipo Hyve";

  static String m11(error) => "No se pudo crear el chat: ${error}";

  static String m12(error) => "No se pudo crear el proyecto: ${error}";

  static String m13(error) => "No se pudo eliminar el chat: ${error}";

  static String m14(milliseconds) => "${milliseconds} ms";

  static String m15(seconds) => "${seconds}s";

  static String m16(name) =>
      "Permitir que ${name} registre sus scripts declarados como herramientas. Cada llamada seguirá requiriendo aprobación.";

  static String m17(count) => "${count} archivos";

  static String m18(error) => "Error al generar imagen: ${error}";

  static String m19(error) => "No se pudo generar música: ${error}";

  static String m20(error) => "No se pudo generar voz: ${error}";

  static String m21(error) => "No se pudo generar el video: ${error}";

  static String m22(count) => "${count} artículos";

  static String m23(language) => "Idioma cambiado a ${language}";

  static String m24(error) => "Falló la conexión MCP: ${error}";

  static String m25(count) => "${count} configurado (valores ocultos)";

  static String m26(minutes) => "hace ${minutes} minutos";

  static String m27(count) => "Se han recuperado ${count} modelos con éxito";

  static String m28(count) => "${count} ejecuciones de comandos";

  static String m29(duration) => "Duración ${duration}";

  static String m30(count) => "${count} cambios de archivos";

  static String m31(count) => "${count} llamadas a herramientas";

  static String m32(id) => "Agente ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Artefacto ${artifactId}";

  static String m34(code) => "Error en la operación del artefacto (${code})";

  static String m35(ids) => "Versiones de artefactos: ${ids}";

  static String m36(index) => "Adjunto ${index}";

  static String m37(count) => "${count} pendiente";

  static String m38(path) =>
      "¿Eliminar todas las versiones de ${path}? Los artefactos a los que hace referencia un mensaje o una entrega no se pueden eliminar.";

  static String m39(depth) => "Profundidad de entrega: ${depth}";

  static String m40(id, status) => "Ejecución de entrega: ${id} · ${status}";

  static String m41(value) => "Duración: ${value}";

  static String m42(value) => "Error: ${value}";

  static String m43(id) => "Evento: ${id}";

  static String m44(sequence) => "Evento #${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} artefacto', other: '${count} artefactos')}";

  static String m46(code) => "Error en la actualización de miembros (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} cambió de ${previous} a ${current}";

  static String m48(agentId, current) => "${agentId} ahora es ${current}";

  static String m49(id) => "ID de mensaje: ${id}";

  static String m50(code) => "No se pudo enviar el mensaje (${code})";

  static String m51(sequence) => "Mensaje #${sequence}";

  static String m52(processed, latest) =>
      "Procesado ${processed} / último ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} destinatario', other: '${count} destinatarios')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} mensaje de referencia', other: '${count} mensajes de referencia')}";

  static String m55(name) => "¿Quitar ${name}?";

  static String m56(name) => "Arrastra para reordenar ${name}";

  static String m57(sequence) => "Respondiendo al mensaje #${sequence}";

  static String m58(id) => "Ejecución raíz: ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} ejecución', other: '${count} ejecuciones')}";

  static String m60(runId) => " · ejecución ${runId}";

  static String m61(value) => "Fuente: ${value}";

  static String m62(id) => "Ejecución de fuente: ${id}";

  static String m63(value) => "Ejecuciones objetivo: ${value}";

  static String m64(input, output) => "Entrada ${input} · salida ${output}";

  static String m65(id, status) => "Turno: ${id} · ${status}";

  static String m66(mime, digest) =>
      "La vista previa en la aplicación no es compatible con este tipo. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "Versión ${version} · agente ${actor}${run}";

  static String m68(error) => "Error al obtener respuesta: ${error}";

  static String m69(error) => "No se pudo guardar la imagen: ${error}";

  static String m70(count) => "${count} seleccionado";

  static String m71(error) => "No se pudo compartir la imagen: ${error}";

  static String m72(error) => "No se pudo importar la habilidad: ${error}";

  static String m73(duration) => "Pensamiento completado · ${duration}";

  static String m74(error) => "Error de reproducción de vídeo: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Acerca de Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "La solicitud activa no se puede cancelar. Espere a que termine.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "La solicitud activa no se puede detener",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Adjunto"),
    "addBot": MessageLookupByLibrary.simpleMessage("Añadir bot"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage(
      "Agregar servidor MCP",
    ),
    "addSkill": MessageLookupByLibrary.simpleMessage("Añadir habilidad"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamaño de fuente de la aplicación",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamaño de fuente",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Abre un proyecto que use este agente para ver y gestionar su contexto y memoria.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Memoria del agente"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Evolución automática de la memoria",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "La memoria a largo plazo pertenece a este agente y puede reutilizarse entre proyectos.",
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Hyve - Asistente de chat IA",
    ),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "Prompt del sistema",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Hyve lo administra y lo añade a cada solicitud al modelo. Los identificadores del agente y la conversación actuales se agregan en tiempo de ejecución y no se pueden editar.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("Archivos adjuntos"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("Imágenes adjuntas"),
    "attachments": MessageLookupByLibrary.simpleMessage("Adjuntos"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automática"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permite que los modelos compatibles activen esta habilidad según su descripción.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Este proveedor solo admite habilidades manuales.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Memoria automática",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "Los resúmenes automáticos pueden ser inexactos. El mensaje actual siempre tiene prioridad.",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Volver al uso diario",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Información básica",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar del bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage(
      "Información del bot",
    ),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Activa herramientas MCP para este agente. Las llamadas requieren confirmación de forma predeterminada.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nombre del bot"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "La búsqueda filtra la lista por nombre del bot.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Elige las instrucciones reutilizables disponibles para este bot.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Este bot no está disponible",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Cambiar avatar"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Guardado"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "La búsqueda coincide con los nombres de los bots y el último mensaje.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Chats"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Galería"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage(
      "Borrar archivos adjuntos",
    ),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Borrar memoria automática",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Limpiar chat"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Borrar habilidades fijadas",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Borrar búsqueda"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Seleccione un día para ver el uso por horas",
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
    "compactNow": MessageLookupByLibrary.simpleMessage("Compactar ahora"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Organizando el contexto…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Error"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "Estado de compactación",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Confirmar eliminación",
    ),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Información de contacto (opcional)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Contexto y memoria",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "Contexto compactado",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage(
      "Ventana de contexto",
    ),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Resumen de la conversación",
    ),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Proporción de tokens por conversación",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("Copiar clave API"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Copiar ubicación de instalación",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Crear Proyecto"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Creando…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Hora de creación"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Proveedor personalizado...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("Uso diario"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo oscuro"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Esta base de datos se creó con una versión más reciente de Hyve. Actualiza la aplicación antes de abrirla.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "La comprobación de integridad de la base de datos falló y no se pudo recuperar desde la copia de seguridad de esta versión.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage(
      "Razonamiento profundo",
    ),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Eres un asistente de IA útil. Por favor, responde en español.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Eliminar bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Eliminar chat"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "Eliminar servidor MCP",
    ),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "Acerca de e información legal",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Apariencia e idioma",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Cambia tu avatar y nombre para mostrar.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Generalidades"),
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
    "directPlayback": MessageLookupByLibrary.simpleMessage("Listo para jugar"),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Listo para obtener una vista previa",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Desactivar sin confirmación para todas",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Desactivar todas las herramientas",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Desactivar scripts",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editBot": MessageLookupByLibrary.simpleMessage("Editar bot"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "Editar servidor MCP",
    ),
    "editMemory": MessageLookupByLibrary.simpleMessage("Editar memoria"),
    "editName": MessageLookupByLibrary.simpleMessage("Editar nombre"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Error al obtener respuesta: el servidor devolvió una respuesta vacía",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Activar sin confirmación para todas",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Activar todas las herramientas",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Activar scripts",
    ),
    "enableSkillScriptsDescription": m16,
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
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Uso estimado",
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
    "fileAttachment": MessageLookupByLibrary.simpleMessage("Archivo adjunto"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Resultado del archivo"),
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
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Olvidar"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("Imagen generada"),
    "generating": MessageLookupByLibrary.simpleMessage("Generando…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Generando imagen, por favor espera...",
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
    "hideApiKey": MessageLookupByLibrary.simpleMessage("Ocultar clave API"),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Ocultar información del bot",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Ocultar barra lateral",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Inicio"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("Uso por hora"),
    "idle": MessageLookupByLibrary.simpleMessage("Inactivo"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("Imagen adjunta"),
    "imageResult": MessageLookupByLibrary.simpleMessage(
      "Resultado de la imagen",
    ),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Imagen guardada en la galería",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Tamaño de imagen"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Estilo de imagen"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importar carpeta de habilidades",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importar ZIP de habilidades",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importando habilidad…",
    ),
    "includesDuration": MessageLookupByLibrary.simpleMessage(
      "Incluye duración",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Tokens de entrada"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Instalar actualización",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "El resumen generado no superó la validación",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("Saltar a lo último"),
    "justNow": MessageLookupByLibrary.simpleMessage("Ahora mismo"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Ajustes de idioma",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "No se puede abrir este enlace.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "Los servidores MCP locales basados en procesos permanecen deshabilitados en espera de una revisión de seguridad de la plataforma.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Administrar memoria"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Por mensaje"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Selecciona la habilidad en el campo de mensaje cuando la necesites.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "Token de acceso OAuth/Bearer",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Argumentos"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese un argumento por línea.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("Autenticación"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Se requiere autorización",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Comando"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Nombre del ejecutable o ruta absoluta. El comando se ejecuta directamente sin shell.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de comunicación",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("Conectado"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Conectando"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Error de conexión",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("Conexión"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Desconectado"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Punto final HTTP transmitible",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage(
      "Variables de entorno",
    ),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese una CLAVE=VALOR por línea. Los valores se almacenan en el almacén de credenciales seguro del sistema operativo; déjelo en blanco mientras edita para mantener los valores existentes.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Los puntos finales MCP remotos deben usar HTTPS.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "Las variables de entorno deben usar una entrada KEY=VALUE por línea.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "Los servidores stdio ejecutan comandos en esta computadora. Agregue únicamente servidores y variables de entorno en los que confíe.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Seguridad de procesos locales",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Sin confirmación",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Ninguno"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Los puntos finales MCP privados, locales y de enlace local están bloqueados.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("ID de proceso (PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage(
      "No funcionando",
    ),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("Corriendo"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("Comenzó en"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage(
      "Estado del proceso",
    ),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Las tiendas Hyve descubrieron catálogos de herramientas. Habilite herramientas individuales al editar un agente; sólo ese agente puede exponerlos al modelo.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "Se agotó el tiempo de espera de la solicitud de MCP.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Variables de entorno seguras",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles del servidor",
    ),
    "mcpServerName": MessageLookupByLibrary.simpleMessage(
      "Nombre del servidor",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Servidores MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Conecta servidores MCP y descubre sus catálogos de herramientas. Configura las herramientas después de crear un agente.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (canalizaciones del sistema operativo)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Proceso y comunicación local",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo iniciar el comando stdio MCP.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Déjelo en blanco para mantener la credencial segura existente.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Almacenado en el almacén de credenciales seguro del sistema operativo.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Esta herramienta tiene un esquema de entrada no compatible y no se puede seleccionar.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Herramientas"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Transporte"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (proceso local)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "El servidor MCP utiliza una versión de protocolo no compatible.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Memoria"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Artefacto"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "La memoria cambió; inténtalo de nuevo",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Corrección"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Decisión"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Hecho"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Preferencia"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("Pregunta abierta"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Tarea"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Utilice @ para mencionar al menos un agente del proyecto.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Mensaje copiado al portapapeles",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Escribe un mensaje y menciona agentes con @...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("Archivo"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Imagen"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Multimodal"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Música"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("En tiempo real"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Discurso"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Texto"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "model": MessageLookupByLibrary.simpleMessage("Modelo"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuración del modelo",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Tamaño del contexto del modelo",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Entrada"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Salida"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage(
      "Hora de modificación",
    ),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Música generada"),
    "musicResult": MessageLookupByLibrary.simpleMessage("Resultado musical"),
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nombre actualizado"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Los nuevos bots permanecen en el espacio de trabajo para editarlos.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Nuevo chat"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Se abre un nuevo chat directamente en el espacio de trabajo.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Nuevo Proyecto"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "Este agente aún no tiene memoria a largo plazo.",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "No hay herramientas MCP conectadas disponibles.",
    ),
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
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Todavía no hay un resumen de la conversación disponible.",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "No se encontraron bots coincidentes",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "No se encontraron chats coincidentes",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "No se encontraron servidores MCP coincidentes",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "No se encontraron herramientas coincidentes",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "No se encontraron habilidades coincidentes",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Sin servidores MCP"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Agregue un servidor stdio de escritorio o HTTP Streamable para descubrir su catálogo de herramientas.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "No se descubrieron herramientas. Verifique la conexión y actualice.",
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
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "No se registró ningún uso de tokens",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("No compatible"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "No hay suficiente contexto anterior para compactar",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Elimina este chat huérfano o vuelve a crear el bot que falta.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Tokens de salida"),
    "partialResponse": MessageLookupByLibrary.simpleMessage(
      "Respuesta parcial",
    ),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("Pausar audio"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Pausar generación",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Fijar"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fijar selección en esta conversación",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fijada"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Reproducir audio"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca primero la clave API",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese una descripción para la generación de imágenes.",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese una descripción para la generación de música.",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese una descripción para la generación de voz",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Ingrese una descripción para la generación de video",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Vista previa del texto",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Información del proceso",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Activo"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Ponerse al día",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("Atrapado"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("Decidir"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("Falló"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("En pausa"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage(
      "Respondiendo",
    ),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("Saltado"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage(
      "Responderá",
    ),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Agregar agente"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Busque un agente disponible y agréguelo a este proyecto.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Agregar archivo adjunto",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Agente"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Memoria del agente",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Todos los tipos"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "Se hace referencia a este artefacto y no se puede eliminar.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage(
      "Archivo",
    ),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Adjunto",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Audio"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Código"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Conjunto de datos",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Documento",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Generado",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("Imagen"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("Otro"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Ese camino del proyecto ya existe.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Utilice una ruta válida relativa al proyecto.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Todos los artefactos",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "El archivo excede el límite de tamaño del artefacto.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "Los enlaces simbólicos no se pueden importar.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "La versión actual cambió. Vuelva a abrirlo antes de editarlo.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Versiones de artefactos",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Artefactos del proyecto",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Explore archivos de proyecto, obtenga una vista previa del historial de versiones y abra archivos con aplicaciones del sistema.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de la auditoría",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Eventos de auditoría",
    ),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Volver a mensajes",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Volver a la carpeta principal",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Escribe un mensaje. Sin @ se transmitirá a todos los agentes activos.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Cancelar cadena raíz",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "Las ejecuciones activas en esta cadena de mensajes raíz, incluidas las entregas descendientes, se detendrán. Otras cadenas continuarán.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "¿Cancelar esta cadena de mensajes raíz?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage(
      "Cancelar ejecución",
    ),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Solo se detendrá esta ejecución. Las demás ejecuciones activas del turno continuarán.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "¿Cancelar esta ejecución?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage("Cancelar turno"),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Todas las ejecuciones activas de este turno se detendrán. Los resultados completados se conservarán.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "¿Cancelar este turno?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Contenido"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Informe de contexto",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Cubierto a través de mensaje",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Crear"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Nuevo texto"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Crear versión",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Decisión cancelada",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "Solicitud de decisión fallida",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Respuesta de decisión no válida",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "Decisión agotada",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Decisiones"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar artefacto?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Los agentes, las habilidades, la configuración y la memoria a largo plazo no se eliminan.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "Agente eliminado",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Suelte los archivos aquí para importarlos",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Envía un mensaje para comenzar a colaborar. Los mensajes sin @ se transmiten.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Aún no hay mensajes",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Entrega del agente",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Mensaje del agente",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "Artefacto cambiado",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "Membresía cambiada",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Decisión de participación",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "El estado de ejecución cambió",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Aviso del sistema",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Mensaje de usuario",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Revise el historial de ejecución, las decisiones de participación, el uso de tokens y los eventos de auditoría.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de ejecución",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "Historial de ejecución",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage(
      "Importar archivos",
    ),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Saltar a lo último",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Cargar eventos anteriores",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Cargando proyecto",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage(
      "Miembros del proyecto",
    ),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Supervisar el procesamiento y gestionar el orden de los agentes, el acceso a los artefactos y la participación.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Revisión de memoria",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Un agente mencionado ya no está activo. Elimínelo o selecciónelo nuevamente.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Mover o cambiar nombre",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Nombre del proyecto"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Ingrese un nombre de proyecto",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Ingrese un nombre de proyecto.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Nuevo artefacto de texto",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "Este proyecto no tiene agentes activos. Los mensajes se guardan, pero no se generará ninguna respuesta.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Sin agentes activos",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "No hay artefactos de proyecto coincidentes",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Aún no hay eventos de auditoría",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "No hay agentes disponibles para agregar",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Aún no hay registros de ejecución",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "No hay agentes coincidentes",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Aún no hay miembros del proyecto",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "No es necesario que ningún agente agregue nada a este mensaje.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Abrir con la aplicación del sistema",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("Omitir"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Responder",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Omitido"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Pausa"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("En pausa"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Vista previa e historial de versiones",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Solo se muestran los primeros 32 KiB. Los agentes pueden seguir leyendo por partes.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Ruta relativa al proyecto",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Soltar para importar",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "El agente tiene una ejecución activa. Al quitarlo se cancela esa ejecución; los demás agentes continúan.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "El agente dejará de recibir nuevos mensajes de proyecto.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Se solicita respuesta pública",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Reanudar"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Transmisión",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("Entrega"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("Dirigido"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("Completado"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Decidir"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("Entregando"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Falló"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "ID de ejecución",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage(
      "Interrumpido",
    ),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Límite excedido",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Omitido"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("Decisión"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("Entrega"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Responder"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Preparando"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("En cola"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("En ejecución"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage(
      "Tiempo de espera agotado",
    ),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Ejecuciones"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Guardar como artefacto del proyecto",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Se guardará como un artefacto del proyecto.",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Buscar"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage(
      "Buscar agentes",
    ),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Buscar nombre, ruta y contenido",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Buscar agentes disponibles",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Enviando"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Acceso a artefactos",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Ninguno"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Leer"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Leer y escribir",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Segmentos de resumen",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("sistema"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Herramientas"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("Completado"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Creado"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Decidir"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("Entregando"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("Despacho"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Falló"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Parcial"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Respondiendo"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "No se puede abrir este archivo con una aplicación del sistema.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "No se puede leer esta versión",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("desconocido"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Actualización de acceso a artefactos",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Usuario"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Espacio de trabajo del proyecto",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Escribe una nueva versión",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Proporcione sus sugerencias y comentarios",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Proveedor"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Información del proveedor",
    ),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Razonamiento completado",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Razonamiento en curso",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Razonamiento interrumpido",
    ),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Reconstruir"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage(
      "Audio de referencia",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Actualizar herramientas",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualizar catálogos",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Actualizando catálogos…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("Solo MCP remoto"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Eliminar archivo",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Eliminar imagen",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Eliminar servidor MCP",
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
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Restaurar"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Turnos recientes conservados",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Ejecutar prueba",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage(
      "Guardar y conectar",
    ),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Guardar cambios"),
    "saveImage": MessageLookupByLibrary.simpleMessage("Guardar imagen"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo guardar en la galería",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Guardando..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Buscar bots"),
    "searchChats": MessageLookupByLibrary.simpleMessage(
      "Buscar conversaciones",
    ),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Buscar servidores MCP",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage(
      "Herramientas de búsqueda",
    ),
    "searchMemory": MessageLookupByLibrary.simpleMessage(
      "Buscar en la memoria",
    ),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Buscar habilidades"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Selecciona al menos un bot.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Seleccionar bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Seleccionar idioma",
    ),
    "selectModel": MessageLookupByLibrary.simpleMessage("Seleccionar modelo:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Seleccionar proveedor:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Seleccionar tema"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "shareImage": MessageLookupByLibrary.simpleMessage("Compartir imagen"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Imagen de Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage("Mostrar clave API"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Al activarlo, las conversaciones del proyecto muestran el uso de tokens y los detalles de herramientas, MCP y otras llamadas en los mensajes de los agentes.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage(
      "Mostrar información del bot",
    ),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Mostrar barra lateral",
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
    "skillImportFailed": m72,
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
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Ubicación de instalación",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Ubicación de instalación copiada al portapapeles",
    ),
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
    "speechGenerated": MessageLookupByLibrary.simpleMessage(
      "Discurso generado",
    ),
    "speechResult": MessageLookupByLibrary.simpleMessage(
      "Resultado del discurso",
    ),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envía un mensaje en el campo de texto de abajo para comenzar a chatear",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Empieza a chatear"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo iniciar. Inténtalo de nuevo.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("Iniciando…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("Activado"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Adjuntado"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "Esperando aprobación",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Completado"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Denegado"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage(
      "Llamada duplicada",
    ),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Fallido"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Generado"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("En curso"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Registrado"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Solicitado"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Ejecutándose"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Omitido"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("Tiempo agotado"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Desconocido"),
    "stop": MessageLookupByLibrary.simpleMessage("Detener"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage(
      "Detener y continuar",
    ),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "¿Detener generación antes de partir?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage(
          "Se mantendrá la respuesta parcial.",
        ),
    "stopping": MessageLookupByLibrary.simpleMessage("Detener…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Información estructurada del proceso",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage(
      "Enviar Comentarios",
    ),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Mensajes resumidos",
    ),
    "supported": MessageLookupByLibrary.simpleMessage("Compatible"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Admite MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Habilidades de apoyo",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt del sistema"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Cámara"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Probar"),
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
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Pensando…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Uso de tokens"),
    "tokens": MessageLookupByLibrary.simpleMessage("tokens"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Permitido una vez",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Denegado"),
    "toolCalls": MessageLookupByLibrary.simpleMessage(
      "Llamadas a herramientas",
    ),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("Destructivo"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("Solo lectura"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Escritura"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Integrado"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Script de habilidad",
    ),
    "totalTokens": MessageLookupByLibrary.simpleMessage("Tokens totales"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Pruebe una búsqueda diferente o cree un elemento nuevo.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Escribiendo..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "No se pueden cargar bots",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "No se pueden cargar chats",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "No se pueden cargar mensajes",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("Bot no disponible"),
    "uninstall": MessageLookupByLibrary.simpleMessage("Desinstalar"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Desinstalar habilidad",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Desfijar"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Subir archivo"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Subir imagen"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Acuerdo de usuario"),
    "version": MessageLookupByLibrary.simpleMessage("Versión 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Vídeo generado"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "No se pudo cargar el vídeo",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Resultado del vídeo"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Ver resumen"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Espera a que termine la generación antes de abandonar este chat.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Esperar a que termine la generación.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Búsqueda web"),
  };
}
