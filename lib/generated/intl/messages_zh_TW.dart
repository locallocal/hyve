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

  static String m0(name) => "已新增智慧體「${name}」";

  static String m1(botName) => "\"${botName}\" 已被刪除";

  static String m2(botName) => "你好！我是 ${botName}，一個AI助手。你可以問我任何問題，我會盡力幫助你。";

  static String m3(botName) => "${botName} 正在輸入...";

  static String m4(botName) => "智慧體 ${botName} 已更新";

  static String m5(botName) => "已刪除與 ${botName} 的聊天";

  static String m6(botName) => "刪除智慧體也會刪除相關聊天記錄，確定要刪除 ${botName} 嗎？";

  static String m7(botName) => "刪除聊天會清空所有的聊天記錄，確定要刪除與 ${botName} 的聊天嗎？";

  static String m8(name) => "確定刪除「${name}」？快取的工具目錄與安全憑證也會移除。";

  static String m9(name) => "確定解除安裝技能「${name}」？相關智慧體綁定也會被移除。";

  static String m10(year) => "© ${year} Hyve 團隊";

  static String m11(error) => "無法建立聊天：${error}";

  static String m12(error) => "建立專案失敗：${error}";

  static String m13(error) => "無法刪除聊天記錄：${error}";

  static String m14(milliseconds) => "${milliseconds} 毫秒";

  static String m15(seconds) => "${seconds} 秒";

  static String m16(name) => "允許「${name}」將已宣告的指令碼註冊為工具。每次呼叫仍須核准，並在桌面沙箱中執行。";

  static String m17(count) => "${count} 個檔案";

  static String m18(error) => "生成图片失败：${error}";

  static String m19(error) => "無法生成音樂：${error}";

  static String m20(error) => "無法產生語音：${error}";

  static String m21(error) => "無法產生影片：${error}";

  static String m22(count) => "${count} 項目";

  static String m23(language) => "語言已設置為${language}";

  static String m24(error) => "MCP 連線失敗：${error}";

  static String m25(count) => "${count} 配置（值隱藏）";

  static String m26(minutes) => "${minutes}分鐘前";

  static String m27(count) => "成功獲取 ${count} 個模型";

  static String m28(count) => "${count} 次命令執行";

  static String m29(duration) => "耗時 ${duration}";

  static String m30(count) => "${count} 筆檔案狀態";

  static String m31(count) => "${count} 次工具呼叫";

  static String m32(id) => "智慧體 ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · 產物 ${artifactId}";

  static String m34(code) => "產物操作失敗（${code}）";

  static String m35(ids) => "產物版本：${ids}";

  static String m36(index) => "附件 ${index}";

  static String m37(count) => "積壓 ${count}";

  static String m38(path) => "將刪除 ${path} 的全部版本。已被訊息或交付引用的產物不會被刪除。";

  static String m39(depth) => "交付深度：${depth}";

  static String m40(id, status) => "交付執行：${id} · ${status}";

  static String m41(value) => "耗時：${value}";

  static String m42(value) => "錯誤：${value}";

  static String m43(id) => "事件：${id}";

  static String m44(sequence) => "事件 #${sequence}";

  static String m45(count) => "${Intl.plural(count, other: '${count} 個產物')}";

  static String m46(code) => "成員更新失敗（${code}）";

  static String m47(agentId, previous, current) =>
      "${agentId} 從 ${previous} 變更為 ${current}";

  static String m48(agentId, current) => "${agentId} 目前狀態為 ${current}";

  static String m49(id) => "訊息 ID：${id}";

  static String m50(code) => "訊息傳送失敗（${code}）";

  static String m51(sequence) => "訊息 #${sequence}";

  static String m52(processed, latest) => "已處理 ${processed} / 最新 ${latest}";

  static String m53(count) => "${Intl.plural(count, other: '${count} 個接收者')}";

  static String m54(count) => "${Intl.plural(count, other: '${count} 則引用訊息')}";

  static String m55(name) => "移除 ${name}？";

  static String m56(name) => "拖曳以調整 ${name} 的順序";

  static String m57(sequence) => "回覆訊息 #${sequence}";

  static String m58(id) => "根執行：${id}";

  static String m59(count) => "${Intl.plural(count, other: '${count} 個執行')}";

  static String m60(runId) => " · 執行 ${runId}";

  static String m61(value) => "來源：${value}";

  static String m62(id) => "來源執行：${id}";

  static String m63(value) => "目標執行：${value}";

  static String m64(input, output) => "輸入 ${input} · 輸出 ${output}";

  static String m65(id, status) => "輪次：${id} · ${status}";

  static String m66(mime, digest) =>
      "該類型不支援應用內預覽。\nMIME：${mime}\nSHA-256：${digest}";

  static String m67(version, actor, run) =>
      "版本 ${version} · 智慧體 ${actor}${run}";

  static String m68(error) => "獲取回覆失敗: ${error}";

  static String m69(error) => "無法儲存影像：${error}";

  static String m70(count) => "已選擇 ${count} 個";

  static String m71(error) => "無法分享圖片：${error}";

  static String m72(error) => "技能匯入失敗：${error}";

  static String m73(duration) => "思考完成 · ${duration}";

  static String m74(error) => "影片播放錯誤：${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("智慧體"),
    "about": MessageLookupByLibrary.simpleMessage("關於"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("關於 Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "活動請求無法取消。等待它完成。",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage("活動請求無法停止"),
    "addAttachment": MessageLookupByLibrary.simpleMessage("附件"),
    "addBot": MessageLookupByLibrary.simpleMessage("新增智慧體"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("新增 MCP 伺服器"),
    "addSkill": MessageLookupByLibrary.simpleMessage("加入技能"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage("調整應用內文字大小"),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage("調整文字大小"),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "開啟一個使用此智慧體的專案後，即可檢視並管理其上下文與記憶。",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("智慧體記憶"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage("自動演化記憶"),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "長期記憶屬於此智慧體，並可在不同專案間重複使用。",
    ),
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Hyve - AI 聊天助手"),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage("系統提示詞"),
    "applicationInjectedPromptDescription":
        MessageLookupByLibrary.simpleMessage(
          "由 Hyve 管理並注入至每次模型請求。目前智慧代理與對話識別碼會在執行階段補充，無法編輯。",
        ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("附件"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("附圖"),
    "attachments": MessageLookupByLibrary.simpleMessage("附件"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("自動啟用"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "讓支援的模型依技能描述按需啟用。",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "目前模型服務僅支援手動使用技能。",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage("自動記憶"),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "自動摘要可能不準確，目前訊息始終優先。",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage("回到日常使用"),
    "basicInformation": MessageLookupByLibrary.simpleMessage("基本訊息"),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("智慧體頭像"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage("智慧體資訊"),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "按工具啟用目前智慧代理可使用的 MCP 能力；預設每次呼叫都需要確認。",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("智慧體名稱"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage("搜尋會依智慧體名稱篩選清單。"),
    "botSkills": MessageLookupByLibrary.simpleMessage("技能"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "選擇這個智慧體可以使用的可重複指令。",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage("此智慧體不可用"),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("更換頭像"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("已儲存"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage("搜尋會比對智慧體名稱與最新訊息。"),
    "chats": MessageLookupByLibrary.simpleMessage("聊天"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("畫廊"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage("清除附件"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage("清除自動記憶"),
    "clearChat": MessageLookupByLibrary.simpleMessage("清空聊天"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage("清除專案固定技能"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("清除搜尋"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "選擇一天查看每小時的使用情況",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage("點擊右上角的 + 新增智慧體"),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage("點擊新建聊天建立專案"),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("命令執行"),
    "compactNow": MessageLookupByLibrary.simpleMessage("立即壓縮"),
    "compactingContext": MessageLookupByLibrary.simpleMessage("正在整理上下文…"),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage("壓縮狀態"),
    "confirm": MessageLookupByLibrary.simpleMessage("確定"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("確認刪除"),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage("聯絡方式（可選）"),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage("上下文與記憶"),
    "contextCompacted": MessageLookupByLibrary.simpleMessage("上下文已壓縮"),
    "contextWindow": MessageLookupByLibrary.simpleMessage("上下文視窗"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage("專案摘要"),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "各對話的 Token 佔比",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("複製 API 金鑰"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage("複製安裝位置"),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("建立專案"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("創造…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("創作時間"),
    "customProvider": MessageLookupByLibrary.simpleMessage("自定義供應商..."),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("日常使用"),
    "darkMode": MessageLookupByLibrary.simpleMessage("深色模式"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "資料庫由較新版本的 Hyve 建立，請升級應用程式後再開啟。",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "資料庫完整性檢查失敗，且無法從目前版本的備份還原。",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("深度思考"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "你是一個有用的AI助手，請用繁體中文回答問題。",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("刪除"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("刪除智慧體"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("刪除聊天"),
    "deleteChatFailed": m13,
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
    "details": MessageLookupByLibrary.simpleMessage("詳情"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("準備開始玩"),
    "directPreview": MessageLookupByLibrary.simpleMessage("準備預覽"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "全部關閉免確認",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage("全部關閉工具"),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage("停用指令碼"),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("編輯"),
    "editBot": MessageLookupByLibrary.simpleMessage("編輯智慧體"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage("編輯 MCP 伺服器"),
    "editMemory": MessageLookupByLibrary.simpleMessage("編輯記憶"),
    "editName": MessageLookupByLibrary.simpleMessage("修改名稱"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "獲取回覆失敗: 伺服器返回空響應",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "全部開啟免確認",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage("全部開啟工具"),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage("啟用指令碼"),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "啟用隔離的技能指令碼？",
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
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage("預計本輪占用"),
    "executionStatus": MessageLookupByLibrary.simpleMessage("執行狀態"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage("請輸入反饋內容"),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "請告訴我們您的想法、問題或建議，幫助我們改進應用",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage("請在此輸入您的反饋內容..."),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage("反饋資訊"),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage("提交失敗，請稍後重試"),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage("感謝您的反饋！"),
    "fetchModelList": MessageLookupByLibrary.simpleMessage("獲取模型列表"),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage("請先獲取模型列表"),
    "fileAttachment": MessageLookupByLibrary.simpleMessage("檔案附件"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("檔案結果"),
    "fileStatus": MessageLookupByLibrary.simpleMessage("檔案狀態"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("音樂"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("語音"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("影片"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "請填寫智慧體名稱、API 位址和 API 金鑰",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟隨系統"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("文字大小"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage("文字大小已更新"),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("遺忘"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("產生的影像"),
    "generating": MessageLookupByLibrary.simpleMessage("生成..."),
    "generatingImage": MessageLookupByLibrary.simpleMessage("正在生成图像，请稍候..."),
    "generationFailed": MessageLookupByLibrary.simpleMessage("生成失敗"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "生成失敗 · 保留部分回覆",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("幫助與反饋"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("隱藏 API 金鑰"),
    "hideInspector": MessageLookupByLibrary.simpleMessage("隱藏智慧體資訊"),
    "hideSidebar": MessageLookupByLibrary.simpleMessage("隱藏側邊欄"),
    "home": MessageLookupByLibrary.simpleMessage("首頁"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("每小時使用量"),
    "idle": MessageLookupByLibrary.simpleMessage("閒置"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("圖片附件"),
    "imageResult": MessageLookupByLibrary.simpleMessage("影像結果"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage("影像已儲存至圖庫"),
    "imageSize": MessageLookupByLibrary.simpleMessage("影像尺寸"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("圖像風格"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage("匯入技能資料夾"),
    "importSkillZip": MessageLookupByLibrary.simpleMessage("匯入技能 ZIP"),
    "importingSkill": MessageLookupByLibrary.simpleMessage("正在匯入技能…"),
    "includesDuration": MessageLookupByLibrary.simpleMessage("包括持續時間"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("輸入 Token"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage("安裝更新"),
    "invalidSummary": MessageLookupByLibrary.simpleMessage("生成的摘要未通過驗證"),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("跳轉至最新"),
    "justNow": MessageLookupByLibrary.simpleMessage("剛剛"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage("語言設定"),
    "lightMode": MessageLookupByLibrary.simpleMessage("淺色模式"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage("無法開啟此連結。"),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "本機程序型 MCP 伺服器仍停用，完成各平台安全審查後才會開放。",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("管理記憶"),
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
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage("溝通管道"),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("已連線"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("連線中"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage("連線錯誤"),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("連線設定"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("未連線"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage("Streamable HTTP 端點"),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage("環境變數"),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "每行填寫一個 KEY=VALUE。內容會儲存在作業系統安全憑證儲存區；編輯時留空可保留現有值。",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
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
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage("免確認"),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("無"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "已封鎖私有、本機及鏈路本地 MCP 端點。",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("進程 ID (PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("不運行"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("跑步"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("開始於"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage("進程狀態"),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Hyve 會儲存已探索的工具目錄。請在編輯智慧代理時逐一啟用工具，只有該智慧代理會將其提供給模型。",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage("MCP 請求逾時。"),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "安全環境變數",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage("伺服器詳情"),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("伺服器名稱"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP 伺服器"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "連接 MCP 伺服器並探索工具目錄；建立智慧代理後再按工具設定。",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr（作業系統管道）",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "本地流程與溝通",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "無法啟動 stdio MCP 命令。",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage("留空可保留現有安全憑證。"),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "權杖會儲存在作業系統的安全憑證儲存區。",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "此工具的輸入 Schema 不受支援，無法選取。",
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
    "memory": MessageLookupByLibrary.simpleMessage("記憶"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("重要引用"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage("記憶已發生變化，請重試"),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("修正"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("決策"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("事實"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("偏好"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("未決問題"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("待辦"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "請使用 @ 提及至少一個專案智慧體。",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage("訊息已複製到剪貼簿"),
    "messageHint": MessageLookupByLibrary.simpleMessage("輸入訊息，使用 @ 提及智慧體..."),
    "messageSkills": MessageLookupByLibrary.simpleMessage("技能"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("音頻"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("檔案"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("圖片"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("多式聯運"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("音樂"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("實時"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("演講"),
    "modalityText": MessageLookupByLibrary.simpleMessage("正文"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("影片"),
    "model": MessageLookupByLibrary.simpleMessage("模型"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage("型号配置"),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage("模型上下文大小"),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("輸入"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("輸出"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage("修改時間"),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("生成的音樂"),
    "musicResult": MessageLookupByLibrary.simpleMessage("音樂結果"),
    "name": MessageLookupByLibrary.simpleMessage("名稱"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("名稱已更新"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "新智慧體會保留在工作區中供編輯。",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("新建聊天"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "新聊天會直接在工作區中開啟。",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("新建專案"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "設定專案名稱，並加入一個或多個智慧體。",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage("此智慧體還沒有長期記憶。"),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "目前沒有已連線且可用的 MCP 工具。",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage("尚未加入技能"),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "依需求加入這個智慧體要使用的已安裝技能。",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage("沒有可用的智慧體"),
    "noChats": MessageLookupByLibrary.simpleMessage("還沒有聊天記錄"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage("未傳回內容"),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "目前還沒有可用的專案摘要。",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage("找不到符合條件的智慧體"),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage("找不到符合條件的聊天記錄"),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "找不到符合的 MCP 伺服器",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage("未找到匹配的工具"),
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
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "尚未記錄 Token 用量",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("不支持"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage("沒有足夠的舊上下文可壓縮"),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "刪除此孤立聊天，或重新建立遺失的智慧體。",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("輸出 Token"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("部分回覆"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("暫停播放"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("暫停生成"),
    "pinMemory": MessageLookupByLibrary.simpleMessage("固定"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage("在目前專案固定已選技能"),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("已固定"),
    "playAudio": MessageLookupByLibrary.simpleMessage("播放音訊"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage("請先輸入API密鑰"),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "请输入图像生成的描述",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "輸入音樂產生的描述",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "輸入語音產生的描述",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "輸入視訊產生的描述",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("預覽文字效果"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("隱私政策"),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage("過程資訊"),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("我的"),
    "projectActive": MessageLookupByLibrary.simpleMessage("活躍"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage("追趕中"),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("已跟上"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("判斷中"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("已暫停"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("回覆中"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("已跳過"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage("將回覆"),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("新增智慧體"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "搜尋可用智慧體並將其新增到目前專案。",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage("新增附件"),
    "projectAgent": MessageLookupByLibrary.simpleMessage("智慧體"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage("智慧體記憶"),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("全部類型"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "產物已被訊息或交付引用，不能刪除。",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage("壓縮檔"),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage("附件"),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("音訊"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("程式碼"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage("資料"),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage("檔案"),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "生成內容",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("圖片"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("其他"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("影片"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "該專案路徑已存在。",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "路徑無效；請使用專案內相對路徑。",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage("全部產物"),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "檔案超過專案產物大小限制。",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "不允許匯入符號連結。",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "目前版本已變化，請重新開啟後再編輯。",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage("產物版本"),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage("專案產物"),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "瀏覽專案檔案、預覽版本歷史，並使用系統應用開啟檔案。",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage("稽核詳情"),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage("稽核事件"),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage("返回訊息"),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage("返回上一層"),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "輸入訊息；不選擇 @ 時將廣播給全部活躍智慧體。",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage("取消根訊息鏈"),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "此根訊息鏈及其後續交付中的活躍執行都將停止；其他訊息鏈將繼續。",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "取消此根訊息鏈？",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage("取消執行"),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "僅停止此執行；同一輪次中的其他活躍執行將繼續。",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage("取消此執行？"),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage("取消輪次"),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "此輪次中的所有活躍執行都將停止；已完成的結果會保留。",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage("取消此輪次？"),
    "projectClose": MessageLookupByLibrary.simpleMessage("關閉"),
    "projectContent": MessageLookupByLibrary.simpleMessage("內容"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage("上下文報告"),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "上下文覆蓋至訊息",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("建立"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("新建文字"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage("建立版本"),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage("判斷已取消"),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage("判斷請求失敗"),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage("判斷結果格式無效"),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage("判斷超時"),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("判斷"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage("刪除產物？"),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "智慧體、技能、設定與長期記憶不會被刪除。",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage("已刪除的智慧體"),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "拖放檔案到此處匯入",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "傳送訊息開始協作；不使用 @ 時將廣播。",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage("暫無訊息"),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage("智慧體交付"),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage("智慧體訊息"),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage("產物變更"),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "成員變更",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "參與判斷",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "執行狀態變更",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage("系統通知"),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage("使用者訊息"),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "查看執行記錄、參與判斷、Token 用量和稽核事件。",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage("執行詳情"),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage("執行記錄"),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage("批次匯入"),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage("回到最新"),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage("載入更早事件"),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage("正在載入專案"),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("專案成員"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "查看訊息處理狀態，並管理智慧體順序、產物權限和專案參與狀態。",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage("記憶版本"),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "被 @ 的智慧體已不在專案中，請刪除或重新選擇。",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage("移動或重命名"),
    "projectName": MessageLookupByLibrary.simpleMessage("專案名稱"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage("輸入專案名稱"),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage("請輸入專案名稱。"),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage("新建文字產物"),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "目前專案沒有活躍智慧體；訊息會被儲存，但不會產生回覆。",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage("暫無活躍智慧體"),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage("暫無符合的專案產物"),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage("暫無稽核事件"),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "沒有可新增的智慧體",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage("暫無執行記錄"),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "未找到符合的智慧體",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage("專案暫無成員"),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "本條訊息沒有智慧體需要補充。",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage("使用系統應用開啟"),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("跳過"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage("回覆"),
    "projectPassed": MessageLookupByLibrary.simpleMessage("已跳過"),
    "projectPause": MessageLookupByLibrary.simpleMessage("暫停"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("已暫停"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage("預覽與版本歷史"),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "預覽僅顯示前 32 KiB；智慧體可分段繼續讀取。",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage("專案內相對路徑"),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage("放開即可匯入"),
    "projectRemove": MessageLookupByLibrary.simpleMessage("移除"),
    "projectRemoveActiveMemberDescription":
        MessageLookupByLibrary.simpleMessage("該智慧體正在執行。移除會取消它的目前執行，其他智慧體不受影響。"),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "該智慧體將不再接收新的專案訊息。",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "請求公開回覆",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("恢復"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage("廣播"),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("交付"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("定向"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("判斷中"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("交付中"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage("執行 ID"),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("已中斷"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage("超出限制"),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("已跳過"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("判斷"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("交付"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("回覆"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("準備中"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("排隊中"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("執行中"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage("已超時"),
    "projectRuns": MessageLookupByLibrary.simpleMessage("執行"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage("儲存為專案正式產物"),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "將儲存為專案正式產物",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("搜尋"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage("搜尋智慧體"),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "搜尋名稱、路徑和正文",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "搜尋可新增的智慧體",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("傳送中"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("技能"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage("產物權限"),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("無"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("唯讀"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage("讀寫"),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage("摘要片段"),
    "projectSystem": MessageLookupByLibrary.simpleMessage("系統"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("系統"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("工具"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("已建立"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("判斷中"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("交付中"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("分發中"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("部分完成"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("回覆中"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "無法使用系統應用開啟此檔案。",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "無法讀取此版本",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("未知"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "正在更新產物權限",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("使用者"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage("專案工作區"),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage("寫入新版本"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage("提供您的意見和建議"),
    "provider": MessageLookupByLibrary.simpleMessage("供應商"),
    "providerInformation": MessageLookupByLibrary.simpleMessage("提供者訊息"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("思考完成"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("思考中"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("思考中斷"),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("重新建構"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage("參考音頻"),
    "refresh": MessageLookupByLibrary.simpleMessage("重新整理"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage("重新整理工具"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage("重新整理目錄"),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "正在重新整理目錄…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("僅支援遠端 MCP"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage("移除檔案"),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage("刪除影像"),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage("刪除 MCP 伺服器"),
    "removeSkill": MessageLookupByLibrary.simpleMessage("移除技能"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("回覆已取消"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage("已停止 · 保留部分回覆"),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("恢復預設值"),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("恢復"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage("保留的最近輪次"),
    "retry": MessageLookupByLibrary.simpleMessage("重試"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage("執行測試"),
    "save": MessageLookupByLibrary.simpleMessage("儲存"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage("儲存並連線"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("儲存修改"),
    "saveImage": MessageLookupByLibrary.simpleMessage("儲存影像"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage("無法儲存到圖庫"),
    "savingChanges": MessageLookupByLibrary.simpleMessage("儲存中..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("搜尋智慧體"),
    "searchChats": MessageLookupByLibrary.simpleMessage("搜尋對話"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage("搜尋 MCP 伺服器"),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage("搜尋工具"),
    "searchMemory": MessageLookupByLibrary.simpleMessage("搜尋記憶"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("搜尋技能"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage("請至少選擇一個智慧體。"),
    "selectBot": MessageLookupByLibrary.simpleMessage("選擇智慧體"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("選擇語言"),
    "selectModel": MessageLookupByLibrary.simpleMessage("選擇模型:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("加入智慧體"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("選擇提供商:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("選擇主題"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("發送"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "shareImage": MessageLookupByLibrary.simpleMessage("分享圖片"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage("圖片來自 Hyve"),
    "showApiKey": MessageLookupByLibrary.simpleMessage("顯示 API 金鑰"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "開啟後，可在專案的對話列表中查看智慧體訊息的 Token 使用情況，以及工具、MCP 等呼叫詳情。",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage("顯示智慧體資訊"),
    "showSidebar": MessageLookupByLibrary.simpleMessage("顯示側邊欄"),
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
    "skillImportFailed": m72,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage("技能已匯入"),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("技能"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "安裝可重複使用的指令，並將其綁定至智慧體。",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "目前版本不會執行技能中的腳本或命令。",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("發佈者"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage("包含參考資料"),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md 僅作為受控提示詞載入；腳本、命令與外部工具維持停用。",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage("桌面指令碼沙箱可用"),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "每個技能的指令碼預設停用，須明確授權後啟用；每次呼叫仍須核准，並在無網路、無主目錄且不繼承環境變數的隔離環境中執行。",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage("技能指令碼不可用"),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "目前平台不具備所需的隔離 helper。技能指令與資源仍可使用，但指令碼不會執行。",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "技能指令碼設定已更新。",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "技能腳本已安裝，但目前版本禁止執行。",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage("指令碼已啟用"),
    "skillSignature": MessageLookupByLibrary.simpleMessage("簽章"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage("簽章無效"),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "未知發佈者",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage("未簽章"),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage("簽章已驗證"),
    "skillSource": MessageLookupByLibrary.simpleMessage("來源"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage("安裝位置"),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "安裝位置已複製到剪貼簿",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("自動"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage("有可用更新"),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("手動"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("通知"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("固定版本"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage("更新策略"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("使用者"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage("驗證說明"),
    "skillVersion": MessageLookupByLibrary.simpleMessage("版本"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage("生成語音"),
    "speechResult": MessageLookupByLibrary.simpleMessage("演講結果"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage("在下方輸入框中發送訊息開始聊天"),
    "startChatting": MessageLookupByLibrary.simpleMessage("開始聊天吧"),
    "startupFailed": MessageLookupByLibrary.simpleMessage("啟動失敗，請再試一次。"),
    "startupStarting": MessageLookupByLibrary.simpleMessage("正在啟動…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("已啟用"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("已附加"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage("等待確認"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("已拒絕"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("重複呼叫"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("已生成"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("進行中"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("已記錄"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("已請求"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("執行中"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("已略過"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("已逾時"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("未知"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage("停止並繼續"),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "離開前停止生成？",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage("部分回應將被保留。"),
    "stopping": MessageLookupByLibrary.simpleMessage("停止…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage("結構化過程資訊"),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("提交反饋"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("已摘要訊息數"),
    "supported": MessageLookupByLibrary.simpleMessage("支持"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("支持MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage("支持技能"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("系統提示詞"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("相機"),
    "testSkill": MessageLookupByLibrary.simpleMessage("測試"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage("測試技能描述"),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage("已設置為深色模式"),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage("已設置為淺色模式"),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage("已設置為跟隨系統主題"),
    "themeSettings": MessageLookupByLibrary.simpleMessage("主題設定"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage("思考完成"),
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("正在思考…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Token 用量"),
    "tokens": MessageLookupByLibrary.simpleMessage("Token"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage("已允許一次"),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("已拒絕"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("工具呼叫"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("破壞性"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("唯讀"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("寫入"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("內建"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage("技能指令碼"),
    "totalTokens": MessageLookupByLibrary.simpleMessage("Token 總量"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "請嘗試不同的搜尋，或建立新專案。",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("正在輸入..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage("無法載入智慧體"),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage("無法載入聊天內容"),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage("無法載入訊息"),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("智慧體不可用"),
    "uninstall": MessageLookupByLibrary.simpleMessage("解除安裝"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("解除安裝技能"),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("解除固定"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("上傳檔案"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("上傳圖片"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("用戶協議"),
    "version": MessageLookupByLibrary.simpleMessage("版本 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("影片生成"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage("無法載入影片"),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("影片結果"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("查看摘要"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "請等待生成完成後再離開此聊天。",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "等待生成完成。",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("網頁搜尋"),
  };
}
