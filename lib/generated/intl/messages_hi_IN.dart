// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a hi_IN locale. All the
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
  String get localeName => 'hi_IN';

  static String m0(name) => "बॉट \"${name}\" जोड़ा गया है";

  static String m1(botName) => "\"${botName}\" हटा दिया गया है";

  static String m2(botName) =>
      "नमस्ते! मैं ${botName} हूँ, एक AI सहायक। आप मुझसे कोई भी प्रश्न पूछ सकते हैं, मैं आपकी मदद करने की पूरी कोशिश करूंगा।";

  static String m3(botName) => "${botName} टाइप कर रहा है...";

  static String m4(botName) => "बॉट ${botName} अपडेट किया गया है";

  static String m5(botName) => "${botName} के साथ चैट हटा दी गई";

  static String m6(botName) =>
      "क्या आप वाकई \"${botName}\" के साथ सभी चैट इतिहास मिटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती है।";

  static String m7(botName) =>
      "बॉट हटाने से संबंधित सभी चैट भी हट जाएंगी। क्या आप वाकई ${botName} को हटाना चाहते हैं?";

  static String m8(botName) =>
      "चैट हटाने से सभी चैट इतिहास मिट जाएगा। क्या आप वाकई ${botName} के साथ चैट हटाना चाहते हैं?";

  static String m9(name) =>
      "${name} को अनइंस्टॉल करें? बॉट से इसके संबंध भी हटा दिए जाएँगे।";

  static String m10(name) =>
      "${name} को घोषित स्क्रिप्ट टूल के रूप में पंजीकृत करने दें। हर कॉल को फिर भी स्वीकृति चाहिए।";

  static String m11(language) => "भाषा ${language} में बदली गई";

  static String m12(minutes) => "${minutes} मिनट पहले";

  static String m13(count) => "सफलतापूर्वक ${count} मॉडल प्राप्त किए गए";

  static String m14(count) => "${count} कमांड निष्पादन";

  static String m15(duration) => "अवधि ${duration}";

  static String m16(count) => "${count} फ़ाइल बदलाव";

  static String m17(count) => "${count} टूल कॉल";

  static String m18(error) => "उत्तर प्राप्त करने में विफल: ${error}";

  static String m19(error) => "कौशल आयात नहीं हो सका: ${error}";

  static String m20(duration) => "सोचना पूर्ण · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("बॉट्स"),
    "about": MessageLookupByLibrary.simpleMessage("के बारे में"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Stars के बारे में"),
    "addBot": MessageLookupByLibrary.simpleMessage("बॉट जोड़ें"),
    "addSkill": MessageLookupByLibrary.simpleMessage("कौशल जोड़ें"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "एप्लिकेशन फॉन्ट साइज़ समायोजित करें",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "फॉन्ट साइज़ समायोजित करें",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "सभी इंस्टॉल किए गए कौशल जोड़ दिए गए हैं।",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("हमेशा चालू"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "हर टेक्स्ट अनुरोध में यह कौशल जोड़ें।",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("हमेशा चालू"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("API पता:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API कुंजी"),
    "apiType": MessageLookupByLibrary.simpleMessage("API प्रकार:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "एक सरल लेकिन शक्तिशाली AI चैट एप्लयन जो आपको कहीं भी, कभी भी AI के साथ चैट करने की अनुमति देता है।",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Stars - AI चैट सहायक"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("स्वचालित"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "समर्थित मॉडल इस कौशल को उसके विवरण के आधार पर सक्रिय कर सकते हैं।",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "यह प्रदाता केवल मैन्युअल कौशल का समर्थन करता है।",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage("स्वचालित स्मृति"),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "स्वचालित सारांश गलत हो सकते हैं। वर्तमान संदेश हमेशा प्राथमिक है।",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("बॉट अवतार"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "इस एजेंट के लिए MCP टूल चालू करें। डिफ़ॉल्ट रूप से टूल कॉल की पुष्टि आवश्यक है।",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("बॉट का नाम"),
    "botSkills": MessageLookupByLibrary.simpleMessage("कौशल"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "इस बॉट के लिए उपलब्ध दोबारा इस्तेमाल किए जा सकने वाले निर्देश चुनें।",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("रद्द करें"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("अवतार बदलें"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "चैट निष्पादन स्थिति",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "चैट इतिहास मिटा दिया गया",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("चैट्स"),
    "clear": MessageLookupByLibrary.simpleMessage("मिटाएं"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "स्वचालित स्मृति साफ़ करें",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("चैट साफ़ करें"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "चैट इतिहास साफ़ करें",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "बातचीत के पिन हटाएँ",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "बॉट जोड़ने के लिए ऊपरी दाएं कोने में + पर क्लिक करें",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "बातचीत बनाने के लिए नई चैट पर क्लिक करें",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("कमांड निष्पादन"),
    "compactNow": MessageLookupByLibrary.simpleMessage("अभी संपीड़ित करें"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "संदर्भ व्यवस्थित किया जा रहा है…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("विफल"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage("संपीड़न स्थिति"),
    "confirm": MessageLookupByLibrary.simpleMessage("पुष्टि करें"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "हटाने की पुष्टि करें",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "संपर्क जानकारी (वैकल्पिक)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "संदर्भ और स्मृति",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "संदर्भ संपीड़ित हुआ",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage("संदर्भ विंडो"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "वार्तालाप सारांश",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Stars टीम"),
    "customProvider": MessageLookupByLibrary.simpleMessage("कस्टम प्रदाता..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("डार्क मोड"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("गहन चिंतन"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "आप एक सहायक AI हैं। कृपया हिंदी में उत्तर दें।",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("हटाएं"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("बॉट हटाएं"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("चैट हटाएं"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "ऐप के बारे में और कानूनी जानकारी",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "दिखावट और भाषा",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "अपना अवतार और प्रदर्शन नाम बदलें।",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("सामान्य"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "सहायता और समर्थन",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "व्यक्तिगत जानकारी",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "बदलाव तुरंत लागू होते हैं और स्थानीय रूप से सहेजे जाते हैं।",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "अपनी प्रोफ़ाइल, दिखावट, भाषा और ऐप सहायता प्रबंधित करें।",
    ),
    "details": MessageLookupByLibrary.simpleMessage("विवरण"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "सभी के लिए बिना पुष्टि बंद करें",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "सभी टूल बंद करें",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "स्क्रिप्ट अक्षम करें",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("संपादित करें"),
    "editBot": MessageLookupByLibrary.simpleMessage("बॉट संपादित करें"),
    "editMemory": MessageLookupByLibrary.simpleMessage("स्मृति संपादित करें"),
    "editName": MessageLookupByLibrary.simpleMessage("नाम संपादित करें"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "उत्तर प्राप्त करने में विफल: सर्वर ने खाली प्रतिक्रिया लौटाई",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "सभी के लिए बिना पुष्टि चालू करें",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "सभी टूल चालू करें",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "स्क्रिप्ट सक्षम करें",
    ),
    "enableSkillScriptsDescription": m10,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "अलग की गई कौशल स्क्रिप्ट सक्षम करें?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "API पता दर्ज करें...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage(
      "API कुंजी दर्ज करें...",
    ),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "बॉट का नाम दर्ज करें...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "प्रदर्शन नाम दर्ज करें",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "कृपया नया नाम दर्ज करें",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "प्रदाता का नाम दर्ज करें...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "सिस्टम प्रॉम्प्ट दर्ज करें...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "सामग्री लोड करने में त्रुटि, कृपया बाद में पुनः प्रयास करें।",
    ),
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "अनुमानित उपयोग",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage("निष्पादन स्थिति"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "कृपया प्रतिक्रिया सामग्री दर्ज करें",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "कृपया हमें अपने विचार, समस्याएं या सुझाव बताएं ताकि हम ऐप को बेहतर बना सकें",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "यहां अपनी प्रतिक्रिया दर्ज करें...",
    ),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "प्रतिक्रिया जानकारी",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "भेजने में विफल, कृपया बाद में पुनः प्रयास करें",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "आपकी प्रतिक्रिया के लिए धन्यवाद!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "मॉडल सूची प्राप्त करें",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले मॉडल सूची प्राप्त करें",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("फ़ाइल स्थिति"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("संगीत"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("वाणी"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("वीडियो"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "कृपया बॉट का नाम, API पता और API कुंजी भरें",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage(
      "सिस्टम का अनुसरण करें",
    ),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("फॉन्ट साइज़"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "फॉन्ट साइज़ अपडेट किया गया",
    ),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("भूलें"),
    "generationFailed": MessageLookupByLibrary.simpleMessage("जनरेशन विफल"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "जनरेशन विफल · आंशिक उत्तर रखा गया",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "सहायता और प्रतिक्रिया",
    ),
    "home": MessageLookupByLibrary.simpleMessage("होम"),
    "idle": MessageLookupByLibrary.simpleMessage("निष्क्रिय"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "कौशल फ़ोल्डर आयात करें",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "कौशल ZIP आयात करें",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "कौशल आयात हो रहा है…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("इनपुट टोकन"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "अपडेट इंस्टॉल करें",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "सारांश सत्यापन में विफल रहा",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("अभी-अभी"),
    "languageChanged": m11,
    "languageSettings": MessageLookupByLibrary.simpleMessage("भाषा सेटिंग्स"),
    "lightMode": MessageLookupByLibrary.simpleMessage("लाइट मोड"),
    "manageMemory": MessageLookupByLibrary.simpleMessage(
      "स्मृति प्रबंधित करें",
    ),
    "manualActivation": MessageLookupByLibrary.simpleMessage("प्रति संदेश"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "ज़रूरत होने पर संदेश लिखने की जगह से कौशल चुनें।",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "पुष्टि के बिना",
    ),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP सर्वर"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "MCP सर्वर कनेक्ट करें और उनके टूल कैटलॉग खोजें। एजेंट बनाने के बाद टूल कॉन्फ़िगर करें।",
    ),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("आर्टिफैक्ट"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "स्मृति बदल गई; फिर प्रयास करें",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("सुधार"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("निर्णय"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("तथ्य"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("पसंद"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("खुला प्रश्न"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("कार्य"),
    "messageHint": MessageLookupByLibrary.simpleMessage("संदेश लिखें..."),
    "messageSkills": MessageLookupByLibrary.simpleMessage("कौशल"),
    "minutesAgo": m12,
    "model": MessageLookupByLibrary.simpleMessage("मॉडल"),
    "modelsRetrievedSuccess": m13,
    "name": MessageLookupByLibrary.simpleMessage("नाम"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("नाम अपडेट किया गया"),
    "newChat": MessageLookupByLibrary.simpleMessage("नई चैट"),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "कोई कनेक्टेड MCP टूल उपलब्ध नहीं है।",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "कोई कौशल नहीं जोड़ा गया",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "इस बॉट के लिए ज़रूरी इंस्टॉल किए गए कौशल जोड़ें।",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "कोई बॉट उपलब्ध नहीं है",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("अभी तक कोई चैट नहीं"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "कोई सामग्री नहीं मिली",
    ),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "अभी कोई वार्तालाप सारांश उपलब्ध नहीं है।",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "कोई मिलता-जुलता कौशल नहीं मिला",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "कोई मॉडल प्राप्त नहीं हुआ",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "कोई कौशल इंस्टॉल नहीं है",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md वाला Agent Skills फ़ोल्डर या ZIP आयात करें।",
    ),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "संपीड़ित करने के लिए पर्याप्त पुराना संदर्भ नहीं है",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("आउटपुट टोकन"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("आंशिक उत्तर"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("उत्पादन रोकें"),
    "pinMemory": MessageLookupByLibrary.simpleMessage("पिन करें"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "इस बातचीत के लिए चयनित कौशल पिन करें",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("पिन किया गया"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले API कुंजी दर्ज करें",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("टेक्स्ट प्रीव्यू"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("गोपनीयता नीति"),
    "processCommandCount": m14,
    "processDuration": m15,
    "processFileCount": m16,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "प्रक्रिया जानकारी",
    ),
    "processToolCount": m17,
    "profile": MessageLookupByLibrary.simpleMessage("प्रोफाइल"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "अपने सुझाव और प्रतिक्रिया प्रदान करें",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("प्रदाता"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("तर्क पूर्ण"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("तर्क जारी"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("तर्क बाधित"),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("पुनर्निर्माण"),
    "refresh": MessageLookupByLibrary.simpleMessage("ताज़ा करें"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "कैटलॉग रीफ़्रेश करें",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "कैटलॉग रीफ़्रेश हो रहे हैं…",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("कौशल हटाएँ"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "उत्तर रद्द किया गया",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "रोक दिया गया · आंशिक उत्तर रखा गया",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "डिफ़ॉल्ट पर रीसेट करें",
    ),
    "responseError": m18,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("पुनर्स्थापित करें"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "हाल के रखे गए चरण",
    ),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "जाँच चलाएँ",
    ),
    "save": MessageLookupByLibrary.simpleMessage("सहेजें"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("परिवर्तन सहेजें"),
    "searchMemory": MessageLookupByLibrary.simpleMessage("स्मृति खोजें"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("कौशल खोजें"),
    "selectBot": MessageLookupByLibrary.simpleMessage("बॉट चुनें"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("भाषा चुनें"),
    "selectModel": MessageLookupByLibrary.simpleMessage("मॉडल चुनें:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("प्रदाता चुनें:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("थीम चुनें"),
    "send": MessageLookupByLibrary.simpleMessage("भेजें"),
    "settings": MessageLookupByLibrary.simpleMessage("सेटिंग्स"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "बातचीत के संदेशों में निष्पादन विवरण दिखाएँ।",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "एसेट उपलब्ध हैं",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("संगतता"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "इस उदाहरण से कौशल सक्रिय होना चाहिए",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "उदाहरण उपयोगकर्ता अनुरोध",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "सक्रियण परिणाम",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage("कौशल का विवरण"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("सामग्री डाइजेस्ट"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("बंद"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("चालू"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("फ़ाइलें"),
    "skillImportFailed": m19,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "कौशल आयात किया गया",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("कौशल"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "दोबारा इस्तेमाल किए जा सकने वाले निर्देश इंस्टॉल करें और उन्हें बॉट से जोड़ें।",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "यह संस्करण कौशल की स्क्रिप्ट या कमांड नहीं चलाता।",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("प्रकाशक"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "संदर्भ फ़ाइलें उपलब्ध हैं",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md को केवल नियंत्रित प्रॉम्प्ट निर्देश के रूप में लोड किया जाता है; स्क्रिप्ट, कमांड और बाहरी टूल अक्षम रहते हैं।",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "डेस्कटॉप स्क्रिप्ट सैंडबॉक्स उपलब्ध",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "आपकी अनुमति तक स्क्रिप्ट बंद रहती हैं। हर कॉल के लिए फिर भी स्वीकृति आवश्यक है।",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "कौशल स्क्रिप्ट उपलब्ध नहीं",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "यह प्लेटफ़ॉर्म आवश्यक अलगाव नहीं देता। निर्देश और संसाधन उपलब्ध रहेंगे।",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "कौशल स्क्रिप्ट सेटिंग अपडेट हुई।",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "स्क्रिप्ट इंस्टॉल हैं, लेकिन उनका निष्पादन अक्षम है।",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "स्क्रिप्ट सक्षम",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("हस्ताक्षर"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "अमान्य हस्ताक्षर",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "अज्ञात प्रकाशक",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage(
      "अहस्ताक्षरित",
    ),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "सत्यापित हस्ताक्षर",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("स्रोत"),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("स्वचालित"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "अपडेट उपलब्ध",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("मैन्युअल"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("सूचित करें"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("पिन किया गया"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage("अपडेट नीति"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "सत्यापन टिप्पणियाँ",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("संस्करण"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "चैट शुरू करने के लिए नीचे इनपुट फील्ड में संदेश भेजें",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("चैटिंग शुरू करें"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("सक्रिय"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("संलग्न"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "स्वीकृति की प्रतीक्षा",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("रद्द"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("पूर्ण"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("अस्वीकृत"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("डुप्लिकेट कॉल"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("विफल"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("जनरेट किया गया"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("प्रगति में"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("दर्ज"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("अनुरोधित"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("चल रहा है"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("छोड़ा गया"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("समय समाप्त"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("अज्ञात"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "संरचित प्रक्रिया जानकारी",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("प्रतिक्रिया भेजें"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("सारांशित संदेश"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("सिस्टम प्रॉम्प्ट"),
    "testSkill": MessageLookupByLibrary.simpleMessage("जाँचें"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "विवरण जाँचें",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "थीम डार्क मोड पर सेट की गई",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "थीम लाइट मोड पर सेट की गई",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "थीम सिस्टम के अनुसार सेट की गई",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("थीम सेटिंग्स"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage("सोचना पूर्ण"),
    "thinkingCompletedWithDuration": m20,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("सोच रहा है…"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "एक बार अनुमति",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("अस्वीकृत"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("टूल कॉल"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("विनाशकारी"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage(
      "केवल-पढ़ने योग्य",
    ),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("लिखना"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("अंतर्निहित"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "स्किल स्क्रिप्ट",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("टाइप कर रहा है..."),
    "uninstall": MessageLookupByLibrary.simpleMessage("अनइंस्टॉल करें"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "कौशल अनइंस्टॉल करें",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("अनपिन करें"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("फ़ाइल अपलोड करें"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("छवि अपलोड करें"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता समझौता"),
    "version": MessageLookupByLibrary.simpleMessage("संस्करण 1.0.0"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("सारांश देखें"),
  };
}
