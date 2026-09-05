// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru_RU locale. All the
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
  String get localeName => 'ru_RU';

  static String m0(name) => "Бот \"${name}\" был добавлен";

  static String m1(botName) => "\"${botName}\" был удален";

  static String m2(botName) =>
      "Здравствуйте! Я ${botName}, ИИ-ассистент. Вы можете задать мне любой вопрос, и я постараюсь помочь вам наилучшим образом.";

  static String m3(botName) => "${botName} печатает...";

  static String m4(botName) => "Бот ${botName} был обновлен";

  static String m5(botName) => "Чат с ${botName} удален";

  static String m6(botName) =>
      "Удаление бота также удалит все связанные чаты. Вы уверены, что хотите удалить ${botName}?";

  static String m7(botName) =>
      "Удаление чата приведет к стиранию всей истории переписки. Вы уверены, что хотите удалить чат с ${botName}?";

  static String m8(name) =>
      "Удалить ${name}? Его кэшированный каталог инструментов и безопасные учетные данные также будут удалены.";

  static String m9(name) =>
      "Удалить ${name}? Привязки к ботам также будут удалены.";

  static String m10(year) => "© ${year} Команда Hyve";

  static String m11(error) => "Не удалось создать чат: ${error}";

  static String m12(error) => "Не удалось создать проект: ${error}";

  static String m13(error) => "Не удалось удалить чат: ${error}";

  static String m14(milliseconds) => "${milliseconds} мс";

  static String m15(seconds) => "${seconds} с";

  static String m16(name) =>
      "Разрешить ${name} зарегистрировать объявленные скрипты как инструменты. Каждый вызов потребует подтверждения.";

  static String m17(count) => "${count} файлы";

  static String m18(error) => "Не удалось создать изображение: ${error}";

  static String m19(error) => "Не удалось создать музыку: ${error}";

  static String m20(error) => "Не удалось сгенерировать речь: ${error}";

  static String m21(error) => "Не удалось создать видео: ${error}";

  static String m22(count) => "${count} предметов";

  static String m23(language) => "Язык изменен на ${language}";

  static String m24(error) => "Не удалось подключиться к MCP: ${error}";

  static String m25(count) => "${count} настроено (значения скрыты)";

  static String m26(minutes) => "${minutes} минут назад";

  static String m27(count) => "Успешно получено ${count} моделей";

  static String m28(count) => "${count} запусков команд";

  static String m29(duration) => "Длительность ${duration}";

  static String m30(count) => "${count} изменений файлов";

  static String m31(count) => "${count} вызовов инструментов";

  static String m32(id) => "Агент ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Артефакт ${artifactId}";

  static String m34(code) => "Операция с артефактом не удалась (${code})";

  static String m35(ids) => "Версии артефакта: ${ids}";

  static String m36(index) => "Приложение ${index}";

  static String m37(count) => "${count} в ожидании";

  static String m38(path) =>
      "Удалить все версии ${path}? Артефакты, на которые ссылается сообщение или доставка, не могут быть удалены.";

  static String m39(depth) => "Глубина доставки: ${depth}";

  static String m40(id, status) => "Запуск передачи: ${id} · ${status}";

  static String m41(value) => "Продолжительность: ${value}";

  static String m42(value) => "Ошибка: ${value}";

  static String m43(id) => "Событие: ${id}";

  static String m44(sequence) => "Событие №${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} артефакт', few: '${count} артефакта', many: '${count} артефактов', other: '${count} артефакта')}";

  static String m46(code) => "Не удалось обновить участника (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} изменено с ${previous} на ${current}";

  static String m48(agentId, current) => "${agentId} теперь ${current}";

  static String m49(id) => "Идентификатор сообщения: ${id}";

  static String m50(code) => "Сообщение не удалось отправить (${code})";

  static String m51(sequence) => "Сообщение №${sequence}";

  static String m52(processed, latest) =>
      "Обработано ${processed} / последнее ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} получатель', few: '${count} получателя', many: '${count} получателей', other: '${count} получателя')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} сообщение со ссылкой', few: '${count} сообщения со ссылками', many: '${count} сообщений со ссылками', other: '${count} сообщения со ссылками')}";

  static String m55(name) => "Удалить ${name}?";

  static String m56(name) => "Перетащите, чтобы изменить порядок ${name}";

  static String m57(sequence) => "Ответ на сообщение №${sequence}";

  static String m58(id) => "Корневой запуск: ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} запуск', few: '${count} запуска', many: '${count} запусков', other: '${count} запуска')}";

  static String m60(runId) => " · запуск ${runId}";

  static String m61(value) => "Источник: ${value}";

  static String m62(id) => "Исходный запуск: ${id}";

  static String m63(value) => "Целевые запуски: ${value}";

  static String m64(input, output) => "Вход ${input} · Выход ${output}";

  static String m65(id, status) => "Ход: ${id} · ${status}";

  static String m66(mime, digest) =>
      "Предварительный просмотр в приложении для этого типа не поддерживается. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "Версия ${version} · агент ${actor}${run}";

  static String m68(error) => "Ошибка получения ответа: ${error}";

  static String m69(error) => "Не удалось сохранить изображение: ${error}";

  static String m70(count) => "${count} выбрано";

  static String m71(error) => "Не удалось поделиться изображением: ${error}";

  static String m72(error) => "Не удалось импортировать навык: ${error}";

  static String m73(duration) => "Размышление завершено · ${duration}";

  static String m74(error) => "Ошибка воспроизведения видео: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Боты"),
    "about": MessageLookupByLibrary.simpleMessage("О приложении"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("О приложении Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "Активный запрос нельзя отменить. Подождите, пока он закончится.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "Активный запрос невозможно остановить.",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Приложение"),
    "addBot": MessageLookupByLibrary.simpleMessage("Добавить бота"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("Добавить MCP-сервер"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Добавить навык"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Настроить размер шрифта приложения",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Настроить размер шрифта",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Откройте проект, использующий этого агента, чтобы просматривать и управлять его контекстом и памятью.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Память агента"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Автоматическое развитие памяти",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "Долговременная память принадлежит этому агенту и может использоваться в разных проектах.",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Все установленные навыки добавлены.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Всегда включён"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Добавляет этот навык в каждый текстовый запрос.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Всегда включён"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Адрес API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API ключ"),
    "apiType": MessageLookupByLibrary.simpleMessage("Тип API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Простое, но мощное приложение для чата с ИИ, которое позволяет общаться с искусственным интеллектом в любое время и в любом месте.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Hyve - ИИ чат-ассистент"),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "Системный промпт",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Управляется Hyve и добавляется к каждому запросу модели. Идентификаторы текущего агента и беседы подставляются во время выполнения и недоступны для редактирования.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage(
      "Прикрепленные файлы",
    ),
    "attachedImages": MessageLookupByLibrary.simpleMessage(
      "Прикрепленные изображения",
    ),
    "attachments": MessageLookupByLibrary.simpleMessage("Вложения"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Автоматически"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Поддерживаемые модели могут активировать этот навык по его описанию.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Этот провайдер поддерживает только ручные навыки.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Автоматическая память",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "Автоматические сводки могут быть неточными. Текущее сообщение всегда имеет приоритет.",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Возврат к ежедневному использованию",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Основная информация",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Аватар бота"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage("Информация о боте"),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Включите инструменты MCP для этого агента. По умолчанию вызовы требуют подтверждения.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Имя бота"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "Поиск фильтрует список по имени бота.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Навыки"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Выберите повторно используемые инструкции, доступные этому боту.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Этот бот недоступен",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Изменить аватар"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Сохранено"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "Поиск соответствует именам ботов и последнему сообщению.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Чаты"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Галерея"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage(
      "Очистить вложения",
    ),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Очистить автоматическую память",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Очистить чат"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Снять закрепление навыков",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Очистить поиск"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Выберите день, чтобы просмотреть почасовое использование.",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Нажмите + в правом верхнем углу, чтобы добавить бота",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Нажмите «Новый чат», чтобы создать беседу",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Выполнение команд",
    ),
    "compactNow": MessageLookupByLibrary.simpleMessage("Сжать сейчас"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Упорядочивание контекста…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "Состояние сжатия",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Подтвердить удаление",
    ),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Контактная информация (необязательно)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Контекст и память",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage("Контекст сжат"),
    "contextWindow": MessageLookupByLibrary.simpleMessage("Окно контекста"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Сводка разговора",
    ),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Доля токенов по беседам",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("Копировать ключ API"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Скопировать место установки.",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Создать проект"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Создание…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Пользовательский провайдер...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Ежедневное использование",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Тёмная тема"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Эта база данных создана более новой версией Hyve. Обновите приложение, прежде чем открывать её.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "Проверка целостности базы данных завершилась ошибкой, восстановить её из резервной копии этой версии не удалось.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Глубокое мышление"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Вы полезный ИИ-ассистент. Пожалуйста, отвечайте на русском языке.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Удалить бота"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Удалить чат"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "Удалить MCP-сервер",
    ),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "О приложении и правовая информация",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Внешний вид и язык",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Измените аватар и отображаемое имя.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Общие"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Помощь и поддержка",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Личная информация",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "Изменения применяются сразу и сохраняются локально.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Управляйте профилем, внешним видом, языком и поддержкой приложения.",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Сведения"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("Готов играть"),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Готово к предварительному просмотру",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Отключить без подтверждения для всех",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Отключить все инструменты",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Отключить скрипты",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editBot": MessageLookupByLibrary.simpleMessage("Редактировать бота"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "Редактировать MCP-сервер.",
    ),
    "editMemory": MessageLookupByLibrary.simpleMessage("Изменить память"),
    "editName": MessageLookupByLibrary.simpleMessage("Изменить имя"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения ответа: сервер вернул пустой ответ",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Включить без подтверждения для всех",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Включить все инструменты",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Включить скрипты",
    ),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "Включить изолированные скрипты?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "Введите адрес API...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage("Введите ключ API..."),
    "enterBotName": MessageLookupByLibrary.simpleMessage("Введите имя бота..."),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Введите отображаемое имя",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите новое имя",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Введите имя провайдера...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Введите системный промпт...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Ошибка при загрузке содержимого, пожалуйста, повторите попытку позже.",
    ),
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Оценка использования",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage(
      "Статус выполнения",
    ),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите содержание отзыва",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, расскажите нам о ваших мыслях, проблемах или предложениях, чтобы помочь нам улучшить приложение",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Введите ваш отзыв здесь...",
    ),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Информация об обратной связи",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Ошибка отправки, пожалуйста, попробуйте позже",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "Спасибо за ваш отзыв!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Получить список моделей",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Сначала получите список моделей",
    ),
    "fileAttachment": MessageLookupByLibrary.simpleMessage("Вложение файла"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Результат файла"),
    "fileStatus": MessageLookupByLibrary.simpleMessage("Статус файлов"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Музыка"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Речь"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Видео"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, заполните имя бота, адрес API и ключ API",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Системная"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("Размер шрифта"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Размер шрифта обновлен",
    ),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Забыть"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage(
      "Изображение создано",
    ),
    "generating": MessageLookupByLibrary.simpleMessage("Генерация…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Идет создание изображения, подождите...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка генерации",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Ошибка генерации · Частичный ответ сохранён",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Помощь и обратная связь",
    ),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("Скрыть ключ API"),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Скрыть информацию о боте",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Скрыть боковую панель",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage(
      "Часовое использование",
    ),
    "idle": MessageLookupByLibrary.simpleMessage("Ожидание"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage(
      "Прикрепленное изображение",
    ),
    "imageResult": MessageLookupByLibrary.simpleMessage(
      "Результат изображения",
    ),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Изображение сохранено в галерее.",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Размер изображения"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Стиль изображения"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Импортировать папку навыка",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Импортировать ZIP навыка",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage("Импорт навыка…"),
    "includesDuration": MessageLookupByLibrary.simpleMessage(
      "Включает продолжительность",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Входные токены"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Установить обновление",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "Созданная сводка не прошла проверку",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Перейти к последней версии",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage("Настройки языка"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Светлая тема"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Невозможно открыть эту ссылку.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "Локальные серверы MCP на основе процессов остаются отключенными в ожидании проверки безопасности платформы.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Управление памятью"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Для сообщения"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "При необходимости выберите навык в поле сообщения.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "Токен доступа OAuth/Bearer",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Аргументы"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Введите по одному аргументу в каждой строке.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется авторизация",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Команда"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Имя исполняемого файла или абсолютный путь. Команда выполняется напрямую без оболочки.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Канал связи",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("На связи"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Подключение"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Ошибка подключения",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage(
      "Подключение",
    ),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Конечная точка потокового HTTP",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage("Переменные среды"),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Введите по одному КЛЮЧ=ЗНАЧЕНИЕ в каждой строке. Значения хранятся в безопасном хранилище учетных данных операционной системы; оставьте пустым при редактировании, чтобы сохранить существующие значения.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Удаленные конечные точки MCP должны использовать HTTPS.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "Переменные среды должны использовать одну запись KEY=VALUE в каждой строке.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "серверы stdio выполняют команды на этом компьютере. Добавляйте только те серверы и переменные среды, которым вы доверяете.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Безопасность локального процесса",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Без подтверждения",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Нет"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Частные, локальные и локальные конечные точки MCP блокируются.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage(
      "Идентификатор процесса (PID)",
    ),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("Не бегу"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("Бег"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("Началось с"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage("Статус процесса"),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "В магазинах Hyve появились каталоги инструментов. Включайте отдельные Инструменты при редактировании агента; только этот агент может предоставить их модели.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут запроса MCP истек.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Защищённые переменные среды",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage(
      "Подробности о сервере",
    ),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("Имя сервера"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Серверы MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Подключайте серверы MCP и находите их каталоги инструментов. Настройте инструменты после создания агента.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin/stdout/stderr (каналы операционной системы)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Локальный процесс и связь",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить команду stdio MCP.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Оставьте поле пустым, чтобы сохранить существующие безопасные учетные данные.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Хранится в безопасном хранилище учетных данных операционной системы.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Этот инструмент имеет неподдерживаемую схему ввода и не может быть выбран.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (локальный процесс)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "Сервер MCP использует неподдерживаемую версию протокола.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Память"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Артефакт"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "Память изменилась; повторите попытку",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Исправление"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Решение"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Факт"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Предпочтение"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("Открытый вопрос"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Задача"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Используйте @, чтобы упомянуть хотя бы одного агента проекта.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Сообщение скопировано в буфер обмена.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Введите сообщение и упомяните агентов через @...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Навыки"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Аудио"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("Файл"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Изображение"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Мультимодальный"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Музыка"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage(
      "В реальном времени",
    ),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Речь"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Текст"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Видео"),
    "model": MessageLookupByLibrary.simpleMessage("Модель"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Конфигурация модели",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Размер контекста модели",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Ввод"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Выход"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage(
      "Время модификации",
    ),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Создана музыка"),
    "musicResult": MessageLookupByLibrary.simpleMessage(
      "Музыкальный результат",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Имя обновлено"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Новые боты остаются в рабочей области для редактирования.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Новый чат"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Новый чат открывается прямо в рабочей области.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Новый проект"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "У этого агента пока нет долговременной памяти.",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "Нет доступных подключённых инструментов MCP.",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Навыки не добавлены",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Добавьте установленные навыки, необходимые этому боту.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Нет доступных ботов",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Пока нет чатов"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Содержимое не возвращено",
    ),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Сводка разговора пока недоступна.",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "Подходящих ботов не найдено.",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "Подходящих чатов не найдено.",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "Подходящие серверы MCP не найдены.",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "Подходящие инструменты не найдены.",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Подходящие навыки не найдены",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Нет MCP-серверов"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Добавьте Streamable HTTP или настольный stdio-сервер, чтобы открыть его каталог инструментов.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "Инструменты не обнаружены. Проверьте соединение и обновите.",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Модели не получены",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "Навыки не установлены",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Импортируйте папку Agent Skills или ZIP-архив с файлом SKILL.md.",
    ),
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "Использование токенов не зафиксировано.",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("Не поддерживается"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Недостаточно старого контекста для сжатия",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Удалите этот потерянный чат или воссоздайте отсутствующего бота.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Выходные токены"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Частичный ответ"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("Приостановить аудио"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Приостановить генерацию",
    ),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Закрепить"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Закрепить выбранное для этого разговора",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Закреплён"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Воспроизвести аудио"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Сначала введите ключ API",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Введите описание для создания изображения.",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Введите описание для создания музыки.",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Введите описание для генерации речи.",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Введите описание для создания видео.",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Предварительный просмотр текста",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Информация о процессе",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Активный"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Догоняем",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("Догнал"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("Решение"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("Не удалось"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage(
      "Приостановлено",
    ),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("Отвечаю"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("Пропущено"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage("Отвечу"),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Добавить агента"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Найдите доступного агента и добавьте его в этот проект.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Добавить вложение",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Агент"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Память агента",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Все типы"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "На этот артефакт есть ссылка, и его нельзя удалить.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage("Архив"),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Приложение",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Аудио"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Код"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Набор данных",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Документ",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Создано",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage(
      "Изображение",
    ),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Видео"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Этот путь проекта уже существует.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Используйте действительный путь относительно проекта.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Все артефакты",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "Размер файла превышает ограничение на размер артефакта.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "Символические ссылки импортировать невозможно.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "Текущая версия изменилась. Откройте его снова перед редактированием.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Версии артефакта",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Артефакты проекта",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Просматривайте файлы проекта, просматривайте историю версий и открывайте файлы с помощью системных приложений.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Подробности аудита",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage("Аудит событий"),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Вернуться к сообщениям",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Вернуться в родительскую папку.",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Введите сообщение. Без @ оно будет транслироваться всем активным агентам.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Отменить корневую цепочку",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "Активные запуски в этой корневой цепочке сообщений, включая доставку потомков, будут остановлены. Другие цепочки продолжат работу.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "Отменить эту корневую цепочку сообщений?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage("Отменить запуск"),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Будет остановлен только этот запуск. Другие активные запуски в ходе продолжатся.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "Отменить этот запуск?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage(
      "Отменить поворот",
    ),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Все активные запуски в этом ходе будут остановлены. Завершенные результаты сохранятся.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "Отменить этот ход?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Содержание"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Контекстный отчет",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Описано в сообщении",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Создать"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Новый текст"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Создать версию",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Решение отменено",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "Запрос на решение не выполнен.",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Неверный ответ на решение",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "Время принятия решения истекло",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Решения"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "Удалить артефакт?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Агенты, навыки, конфигурация и долговременная память не удаляются.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage("Удален агент"),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Перетащите сюда файлы для импорта.",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Отправьте сообщение, чтобы начать сотрудничество. Сообщения без @ транслируются.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Сообщений пока нет",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Передача агента",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Сообщение агента",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "Артефакт изменен.",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "Членство изменено",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Решение об участии",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "Статус выполнения изменен.",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Системное уведомление",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Сообщение пользователя",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Просмотрите историю запусков, решения об участии, использование токенов и события аудита.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Детали исполнения",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "История запуска",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage("Импорт файлов"),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Перейти к последней версии",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Загрузить более ранние события",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Загрузка проекта",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("Участники проекта"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Отслеживайте обработку и управляйте порядком агентов, доступом к артефактам и участием.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Ревизия памяти",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Указанный агент больше не активен. Удалите или выберите его снова.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Переместить или переименовать",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Название проекта"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Введите название проекта.",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Введите название проекта.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Новый текстовый артефакт.",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "У этого проекта нет активных агентов. Сообщения сохраняются, но ответ не генерируется.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Нет активных веществ",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "Нет соответствующих артефактов проекта.",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Еще нет событий аудита",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Нет агентов, доступных для добавления.",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Записей об исполнении пока нет",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "Нет подходящих агентов",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Пока нет участников проекта",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "Ни одному агенту не нужно было ничего добавлять к этому сообщению.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Открыть с помощью системного приложения.",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage(
      "Пропустить",
    ),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Ответить",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Пропущено"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage(
      "Приостановлено",
    ),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Предварительный просмотр и история версий",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Показаны только первые 32 КиБ. Агенты могут продолжать чтение частями.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Путь относительно проекта",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Отпустите для импорта",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "У агента есть активный запуск. Удаление агента отменит этот запуск; остальные агенты продолжат работу.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "Агент перестанет получать новые сообщения проекта.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Запрошен публичный ответ",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Возобновить"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Трансляция",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("Передача"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("Целевой"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Отменено"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("Завершено"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Решение"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("Передача"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Не удалось"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "Идентификатор запуска",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("Прервано"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Превышен лимит",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Пропущено"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("Решение"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("Передача"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Ответить"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Подготовка"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("В очереди"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("Выполняется"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage(
      "Тайм-аут истек",
    ),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Запуски"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Сохранить как артефакт проекта.",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Будет сохранен как артефакт проекта.",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Поиск"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage(
      "Поиск агентов",
    ),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Поиск по имени, пути и содержимому.",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Поиск доступных агентов",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Отправка"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Навыки"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ к артефакту",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Нет"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Читать"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Читать и писать",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Сводные сегменты",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("Система"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("система"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Отменено"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("Завершено"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Создано"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Решение"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("Передача"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage(
      "Диспетчеризация",
    ),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Не удалось"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Частичный"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Отвечаю"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "Невозможно открыть этот файл с помощью системного приложения.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "Невозможно прочитать эту версию",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("неизвестно"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Обновление доступа к артефактам.",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Пользователь"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Рабочая область проекта",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Написать новую версию",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Поделитесь своими предложениями и отзывами",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Провайдер"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Информация о поставщике",
    ),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Рассуждение завершено",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Рассуждение выполняется",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Рассуждение прервано",
    ),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Перестроить"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage("Справочный звук"),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Обновить инструменты",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Обновить каталоги",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Обновление каталогов…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage(
      "Только удаленный MCP",
    ),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Удалить файл",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Удалить изображение",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Удаление MCP-сервера",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Удалить навык"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("Ответ отменен"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Остановлено · Частичный ответ сохранён",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Восстановить значения по умолчанию",
    ),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Сохранённые последние ходы",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить попытку"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Запустить проверку",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage(
      "Сохранить и подключить",
    ),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
    "saveImage": MessageLookupByLibrary.simpleMessage("Сохранить изображение"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить в галерею.",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Сохранение..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Поиск ботов"),
    "searchChats": MessageLookupByLibrary.simpleMessage("Поиск разговоров"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Поиск серверов MCP",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage(
      "Инструменты поиска",
    ),
    "searchMemory": MessageLookupByLibrary.simpleMessage("Поиск в памяти"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Поиск навыков"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Выберите хотя бы одного бота.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Выбрать бота"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выбрать язык"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Выберите модель:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Выберите провайдера:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Выбрать тему"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Отправить"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "shareImage": MessageLookupByLibrary.simpleMessage(
      "Поделиться изображением",
    ),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Изображение с сайта Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage("Показать ключ API"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "После включения в диалогах проекта отображаются сведения об использовании токенов, инструментах, вызовах MCP и других вызовах для сообщений агентов.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage(
      "Показать информацию о боте",
    ),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Показать боковую панель",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Доступны ресурсы",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("Совместимость"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Этот пример должен активировать навык",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Пример запроса пользователя",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Результат активации",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage("Сведения о навыке"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Хеш содержимого"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Выключен"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Включён"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Файлы"),
    "skillImportFailed": m72,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Навык импортирован",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Навыки"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Устанавливайте повторно используемые инструкции и привязывайте их к ботам.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "В этой версии скрипты и команды из навыков не выполняются.",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Издатель"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Доступны справочные файлы",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md загружается только как управляемая инструкция для модели; скрипты, команды и внешние инструменты остаются отключёнными.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Песочница скриптов доступна",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Скрипты отключены до вашего разрешения. Каждый вызов по-прежнему требует подтверждения.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Скрипты навыков недоступны",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "На этой платформе нет требуемой изоляции. Инструкции и ресурсы остаются доступными.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Настройка скриптов обновлена.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Скрипты установлены, но их выполнение отключено.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Скрипты включены",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Подпись"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Недействительная подпись",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Неизвестный издатель",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage(
      "Без подписи",
    ),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Подпись проверена",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Источник"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Место установки",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Место установки скопировано в буфер обмена.",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage(
      "Автоматически",
    ),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Доступно обновление",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Вручную"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("Уведомлять"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Закреплено"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Политика обновлений",
    ),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Пользователь"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Примечания проверки",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Версия"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage(
      "Речь генерируется",
    ),
    "speechResult": MessageLookupByLibrary.simpleMessage("Результат речи"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Отправьте сообщение в поле ввода ниже, чтобы начать чат",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Начать общение"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось запустить приложение. Повторите попытку.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("Запуск…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("Активировано"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Прикреплено"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "Ожидает подтверждения",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Отменено"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Завершено"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Отклонено"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("Повторный вызов"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Создано"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("В процессе"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Записано"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Запрошено"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Выполняется"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Пропущено"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage(
      "Время ожидания истекло",
    ),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage(
      "Остановись и продолжи",
    ),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Остановить генерацию перед уходом?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage("Частичный ответ будет сохранен."),
    "stopping": MessageLookupByLibrary.simpleMessage("Остановка…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Структурированная информация о процессе",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Отправить отзыв"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("Сводка сообщений"),
    "supported": MessageLookupByLibrary.simpleMessage("Поддерживается"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Поддерживает MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Поддерживает навыки",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Системный промпт"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Камера"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Тест"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Проверить описание",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Установлена тёмная тема",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Установлена светлая тема",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Установлена системная тема",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("Настройки темы"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Размышление завершено",
    ),
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Размышление…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Использование токенов"),
    "tokens": MessageLookupByLibrary.simpleMessage("токены"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Разрешено один раз",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Отклонено"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Вызовы инструментов"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage(
      "Разрушительный",
    ),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("Только чтение"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Запись"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Встроенный"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Скрипт навыка",
    ),
    "totalTokens": MessageLookupByLibrary.simpleMessage("Всего токенов"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Попробуйте другой поиск или создайте новый элемент.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Печатает..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "Невозможно загрузить ботов",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "Невозможно загрузить чаты.",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "Невозможно загрузить сообщения",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("Недоступный бот"),
    "uninstall": MessageLookupByLibrary.simpleMessage("Удалить"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("Удалить навык"),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Открепить"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Загрузить файл"),
    "uploadImage": MessageLookupByLibrary.simpleMessage(
      "Загрузить изображение",
    ),
    "userAgreement": MessageLookupByLibrary.simpleMessage(
      "Пользовательское соглашение",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Версия 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Видео создано"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить видео",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Видео результат"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Открыть сводку"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Прежде чем покинуть чат, дождитесь завершения генерации.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Подождите, пока завершится генерация.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Веб-поиск"),
  };
}
