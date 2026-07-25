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
      "Вы уверены, что хотите очистить всю историю чата с \"${botName}\"? Это действие нельзя отменить.";

  static String m7(botName) =>
      "Удаление бота также удалит все связанные чаты. Вы уверены, что хотите удалить ${botName}?";

  static String m8(botName) =>
      "Удаление чата приведет к стиранию всей истории переписки. Вы уверены, что хотите удалить чат с ${botName}?";

  static String m9(language) => "Язык изменен на ${language}";

  static String m10(minutes) => "${minutes} минут назад";

  static String m11(count) => "Успешно получено ${count} моделей";

  static String m12(count) => "${count} запусков команд";

  static String m13(duration) => "Длительность ${duration}";

  static String m14(count) => "${count} изменений файлов";

  static String m15(count) => "${count} вызовов инструментов";

  static String m16(error) => "Ошибка получения ответа: ${error}";

  static String m17(duration) => "Размышление завершено · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Боты"),
    "about": MessageLookupByLibrary.simpleMessage("О приложении"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("О приложении Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Добавить бота"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Настроить размер шрифта приложения",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Настроить размер шрифта",
    ),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Адрес API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API ключ"),
    "apiType": MessageLookupByLibrary.simpleMessage("Тип API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Простое, но мощное приложение для чата с ИИ, которое позволяет общаться с искусственным интеллектом в любое время и в любом месте.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - ИИ чат-ассистент",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Аватар бота"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("Имя бота"),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Изменить аватар"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "Статус выполнения чата",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "История чата очищена",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Чаты"),
    "clear": MessageLookupByLibrary.simpleMessage("Очистить"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Очистить чат"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Очистить историю чата",
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
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "Подтвердить удаление",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Контактная информация (необязательно)",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Команда Stars"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Пользовательский провайдер...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Тёмная тема"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Глубокое мышление"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Вы полезный ИИ-ассистент. Пожалуйста, отвечайте на русском языке.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Удалить бота"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Удалить чат"),
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
    "editBot": MessageLookupByLibrary.simpleMessage("Редактировать бота"),
    "editName": MessageLookupByLibrary.simpleMessage("Изменить имя"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Ошибка получения ответа: сервер вернул пустой ответ",
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
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка генерации",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Ошибка генерации · Частичный ответ сохранён",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "Помощь и обратная связь",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Входные токены"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "languageChanged": m9,
    "languageSettings": MessageLookupByLibrary.simpleMessage("Настройки языка"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Светлая тема"),
    "messageHint": MessageLookupByLibrary.simpleMessage("Введите сообщение..."),
    "minutesAgo": m10,
    "model": MessageLookupByLibrary.simpleMessage("Модель"),
    "modelsRetrievedSuccess": m11,
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Имя обновлено"),
    "newChat": MessageLookupByLibrary.simpleMessage("Новый чат"),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Нет доступных ботов",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Пока нет чатов"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Содержимое не возвращено",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Модели не получены",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Выходные токены"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Частичный ответ"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage(
      "Приостановить генерацию",
    ),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Сначала введите ключ API",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Предварительный просмотр текста",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "processCommandCount": m12,
    "processDuration": m13,
    "processFileCount": m14,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Информация о процессе",
    ),
    "processToolCount": m15,
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Поделитесь своими предложениями и отзывами",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Провайдер"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Рассуждение завершено",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Рассуждение выполняется",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Рассуждение прервано",
    ),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("Ответ отменен"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Остановлено · Частичный ответ сохранён",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "Восстановить значения по умолчанию",
    ),
    "responseError": m16,
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
    "selectBot": MessageLookupByLibrary.simpleMessage("Выбрать бота"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выбрать язык"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Выберите модель:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Выберите провайдера:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Выбрать тему"),
    "send": MessageLookupByLibrary.simpleMessage("Отправить"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Показывать сведения о выполнении в сообщениях беседы.",
    ),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Отправьте сообщение в поле ввода ниже, чтобы начать чат",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Начать общение"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Прикреплено"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Отменено"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Завершено"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Создано"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("В процессе"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Записано"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Выполняется"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Структурированная информация о процессе",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Отправить отзыв"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Системный промпт"),
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
    "thinkingCompletedWithDuration": m17,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Размышление…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Вызовы инструментов"),
    "typing": MessageLookupByLibrary.simpleMessage("Печатает..."),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Загрузить файл"),
    "uploadImage": MessageLookupByLibrary.simpleMessage(
      "Загрузить изображение",
    ),
    "userAgreement": MessageLookupByLibrary.simpleMessage(
      "Пользовательское соглашение",
    ),
    "version": MessageLookupByLibrary.simpleMessage("Версия 1.0.0"),
  };
}
