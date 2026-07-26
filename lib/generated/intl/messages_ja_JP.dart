// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja_JP locale. All the
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
  String get localeName => 'ja_JP';

  static String m0(name) => "ボット \"${name}\" が追加されました";

  static String m1(botName) => "\"${botName}\"が削除されました";

  static String m2(botName) =>
      "こんにちは！私は${botName}というAIアシスタントです。どんな質問でもお気軽にどうぞ、できる限りお手伝いします。";

  static String m3(botName) => "${botName}が入力中...";

  static String m4(botName) => "ボット${botName}が更新されました";

  static String m5(botName) => "${botName}とのチャットが削除されました";

  static String m6(botName) =>
      "\"${botName}\"とのすべてのチャット履歴を消去してもよろしいですか？この操作は元に戻せません。";

  static String m7(botName) =>
      "ボットを削除すると、関連するすべてのチャットも削除されます。${botName}を本当に削除しますか？";

  static String m8(botName) =>
      "チャットを削除するとすべてのチャット履歴が消去されます。${botName}とのチャットを本当に削除しますか？";

  static String m9(name) => "${name} をアンインストールしますか？ボットとの関連付けも削除されます。";

  static String m10(language) => "言語が${language}に設定されました";

  static String m11(minutes) => "${minutes}分前";

  static String m12(count) => "${count}個のモデルが正常に取得されました";

  static String m13(count) => "コマンド実行 ${count} 件";

  static String m14(duration) => "所要時間 ${duration}";

  static String m15(count) => "ファイル更新 ${count} 件";

  static String m16(count) => "ツール呼び出し ${count} 件";

  static String m17(error) => "応答の取得に失敗しました：${error}";

  static String m18(error) => "スキルをインポートできませんでした：${error}";

  static String m19(duration) => "思考完了 · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("ボット"),
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Starsについて"),
    "addBot": MessageLookupByLibrary.simpleMessage("ボットを追加"),
    "addSkill": MessageLookupByLibrary.simpleMessage("スキルを追加"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "アプリのフォントサイズを調整する",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage("フォントサイズを調整"),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "インストール済みのスキルはすべて追加されています。",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("常に有効"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "各テキストリクエストにこのスキルを挿入します。",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("常に有効"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("APIアドレス:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("APIキー"),
    "apiType": MessageLookupByLibrary.simpleMessage("APIタイプ:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "いつでもどこでもAIとチャットできるシンプルで強力なAIチャットアプリケーション。",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Stars - AIチャットアシスタント"),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("ボットのアバター"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("ボット名"),
    "botSkills": MessageLookupByLibrary.simpleMessage("スキル"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "このボットで使用できる再利用可能な指示を選択します。",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("アバターを変更"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage("チャットの実行状況"),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "チャット履歴が消去されました",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("チャット"),
    "clear": MessageLookupByLibrary.simpleMessage("クリア"),
    "clearChat": MessageLookupByLibrary.simpleMessage("チャットをクリア"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage("チャット履歴をクリア"),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "右上の+をクリックしてボットを追加",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "新しいチャットをクリックして会話を作成",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("コマンド実行"),
    "confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage("削除の確認"),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage("連絡先情報（任意）"),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Starsチーム"),
    "customProvider": MessageLookupByLibrary.simpleMessage("カスタムプロバイダー..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("ダークモード"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("深い思考"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "あなたは役立つAIアシスタントです。日本語で回答してください。",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("ボットを削除"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("チャットを削除"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "このアプリについて・法的情報",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "外観と言語",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "アバターと表示名を変更します。",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("一般"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage("ヘルプとサポート"),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage("個人情報"),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "変更はすぐに反映され、ローカルに保存されます。",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "プロフィール、外観、言語、アプリのサポートを管理します。",
    ),
    "editBot": MessageLookupByLibrary.simpleMessage("ボットを編集"),
    "editName": MessageLookupByLibrary.simpleMessage("名前を編集"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "応答の取得に失敗しました：サーバーが空の応答を返しました",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage("APIアドレスを入力..."),
    "enterApiKey": MessageLookupByLibrary.simpleMessage("APIキーを入力..."),
    "enterBotName": MessageLookupByLibrary.simpleMessage("ボット名を入力..."),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage("表示名を入力してください"),
    "enterNewName": MessageLookupByLibrary.simpleMessage("新しい名前を入力してください"),
    "enterProviderName": MessageLookupByLibrary.simpleMessage("プロバイダー名を入力..."),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "システムプロンプトを入力...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "コンテンツの読み込み中にエラーが発生しました。後でもう一度お試しください。",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage("実行状態"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "フィードバック内容を入力してください",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "アプリの改善に役立てるたければ、あなたの考え、問題点、または提案を教えてください",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "ここにフィードバックを入力してください...",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "送信に失敗しました。後でもう一度お試しください",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "フィードバックをありがとうございます！",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage("モデルリストを取得"),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "まずモデルリストを取得してください",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("ファイル状態"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("音楽"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("音声"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("動画"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "ボット名、APIアドレス、APIキーを入力してください",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("システムに従う"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("フォントサイズ"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage("フォントサイズが更新されました"),
    "generationFailed": MessageLookupByLibrary.simpleMessage("生成に失敗"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "生成に失敗 · 部分回答を保持",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("ヘルプとフィードバック"),
    "home": MessageLookupByLibrary.simpleMessage("ホーム"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage("スキルフォルダーをインポート"),
    "importSkillZip": MessageLookupByLibrary.simpleMessage("スキル ZIP をインポート"),
    "importingSkill": MessageLookupByLibrary.simpleMessage("スキルをインポート中…"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("入力トークン"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "languageChanged": m10,
    "languageSettings": MessageLookupByLibrary.simpleMessage("言語設定"),
    "lightMode": MessageLookupByLibrary.simpleMessage("ライトモード"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("メッセージごと"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "必要なときにメッセージ入力欄からスキルを選択します。",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage("メッセージを入力..."),
    "messageSkills": MessageLookupByLibrary.simpleMessage("スキル"),
    "minutesAgo": m11,
    "model": MessageLookupByLibrary.simpleMessage("モデル"),
    "modelsRetrievedSuccess": m12,
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("名前が更新されました"),
    "newChat": MessageLookupByLibrary.simpleMessage("新しいチャット"),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage("スキルが追加されていません"),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "このボットに必要なインストール済みスキルを追加します。",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage("利用可能なボットがありません"),
    "noChats": MessageLookupByLibrary.simpleMessage("まだチャットがありません"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "コンテンツが返されませんでした",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage("一致するスキルが見つかりません"),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage("モデルが取得されませんでした"),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "スキルがインストールされていません",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md を含む Agent Skills フォルダーまたは ZIP をインポートしてください。",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("出力トークン"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("部分回答"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("生成を一時停止"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "APIキーを先に入力してください",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("テキスト効果のプレビュー"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "processCommandCount": m13,
    "processDuration": m14,
    "processFileCount": m15,
    "processInformation": MessageLookupByLibrary.simpleMessage("処理情報"),
    "processToolCount": m16,
    "profile": MessageLookupByLibrary.simpleMessage("プロフィール"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage("ご意見やご提案をお寄せください"),
    "provider": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("推論完了"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("推論中"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("推論中断"),
    "removeSkill": MessageLookupByLibrary.simpleMessage("スキルを削除"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("応答がキャンセルされました"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "停止済み · 部分回答を保持",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("デフォルトに戻す"),
    "responseError": m17,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("スキルを検索"),
    "selectBot": MessageLookupByLibrary.simpleMessage("ボットを選択"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("言語を選択"),
    "selectModel": MessageLookupByLibrary.simpleMessage("モデルを選択:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("プロバイダーを選択:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("テーマを選択"),
    "send": MessageLookupByLibrary.simpleMessage("送信"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "会話メッセージに実行の詳細を表示します。",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage("アセットあり"),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("互換性"),
    "skillDetails": MessageLookupByLibrary.simpleMessage("スキルの詳細"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("コンテンツダイジェスト"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("無効"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("有効"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("ファイル"),
    "skillImportFailed": m18,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "スキルをインポートしました",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("スキル"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "再利用可能な指示をインストールしてボットに関連付けます。",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "このバージョンでは、スキル内のスクリプトやコマンドは実行されません。",
    ),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "参照ファイルあり",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md は管理されたプロンプト指示としてのみ読み込まれます。スクリプト、コマンド、外部ツールは無効のままです。",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "スクリプトはインストールされていますが、実行は無効です。",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("ソース"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("ユーザー"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage("検証メモ"),
    "skillVersion": MessageLookupByLibrary.simpleMessage("バージョン"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "下の入力欄にメッセージを送信してチャットを開始してください",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("チャットを始めましょう"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("添付済み"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("キャンセル済み"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("完了"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("生成済み"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("進行中"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("記録済み"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("実行中"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage("構造化された処理情報"),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("フィードバックを送信"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("システムプロンプト"),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "テーマがダークモードに設定されました",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "テーマがライトモードに設定されました",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "テーマがシステムに従うように設定されました",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("テーマ設定"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage("思考完了"),
    "thinkingCompletedWithDuration": m19,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("思考中…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("ツール呼び出し"),
    "typing": MessageLookupByLibrary.simpleMessage("入力中..."),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("スキルをアンインストール"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("ファイルをアップロード"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("画像をアップロード"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("ユーザー同意"),
    "version": MessageLookupByLibrary.simpleMessage("バージョン 1.0.0"),
  };
}
