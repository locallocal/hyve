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
      "ボットを削除すると、関連するすべてのチャットも削除されます。${botName}を本当に削除しますか？";

  static String m7(botName) =>
      "チャットを削除するとすべてのチャット履歴が消去されます。${botName}とのチャットを本当に削除しますか？";

  static String m8(name) => "${name} を削除しますか?キャッシュされたツール カタログと安全な認証情報も削除されます。";

  static String m9(name) => "${name} をアンインストールしますか？ボットとの関連付けも削除されます。";

  static String m10(year) => "© ${year} Hyveチーム";

  static String m11(error) => "チャットを作成できませんでした: ${error}";

  static String m12(error) => "プロジェクトを作成できませんでした: ${error}";

  static String m13(error) => "チャットを削除できませんでした: ${error}";

  static String m14(milliseconds) => "${milliseconds} ミリ秒";

  static String m15(seconds) => "${seconds} 秒";

  static String m16(name) =>
      "${name} が宣言済みスクリプトをツールとして登録することを許可します。各呼び出しにも承認が必要です。";

  static String m17(count) => "${count} ファイル";

  static String m18(error) => "画像の生成に失敗しました: ${error}";

  static String m19(error) => "音楽を生成できませんでした: ${error}";

  static String m20(error) => "音声を生成できませんでした: ${error}";

  static String m21(error) => "ビデオを生成できませんでした: ${error}";

  static String m22(count) => "${count} アイテム";

  static String m23(language) => "言語が${language}に設定されました";

  static String m24(error) => "MCP 接続に失敗しました: ${error}";

  static String m25(count) => "${count} 件設定済み（値は非表示）";

  static String m26(minutes) => "${minutes}分前";

  static String m27(count) => "${count}個のモデルが正常に取得されました";

  static String m28(count) => "コマンド実行 ${count} 件";

  static String m29(duration) => "所要時間 ${duration}";

  static String m30(count) => "ファイル更新 ${count} 件";

  static String m31(count) => "ツール呼び出し ${count} 件";

  static String m32(id) => "エージェント ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · アーティファクト ${artifactId}";

  static String m34(code) => "アーティファクト操作が失敗しました (${code})";

  static String m35(ids) => "アーティファクトのバージョン: ${ids}";

  static String m36(index) => "アタッチメント ${index}";

  static String m37(count) => "${count} 保留中";

  static String m38(path) =>
      "${path} のすべてのバージョンを削除しますか?メッセージまたは配信によって参照されるアーティファクトは削除できません。";

  static String m39(depth) => "配送深さ: ${depth}";

  static String m40(id, status) => "配送実行: ${id} · ${status}";

  static String m41(value) => "期間: ${value}";

  static String m42(value) => "エラー: ${value}";

  static String m43(id) => "イベント: ${id}";

  static String m44(sequence) => "イベント #${sequence}";

  static String m45(count) => "${Intl.plural(count, other: '成果物 ${count} 件')}";

  static String m46(code) => "メンバーの更新に失敗しました (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} が ${previous} から ${current} に変更されました";

  static String m48(agentId, current) => "${agentId} は ${current} になりました";

  static String m49(id) => "メッセージ ID: ${id}";

  static String m50(code) => "メッセージの送信に失敗しました (${code})";

  static String m51(sequence) => "メッセージ #${sequence}";

  static String m52(processed, latest) => "処理済み ${processed} / 最新 ${latest}";

  static String m53(count) => "${Intl.plural(count, other: '受信者 ${count} 件')}";

  static String m54(count) =>
      "${Intl.plural(count, other: '参照メッセージ ${count} 件')}";

  static String m55(name) => "${name} を削除しますか?";

  static String m56(name) => "ドラッグして並べ替えます ${name}";

  static String m57(sequence) => "メッセージ #${sequence} に返信中";

  static String m58(id) => "ルート実行: ${id}";

  static String m59(count) => "${Intl.plural(count, other: '実行 ${count} 件')}";

  static String m60(runId) => "· 走る ${runId}";

  static String m61(value) => "出典: ${value}";

  static String m62(id) => "ソース実行: ${id}";

  static String m63(value) => "目標実行数: ${value}";

  static String m64(input, output) => "入力 ${input} · 出力 ${output}";

  static String m65(id, status) => "ターン: ${id} · ${status}";

  static String m66(mime, digest) =>
      "このタイプではアプリ内プレビューはサポートされていません。 \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "バージョン ${version} · エージェント ${actor}${run}";

  static String m68(error) => "応答の取得に失敗しました：${error}";

  static String m69(error) => "画像を保存できませんでした: ${error}";

  static String m70(count) => "${count} が選択されました";

  static String m71(error) => "画像を共有できませんでした: ${error}";

  static String m72(error) => "スキルをインポートできませんでした：${error}";

  static String m73(duration) => "思考完了 · ${duration}";

  static String m74(error) => "動画の再生エラー: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("ボット"),
    "about": MessageLookupByLibrary.simpleMessage("アプリについて"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Hyveについて"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "アクティブなリクエストはキャンセルできません。完了するまで待ちます。",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "アクティブなリクエストは停止できません",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("添付ファイル"),
    "addBot": MessageLookupByLibrary.simpleMessage("ボットを追加"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("MCP サーバーの追加"),
    "addSkill": MessageLookupByLibrary.simpleMessage("スキルを追加"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "アプリのフォントサイズを調整する",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage("フォントサイズを調整"),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "このエージェントを使用するプロジェクトを開くと、コンテキストとメモリを表示・管理できます。",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("エージェントメモリ"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "メモリの自動進化",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "長期メモリはこのエージェントに属し、プロジェクト間で再利用できます。",
    ),
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Hyve - AIチャットアシスタント"),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "システムプロンプト",
    ),
    "applicationInjectedPromptDescription":
        MessageLookupByLibrary.simpleMessage(
          "Hyve が管理し、すべてのモデルリクエストに注入します。現在のエージェントと会話の識別子は実行時に追加され、編集できません。",
        ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("添付ファイル"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("添付画像"),
    "attachments": MessageLookupByLibrary.simpleMessage("添付ファイル"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("自動"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "対応モデルが説明に基づいてこのスキルを有効化します。",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "このプロバイダーは手動スキルのみ対応しています。",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage("自動メモリ"),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "自動要約は不正確な場合があります。現在のメッセージが常に優先されます。",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage("毎日の使用法に戻る"),
    "basicInformation": MessageLookupByLibrary.simpleMessage("基本情報"),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("ボットのアバター"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage("ボット情報"),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "このエージェントで MCP ツールを有効にします。ツール呼び出しには既定で確認が必要です。",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("ボット名"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "検索では、ボット名でリストをフィルターします。",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("スキル"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "このボットで使用できる再利用可能な指示を選択します。",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "このボットは利用できません",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("アバターを変更"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("保存しました"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "検索では、ボット名と最新のメッセージが一致します。",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("チャット"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("ギャラリー"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage("添付ファイルをクリア"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage("自動メモリを消去"),
    "clearChat": MessageLookupByLibrary.simpleMessage("チャットをクリア"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage("会話の固定を解除"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("検索をクリア"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "日を選択して時間ごとの使用量を表示します",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "右上の+をクリックしてボットを追加",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "新しいチャットをクリックして会話を作成",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("コマンド実行"),
    "compactNow": MessageLookupByLibrary.simpleMessage("今すぐ圧縮"),
    "compactingContext": MessageLookupByLibrary.simpleMessage("コンテキストを整理中…"),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage("圧縮状態"),
    "confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("削除の確認"),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage("連絡先情報（任意）"),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage("コンテキストとメモリ"),
    "contextCompacted": MessageLookupByLibrary.simpleMessage("コンテキストを圧縮しました"),
    "contextWindow": MessageLookupByLibrary.simpleMessage("コンテキストウィンドウ"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage("会話の要約"),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "会話別のトークン割合",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("APIキーをコピー"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "インストール場所をコピー",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("プロジェクトの作成"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("作成中…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("作成時間"),
    "customProvider": MessageLookupByLibrary.simpleMessage("カスタムプロバイダー..."),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("毎日の使用量"),
    "darkMode": MessageLookupByLibrary.simpleMessage("ダークモード"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "このデータベースは新しいバージョンの Hyve で作成されています。アプリを更新してから開いてください。",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "データベースの整合性チェックに失敗し、このバージョンのバックアップからも復元できませんでした。",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("深い思考"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "あなたは役立つAIアシスタントです。日本語で回答してください。",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("ボットを削除"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("チャットを削除"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage("MCP サーバーの削除"),
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
    "details": MessageLookupByLibrary.simpleMessage("詳細"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("すぐにプレイできます"),
    "directPreview": MessageLookupByLibrary.simpleMessage("プレビューの準備ができました"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "すべての確認不要を解除",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage("すべてのツールを無効化"),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage("スクリプトを無効化"),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editBot": MessageLookupByLibrary.simpleMessage("ボットを編集"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage("MCP サーバーの編集"),
    "editMemory": MessageLookupByLibrary.simpleMessage("メモリを編集"),
    "editName": MessageLookupByLibrary.simpleMessage("名前を編集"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "応答の取得に失敗しました：サーバーが空の応答を返しました",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "すべて確認不要にする",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage("すべてのツールを有効化"),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage("スクリプトを有効化"),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "隔離されたスキルスクリプトを有効にしますか？",
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
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage("推定使用量"),
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
    "feedbackInformation": MessageLookupByLibrary.simpleMessage("フィードバック情報"),
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
    "fileAttachment": MessageLookupByLibrary.simpleMessage("添付ファイル"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("ファイル結果"),
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
    "forgetMemory": MessageLookupByLibrary.simpleMessage("忘れる"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("画像生成"),
    "generating": MessageLookupByLibrary.simpleMessage("生成中…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "画像を生成しています。お待ちください...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage("生成に失敗"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "生成に失敗 · 部分回答を保持",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("ヘルプとフィードバック"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("APIキーを非表示にする"),
    "hideInspector": MessageLookupByLibrary.simpleMessage("ボット情報を非表示にする"),
    "hideSidebar": MessageLookupByLibrary.simpleMessage("サイドバーを非表示にする"),
    "home": MessageLookupByLibrary.simpleMessage("ホーム"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("時間当たりの使用量"),
    "idle": MessageLookupByLibrary.simpleMessage("待機中"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("画像添付"),
    "imageResult": MessageLookupByLibrary.simpleMessage("画像結果"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "画像をギャラリーに保存しました",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("画像サイズ"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("画像スタイル"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage("スキルフォルダーをインポート"),
    "importSkillZip": MessageLookupByLibrary.simpleMessage("スキル ZIP をインポート"),
    "importingSkill": MessageLookupByLibrary.simpleMessage("スキルをインポート中…"),
    "includesDuration": MessageLookupByLibrary.simpleMessage("期間を含む"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("入力トークン"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage("更新をインストール"),
    "invalidSummary": MessageLookupByLibrary.simpleMessage("生成された要約は検証に失敗しました"),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("最新にジャンプ"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage("言語設定"),
    "lightMode": MessageLookupByLibrary.simpleMessage("ライトモード"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage("このリンクを開けません。"),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "ローカル プロセスベースの MCP サーバーは、プラットフォームのセキュリティ レビューが行われるまで無効のままです。",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("メモリを管理"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("メッセージごと"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "必要なときにメッセージ入力欄からスキルを選択します。",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "OAuth/Bearer アクセストークン",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("引数"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "1 行に 1 つの引数を入力してください。",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("認証"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage("承認が必要です"),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("コマンド"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "実行可能ファイル名または絶対パス。コマンドはシェルを使用せずに直接実行されます。",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage("通信チャネル"),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("接続されました"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("接続中"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage("接続エラー"),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("接続"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("切断されました"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "ストリーミング可能な HTTP エンドポイント",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage("環境変数"),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Enter one KEY=VALUE per line.値はオペレーティング システムの安全な資格情報ストアに保存されます。既存の値を保持するには、編集中は空白のままにします。",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "リモート MCP エンドポイントは HTTPS を使用する必要があります。",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "環境変数では、1 行に 1 つの KEY=VALUE エントリを使用する必要があります。",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "stdio サーバーはこのコンピューター上でコマンドを実行します。信頼できるサーバーと環境変数のみを追加してください。",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "ローカルプロセスのセキュリティ",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage("確認不要"),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("なし"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "プライベート、ローカル、およびリンクローカル MCP エンドポイントはブロックされます。",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("プロセス ID (PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("実行されていません"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("ランニング"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("に開始されました"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage("プロセスステータス"),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Hyve ストアがツール カタログを発見しました。エージェントを編集するときに個々のツールを有効にします。そのエージェントだけがそれらをモデルに公開できます。",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "MCP リクエストがタイムアウトしました。",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "安全な環境変数",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage("サーバーの詳細"),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("サーバー名"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP サーバー"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "MCP サーバーに接続してツールカタログを検出します。ツールはエージェント作成後に設定します。",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (オペレーティング システム パイプ)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "ローカルプロセスと通信",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "stdio MCP コマンドを開始できませんでした。",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "既存の安全な認証情報を保持するには、空白のままにします。",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "オペレーティング システムの安全な資格情報ストアに保存されます。",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "このツールにはサポートされていない入力スキーマがあるため、選択できません。",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("ツール"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("輸送"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (ローカルプロセス)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "MCP サーバーはサポートされていないプロトコル バージョンを使用しています。",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("メモリ"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("成果物"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "メモリが変更されました。再試行してください",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("訂正"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("決定"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("事実"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("設定"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("未解決の質問"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("タスク"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "@ を使用して、少なくとも 1 人のプロジェクト エージェントに言及します。",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "メッセージがクリップボードにコピーされました",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "メッセージを入力し、@でエージェントをメンション...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("スキル"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("オーディオ"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("ファイル"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("画像"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("マルチモーダル"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("音楽"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("リアルタイム"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("スピーチ"),
    "modalityText": MessageLookupByLibrary.simpleMessage("テキスト"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("ビデオ"),
    "model": MessageLookupByLibrary.simpleMessage("モデル"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage("モデル構成"),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage("モデルコンテキストサイズ"),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("入力"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("出力"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage("修正時間"),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("音楽が生成されました"),
    "musicResult": MessageLookupByLibrary.simpleMessage("音楽の結果"),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("名前が更新されました"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "新しいボットは編集のためにワークスペースに残ります。",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("新しいチャット"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "新しいチャットがワークスペースで直接開きます。",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("新しいプロジェクト"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "このエージェントにはまだ長期メモリがありません。",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "接続済みの利用可能な MCP ツールはありません。",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage("スキルが追加されていません"),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "このボットに必要なインストール済みスキルを追加します。",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage("利用可能なボットがありません"),
    "noChats": MessageLookupByLibrary.simpleMessage("まだチャットがありません"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "コンテンツが返されませんでした",
    ),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "利用できる会話の要約はまだありません。",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "一致するボットが見つかりませんでした",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "一致するチャットが見つかりませんでした",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "一致する MCP サーバーが見つかりませんでした",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "一致するツールが見つかりませんでした",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage("一致するスキルが見つかりません"),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("MCP サーバーなし"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "ストリーミング可能な HTTP またはデスクトップ stdio サーバーを追加して、そのツール カタログを検出します。",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "ツールが見つかりませんでした。接続を確認して更新してください。",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage("モデルが取得されませんでした"),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "スキルがインストールされていません",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md を含む Agent Skills フォルダーまたは ZIP をインポートしてください。",
    ),
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "トークンの使用量は記録されません",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("サポートされていません"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "圧縮できる古いコンテキストが不足しています",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "この孤立したチャットを削除するか、不足しているボットを再作成してください。",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("出力トークン"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("部分回答"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("音声を一時停止"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("生成を一時停止"),
    "pinMemory": MessageLookupByLibrary.simpleMessage("固定"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "選択したスキルをこの会話に固定",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("固定済み"),
    "playAudio": MessageLookupByLibrary.simpleMessage("音声を再生"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "APIキーを先に入力してください",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "画像生成の説明を入力してください",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "音楽生成の説明を入力します",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "音声生成の説明を入力します",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "ビデオ生成の説明を入力します",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("テキスト効果のプレビュー"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage("処理情報"),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("プロフィール"),
    "projectActive": MessageLookupByLibrary.simpleMessage("アクティブ"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage("追いつきます"),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("追いついた"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("決定"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("失敗しました"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("一時停止中"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("返信する"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("スキップされました"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage("返信します"),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("エージェントを追加する"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "利用可能なエージェントを検索し、このプロジェクトに追加します。",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage("添付ファイルを追加"),
    "projectAgent": MessageLookupByLibrary.simpleMessage("エージェント"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage("エージェントメモリ"),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("全種類"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "このアーティファクトは参照されているため、削除できません。",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage("アーカイブ"),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "添付ファイル",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("オーディオ"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("コード"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "データセット",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "ドキュメント",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "生成されました",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("画像"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("その他"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("ビデオ"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "そのプロジェクト パスはすでに存在します。",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "有効なプロジェクト相対パスを使用してください。",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage("すべてのアーティファクト"),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "ファイルはアーティファクトのサイズ制限を超えています。",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "シンボリックリンクはインポートできません。",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "現在のバージョンが変更されました。編集する前に再度開きます。",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "アーティファクトのバージョン",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage("プロジェクト成果物"),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "プロジェクト ファイルを参照し、バージョン履歴をプレビューし、システム アプリでファイルを開きます。",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage("監査の詳細"),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage("監査イベント"),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage("メッセージに戻る"),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "親フォルダーに戻る",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "メッセージを入力します。 @ を付けないと、すべてのアクティブなエージェントにブロードキャストされます。",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "ルートチェーンをキャンセルします",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "このルート メッセージ チェーン内のアクティブな実行 (子孫配信を含む) が停止します。他のチェーンも継続します。",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "このルート メッセージ チェーンをキャンセルしますか?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage("実行をキャンセルする"),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "この実行のみが停止します。ターン内の他のアクティブな実行は継続されます。",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "この実行をキャンセルしますか?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage("ターンをキャンセルする"),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "このターンのアクティブな実行はすべて停止します。完了した結果は保持されます。",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "このターンをキャンセルしますか?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("閉じる"),
    "projectContent": MessageLookupByLibrary.simpleMessage("内容"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage("コンテキストレポート"),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "メッセージでカバー",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("作成する"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("新しいテキスト"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage("バージョンを作成する"),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "決定は取り消されました",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "意思決定リクエストが失敗しました",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage("無効な決定応答"),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "決定がタイムアウトになりました",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("決定"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "アーティファクトを削除しますか?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "エージェント、スキル、設定、および長期記憶は削除されません。",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "エージェントが削除されました",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "ここにファイルをドロップしてインポートします",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "メッセージを送信してコラボレーションを開始します。 @のないメッセージはブロードキャストされます。",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "まだメッセージはありません",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "エージェント配信",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "エージェントのメッセージ",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "アーティファクトが変更されました",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "メンバーが変わりました",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "参加決定",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "実行ステータスが変更されました",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "システムに関するお知らせ",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "ユーザーメッセージ",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "実行履歴、参加の決定、トークンの使用状況、および監査イベントを確認します。",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage("実行の詳細"),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage("実行履歴"),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage("ファイルをインポートする"),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage("最新へジャンプ"),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "以前のイベントをロードする",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "プロジェクトの読み込み中",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("プロジェクトメンバー"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "処理を監視し、エージェントの順序、成果物へのアクセス、および参加を管理します。",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage("メモリリビジョン"),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "言及されたエージェントはもう活動していません。削除するか、再度選択してください。",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage("移動または名前変更"),
    "projectName": MessageLookupByLibrary.simpleMessage("プロジェクト名"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage("プロジェクト名を入力します"),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "プロジェクト名を入力します。",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "新しいテキストアーティファクト",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "このプロジェクトにはアクティブなエージェントがいません。メッセージは保存されますが、応答は生成されません。",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "アクティブなエージェントはありません",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "一致するプロジェクト成果物はありません",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "監査イベントはまだありません",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "追加できるエージェントはありません",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage("まだ実行記録がありません"),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "一致するエージェントがありません",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "プロジェクトメンバーはまだいません",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "エージェントがこのメッセージに何も追加する必要はありません。",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "システムアプリで開く",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("スキップ"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage("返信"),
    "projectPassed": MessageLookupByLibrary.simpleMessage("スキップ"),
    "projectPause": MessageLookupByLibrary.simpleMessage("一時停止"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("一時停止中"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "プレビューとバージョン履歴",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "最初の 32 KiB のみが表示されます。エージェントは分割して読み取りを続けることができます。",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage("プロジェクトの相対パス"),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "ドロップしてインポート",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("削除"),
    "projectRemoveActiveMemberDescription":
        MessageLookupByLibrary.simpleMessage(
          "エージェントはアクティブに実行されています。これを削除すると、その実行がキャンセルされます。他のエージェントも続行します。",
        ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "エージェントは新しいプロジェクト メッセージの受信を停止します。",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "公開回答が求められています",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("再開"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage("放送"),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("配信"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("ターゲットにされた"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("キャンセルされました"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("完了"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("決定"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("配信中"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("失敗しました"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage("実行ID"),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("中断されました"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage("制限を超えました"),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("スキップ"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("決定"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("配信"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("返信"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("準備中"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("キューに登録されました"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("実行中"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage("タイムアウトしました"),
    "projectRuns": MessageLookupByLibrary.simpleMessage("実行"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "プロジェクト成果物として保存",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "プロジェクトの成果物として保存されます",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("検索"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage("エージェントを検索"),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "名前、パス、コンテンツを検索します",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "対応可能なエージェントを検索する",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("送信中"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("スキル"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "アーティファクトへのアクセス",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("なし"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("読む"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "読み取りと書き込み",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage("概要セグメント"),
    "projectSystem": MessageLookupByLibrary.simpleMessage("システム"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("システム"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("ツール"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("キャンセルされました"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("完了"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("作成されました"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("決定"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("配信中"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("派遣"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("失敗しました"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("部分的"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("返信する"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "システム アプリではこのファイルを開くことができません。",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "このバージョンを読み取れません",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("不明"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "アーティファクトへのアクセスを更新しています",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("ユーザー"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage("プロジェクトワークスペース"),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "新しいバージョンを作成する",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage("ご意見やご提案をお寄せください"),
    "provider": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "providerInformation": MessageLookupByLibrary.simpleMessage("プロバイダー情報"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("推論完了"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("推論中"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("推論中断"),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("再構築"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage("参考音声"),
    "refresh": MessageLookupByLibrary.simpleMessage("更新"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage("ツールを更新"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage("カタログを更新"),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "カタログを更新中…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("リモート MCP のみ"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage("ファイルを削除"),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage("画像を削除"),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage("MCP サーバーを削除します"),
    "removeSkill": MessageLookupByLibrary.simpleMessage("スキルを削除"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("応答がキャンセルされました"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "停止済み · 部分回答を保持",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("デフォルトに戻す"),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("復元"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage("保持された最近のターン"),
    "retry": MessageLookupByLibrary.simpleMessage("再試行"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage("テストを実行"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage("保存して接続する"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存"),
    "saveImage": MessageLookupByLibrary.simpleMessage("画像を保存"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "ギャラリーに保存できませんでした",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("保存中..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("ボットを検索"),
    "searchChats": MessageLookupByLibrary.simpleMessage("会話を検索"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage("MCP サーバーを検索"),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage("検索ツール"),
    "searchMemory": MessageLookupByLibrary.simpleMessage("メモリを検索"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("スキルを検索"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "少なくとも 1 つのボットを選択します。",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("ボットを選択"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("言語を選択"),
    "selectModel": MessageLookupByLibrary.simpleMessage("モデルを選択:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("プロバイダーを選択:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("テーマを選択"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("送信"),
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "shareImage": MessageLookupByLibrary.simpleMessage("画像を共有する"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage("Hyve からの画像"),
    "showApiKey": MessageLookupByLibrary.simpleMessage("APIキーを表示"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "有効にすると、プロジェクトの会話でエージェントメッセージのトークン使用量やツール、MCP などの呼び出し詳細を確認できます。",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage("ボット情報を表示"),
    "showSidebar": MessageLookupByLibrary.simpleMessage("サイドバーを表示"),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage("アセットあり"),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("互換性"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "この例ではスキルを有効化する",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "ユーザー依頼の例",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage("有効化結果"),
    "skillDetails": MessageLookupByLibrary.simpleMessage("スキルの詳細"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("コンテンツダイジェスト"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("無効"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("有効"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("ファイル"),
    "skillImportFailed": m72,
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
    "skillPublisher": MessageLookupByLibrary.simpleMessage("発行者"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "参照ファイルあり",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md は管理されたプロンプト指示としてのみ読み込まれます。スクリプト、コマンド、外部ツールは無効のままです。",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "デスクトップスクリプトサンドボックスが利用可能",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "承認するまでスクリプトはスキルごとに無効です。各呼び出しにも引き続き承認が必要です。",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "スキルスクリプトは利用不可",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "このプラットフォームには必要な隔離環境がありません。指示とリソースは引き続き利用できます。",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "スキルスクリプト設定を更新しました。",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "スクリプトはインストールされていますが、実行は無効です。",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage("スクリプト有効"),
    "skillSignature": MessageLookupByLibrary.simpleMessage("署名"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage("無効な署名"),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "不明な発行者",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage("未署名"),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage("署名検証済み"),
    "skillSource": MessageLookupByLibrary.simpleMessage("ソース"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage("設置場所"),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "インストール場所がクリップボードにコピーされました",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("自動"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage("更新あり"),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("手動"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("通知"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("固定"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage("更新ポリシー"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("ユーザー"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage("検証メモ"),
    "skillVersion": MessageLookupByLibrary.simpleMessage("バージョン"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage("音声が生成されました"),
    "speechResult": MessageLookupByLibrary.simpleMessage("スピーチ結果"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "下の入力欄にメッセージを送信してチャットを開始してください",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("チャットを始めましょう"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "起動に失敗しました。もう一度お試しください。",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("起動しています…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("有効化済み"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("添付済み"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage("承認待ち"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("キャンセル済み"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("完了"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("拒否済み"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("重複呼び出し"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("生成済み"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("進行中"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("記録済み"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("リクエスト済み"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("実行中"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("スキップ済み"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("不明"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage("停止して続行"),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "終了する前に生成を停止しますか?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage("部分応答は維持されます。"),
    "stopping": MessageLookupByLibrary.simpleMessage("停止中…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage("構造化された処理情報"),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("フィードバックを送信"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("要約済みメッセージ"),
    "supported": MessageLookupByLibrary.simpleMessage("サポートされています"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("MCP をサポート"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage("スキルをサポート"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("システムプロンプト"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("カメラ"),
    "testSkill": MessageLookupByLibrary.simpleMessage("テスト"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage("説明をテスト"),
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
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("思考中…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("トークン使用量"),
    "tokens": MessageLookupByLibrary.simpleMessage("トークン"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage("1回のみ許可"),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("拒否"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("ツール呼び出し"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("破壊的"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("読み取り専用"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("書き込み"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("組み込み"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage("スキルスクリプト"),
    "totalTokens": MessageLookupByLibrary.simpleMessage("トークンの総数"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "別の検索を試すか、新しい項目を作成してください。",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("入力中..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage("ボットをロードできません"),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage("チャットを読み込めません"),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "メッセージを読み込めません",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("利用できないボット"),
    "uninstall": MessageLookupByLibrary.simpleMessage("アンインストール"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("スキルをアンインストール"),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("固定解除"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("ファイルをアップロード"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("画像をアップロード"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("ユーザー同意"),
    "version": MessageLookupByLibrary.simpleMessage("バージョン 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("ビデオが生成されました"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage("動画を読み込めません"),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("ビデオ結果"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("要約を表示"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "このチャットを終了する前に、生成が完了するまで待ってください。",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "生成が完了するまで待ちます。",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("ウェブ検索"),
  };
}
