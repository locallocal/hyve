// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_TW locale. All the
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
  String get localeName => 'zh_TW';

  static String m0(name) => "智能體 \"${name}\" 已添加";

  static String m1(botName) => "\"${botName}\" 已被刪除";

  static String m2(botName) => "你好！我是 ${botName}，一個AI助手。你可以問我任何問題，我會盡力幫助你。";

  static String m3(botName) => "${botName} 正在輸入...";

  static String m4(botName) => "智能體 ${botName} 已更新";

  static String m5(botName) => "已刪除與 ${botName} 的聊天";

  static String m6(botName) => "確定要清空與 \"${botName}\" 的所有聊天記錄嗎？此操作無法撤銷。";

  static String m7(botName) => "刪除機器人會刪除對應的聊天記錄，確定要刪除 ${botName} 嗎？";

  static String m8(botName) => "刪除聊天會清空所有的聊天記錄，確定要刪除與 ${botName} 的聊天嗎？";

  static String m21(name) => "確定刪除「${name}」？快取的工具目錄與安全憑證也會移除。";

  static String m9(name) => "確定解除安裝技能「${name}」？相關智慧體綁定也會被移除。";

  static String m10(language) => "語言已設置為${language}";

  static String m30(error) => "MCP 連線失敗：${error}";

  static String m11(minutes) => "${minutes}分鐘前";

  static String m12(count) => "成功獲取 ${count} 個模型";

  static String m13(count) => "${count} 次命令執行";

  static String m14(duration) => "耗時 ${duration}";

  static String m15(count) => "${count} 筆檔案狀態";

  static String m16(count) => "${count} 次工具呼叫";

  static String m17(error) => "獲取回覆失敗: ${error}";

  static String m18(error) => "技能匯入失敗：${error}";

  static String m19(duration) => "思考完成 · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("智能體"),
    "about": MessageLookupByLibrary.simpleMessage("關於"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("關於 Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("添加機器人"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("新增 MCP 伺服器"),
    "addSkill": MessageLookupByLibrary.simpleMessage("加入技能"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage("調整應用內文字大小"),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage("調整文字大小"),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage("所有已安裝技能均已加入。"),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("始終啟用"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "每次文字請求都會注入此技能。",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("始終啟用"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("API地址:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API密鑰"),
    "apiType": MessageLookupByLibrary.simpleMessage("API類型:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "一個簡單而強大的AI聊天應用，讓您隨時隨地與AI進行對話。",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Stars - AI 聊天助手"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("自動啟用"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "讓支援的模型依技能描述按需啟用。",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "目前模型服務僅支援手動使用技能。",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("機器人頭像"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("機器人名稱"),
    "botSkills": MessageLookupByLibrary.simpleMessage("技能"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "選擇這個智慧體可以使用的可重複指令。",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("更換頭像"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("已儲存"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage("對話執行狀態"),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage("聊天記錄已清空"),
    "chats": MessageLookupByLibrary.simpleMessage("聊天"),
    "clear": MessageLookupByLibrary.simpleMessage("清空"),
    "clearChat": MessageLookupByLibrary.simpleMessage("清空聊天"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage("清空聊天記錄"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage("清除會話固定技能"),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage("點擊右上角 + 添加智能體"),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage("點擊新建聊天建立會話"),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("命令執行"),
    "confirm": MessageLookupByLibrary.simpleMessage("確定"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage("確認刪除"),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmDeleteMcpServer": m21,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage("聯絡方式（可選）"),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Stars 團隊"),
    "customProvider": MessageLookupByLibrary.simpleMessage("自定義供應商..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("深色模式"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("深度思考"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "你是一個有用的AI助手，請用繁體中文回答問題。",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("刪除"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("刪除智能體"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("刪除聊天"),
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage("刪除 MCP 伺服器"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage("關於與法律資訊"),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "外觀與語言",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "修改頭像與顯示名稱。",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("一般"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage("幫助與支援"),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage("個人資訊"),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "修改會立即生效並儲存於本機。",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "管理個人資訊、外觀、語言與應用程式支援。",
    ),
    "editBot": MessageLookupByLibrary.simpleMessage("編輯機器人"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage("編輯 MCP 伺服器"),
    "editName": MessageLookupByLibrary.simpleMessage("修改名稱"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "獲取回覆失敗: 伺服器返回空響應",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage("輸入API地址..."),
    "enterApiKey": MessageLookupByLibrary.simpleMessage("輸入API密鑰..."),
    "enterBotName": MessageLookupByLibrary.simpleMessage("請輸入名稱..."),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage("請輸入顯示名稱"),
    "enterNewName": MessageLookupByLibrary.simpleMessage("請輸入新名稱"),
    "enterProviderName": MessageLookupByLibrary.simpleMessage("輸入供應商名稱..."),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage("輸入系統提示詞..."),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "載入內容時出錯，請稍後再試。",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage("執行狀態"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage("請輸入反饋內容"),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "請告訴我們您的想法、問題或建議，幫助我們改進應用",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage("請在此輸入您的反饋內容..."),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage("提交失敗，請稍後重試"),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage("感謝您的反饋！"),
    "fetchModelList": MessageLookupByLibrary.simpleMessage("獲取模型列表"),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage("請先獲取模型列表"),
    "fileStatus": MessageLookupByLibrary.simpleMessage("檔案狀態"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("音樂"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("語音"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("影片"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "請填寫智能體名稱、API地址和API密鑰",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟隨系統"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("文字大小"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage("文字大小已更新"),
    "generationFailed": MessageLookupByLibrary.simpleMessage("生成失敗"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "生成失敗 · 保留部分回覆",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("幫助與反饋"),
    "home": MessageLookupByLibrary.simpleMessage("首頁"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage("匯入技能資料夾"),
    "importSkillZip": MessageLookupByLibrary.simpleMessage("匯入技能 ZIP"),
    "importingSkill": MessageLookupByLibrary.simpleMessage("正在匯入技能…"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("輸入 Token"),
    "justNow": MessageLookupByLibrary.simpleMessage("剛剛"),
    "languageChanged": m10,
    "languageSettings": MessageLookupByLibrary.simpleMessage("語言設定"),
    "lightMode": MessageLookupByLibrary.simpleMessage("淺色模式"),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "本機程序型 MCP 伺服器仍停用，完成各平台安全審查後才會開放。",
    ),
    "manualActivation": MessageLookupByLibrary.simpleMessage("按訊息啟用"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "需要時從訊息輸入框選擇技能。",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "OAuth / Bearer 存取權杖",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("參數"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "每行填寫一個參數。",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("驗證"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage("需要授權"),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("命令"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "填寫可執行檔名稱或絕對路徑；命令會直接執行，不經過 Shell。",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("已連線"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("連線中"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage("連線錯誤"),
    "mcpConnectionFailed": m30,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("連線設定"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("未連線"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage("Streamable HTTP 端點"),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage("環境變數"),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "每行填寫一個 KEY=VALUE。內容會儲存在作業系統安全憑證儲存區；編輯時留空可保留現有值。",
    ),
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "遠端 MCP 端點必須使用 HTTPS。",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "環境變數必須以每行一個 KEY=VALUE 的格式填寫。",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "stdio 伺服器會在本機執行命令，請只加入你信任的伺服器和環境變數。",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "本機程序安全",
    ),
    "mcpNamespace": MessageLookupByLibrary.simpleMessage("工具命名空間"),
    "mcpNamespaceDescription": MessageLookupByLibrary.simpleMessage(
      "使用 1–32 個小寫字母、數字、底線或連字號。",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("無"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "已封鎖私有、本機及鏈路本地 MCP 端點。",
    ),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Stars 會儲存工具目錄，但僅在已啟用技能要求某個已開啟工具時，才提供完整 Schema 給模型。",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage("MCP 請求逾時。"),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("伺服器名稱"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP 伺服器"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "連接本機或遠端 MCP 工具，並控制智慧代理可使用哪些工具。",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "無法啟動 stdio MCP 命令。",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage("留空可保留現有安全憑證。"),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "權杖會儲存在作業系統的安全憑證儲存區。",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "此工具的輸入 Schema 不受支援，無法啟用。",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("工具"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("傳輸方式"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage("stdio（本機程序）"),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "MCP 伺服器使用不支援的協定版本。",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage("輸入消息..."),
    "messageSkills": MessageLookupByLibrary.simpleMessage("技能"),
    "minutesAgo": m11,
    "model": MessageLookupByLibrary.simpleMessage("模型"),
    "modelsRetrievedSuccess": m12,
    "name": MessageLookupByLibrary.simpleMessage("名稱"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("名稱已更新"),
    "newChat": MessageLookupByLibrary.simpleMessage("新建聊天"),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage("尚未加入技能"),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "依需求加入這個智慧體要使用的已安裝技能。",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage("沒有可用的智能體"),
    "noChats": MessageLookupByLibrary.simpleMessage("還沒有聊天記錄"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage("未傳回內容"),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "找不到符合的 MCP 伺服器",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage("找不到符合的技能"),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("尚無 MCP 伺服器"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "新增 Streamable HTTP 或桌面端 stdio 伺服器以探索其工具目錄。",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "尚未發現工具，請檢查連線後重新整理。",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage("未獲取到任何模型"),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage("尚未安裝技能"),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "匯入包含 SKILL.md 的智慧體技能資料夾或 ZIP。",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("輸出 Token"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("部分回覆"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("暫停生成"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage("在目前會話固定已選技能"),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("已固定"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage("請先輸入API密鑰"),
    "previewText": MessageLookupByLibrary.simpleMessage("預覽文字效果"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("隱私政策"),
    "processCommandCount": m13,
    "processDuration": m14,
    "processFileCount": m15,
    "processInformation": MessageLookupByLibrary.simpleMessage("過程資訊"),
    "processToolCount": m16,
    "profile": MessageLookupByLibrary.simpleMessage("我的"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage("提供您的意見和建議"),
    "provider": MessageLookupByLibrary.simpleMessage("供應商"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("思考完成"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("思考中"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("思考中斷"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage("重新整理工具"),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("僅支援遠端 MCP"),
    "removeSkill": MessageLookupByLibrary.simpleMessage("移除技能"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("回覆已取消"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage("已停止 · 保留部分回覆"),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("恢復預設值"),
    "responseError": m17,
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage("執行測試"),
    "save": MessageLookupByLibrary.simpleMessage("儲存"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage("儲存並連線"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("儲存修改"),
    "savingChanges": MessageLookupByLibrary.simpleMessage("儲存中..."),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage("搜尋 MCP 伺服器"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("搜尋技能"),
    "selectBot": MessageLookupByLibrary.simpleMessage("選擇智能體"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("選擇語言"),
    "selectModel": MessageLookupByLibrary.simpleMessage("選擇模型:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("選擇提供商:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("選擇主題"),
    "send": MessageLookupByLibrary.simpleMessage("發送"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "在對話內容中顯示執行狀態。",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage("包含靜態資源"),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("相容性"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "這個範例應啟用技能",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "範例使用者請求",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage("啟用結果"),
    "skillDetails": MessageLookupByLibrary.simpleMessage("技能詳情"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("內容摘要"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("已關閉"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("已開啟"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("檔案"),
    "skillImportFailed": m18,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage("技能已匯入"),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("技能"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "安裝可重複使用的指令，並將其綁定至智慧體。",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "目前版本不會執行技能中的腳本或命令。",
    ),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage("包含參考資料"),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md 僅作為受控提示詞載入；腳本、命令與外部工具維持停用。",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "技能腳本已安裝，但目前版本禁止執行。",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("來源"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("使用者"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage("驗證說明"),
    "skillVersion": MessageLookupByLibrary.simpleMessage("版本"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage("在下方輸入框中發送訊息開始聊天"),
    "startChatting": MessageLookupByLibrary.simpleMessage("開始聊天吧"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("已附加"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("已生成"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("進行中"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("已記錄"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("執行中"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage("結構化過程資訊"),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("提交反饋"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("系統提示詞"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage("測試技能描述"),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage("已設置為深色模式"),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage("已設置為淺色模式"),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage("已設置為跟隨系統主題"),
    "themeSettings": MessageLookupByLibrary.simpleMessage("主題設定"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage("思考完成"),
    "thinkingCompletedWithDuration": m19,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("正在思考…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("工具呼叫"),
    "typing": MessageLookupByLibrary.simpleMessage("正在輸入..."),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("解除安裝技能"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("上傳檔案"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("上傳圖片"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("用戶協議"),
    "version": MessageLookupByLibrary.simpleMessage("版本 1.0.0"),
  };
}
