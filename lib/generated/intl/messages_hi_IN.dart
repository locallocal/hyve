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

  static String m9(language) => "भाषा ${language} में बदली गई";

  static String m10(minutes) => "${minutes} मिनट पहले";

  static String m11(count) => "सफलतापूर्वक ${count} मॉडल प्राप्त किए गए";

  static String m12(count) => "${count} कमांड निष्पादन";

  static String m13(duration) => "अवधि ${duration}";

  static String m14(count) => "${count} फ़ाइल बदलाव";

  static String m15(count) => "${count} टूल कॉल";

  static String m16(error) => "उत्तर प्राप्त करने में विफल: ${error}";

  static String m17(duration) => "सोचना पूर्ण · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("बॉट्स"),
    "about": MessageLookupByLibrary.simpleMessage("के बारे में"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Stars के बारे में"),
    "addBot": MessageLookupByLibrary.simpleMessage("बॉट जोड़ें"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "एप्लिकेशन फॉन्ट साइज़ समायोजित करें",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "फॉन्ट साइज़ समायोजित करें",
    ),
    "apiAddress": MessageLookupByLibrary.simpleMessage("API पता:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API कुंजी"),
    "apiType": MessageLookupByLibrary.simpleMessage("API प्रकार:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "एक सरल लेकिन शक्तिशाली AI चैट एप्लयन जो आपको कहीं भी, कभी भी AI के साथ चैट करने की अनुमति देता है।",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Stars - AI चैट सहायक"),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("बॉट अवतार"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("बॉट का नाम"),
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
    "clearChat": MessageLookupByLibrary.simpleMessage("चैट साफ़ करें"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "चैट इतिहास साफ़ करें",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "बॉट जोड़ने के लिए ऊपरी दाएं कोने में + पर क्लिक करें",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "बातचीत बनाने के लिए नई चैट पर क्लिक करें",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("कमांड निष्पादन"),
    "confirm": MessageLookupByLibrary.simpleMessage("पुष्टि करें"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
      "हटाने की पुष्टि करें",
    ),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "संपर्क जानकारी (वैकल्पिक)",
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
    "editBot": MessageLookupByLibrary.simpleMessage("बॉट संपादित करें"),
    "editName": MessageLookupByLibrary.simpleMessage("नाम संपादित करें"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "उत्तर प्राप्त करने में विफल: सर्वर ने खाली प्रतिक्रिया लौटाई",
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
    "generationFailed": MessageLookupByLibrary.simpleMessage("जनरेशन विफल"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "जनरेशन विफल · आंशिक उत्तर रखा गया",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage(
      "सहायता और प्रतिक्रिया",
    ),
    "home": MessageLookupByLibrary.simpleMessage("होम"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("इनपुट टोकन"),
    "justNow": MessageLookupByLibrary.simpleMessage("अभी-अभी"),
    "languageChanged": m9,
    "languageSettings": MessageLookupByLibrary.simpleMessage("भाषा सेटिंग्स"),
    "lightMode": MessageLookupByLibrary.simpleMessage("लाइट मोड"),
    "messageHint": MessageLookupByLibrary.simpleMessage("संदेश लिखें..."),
    "minutesAgo": m10,
    "model": MessageLookupByLibrary.simpleMessage("मॉडल"),
    "modelsRetrievedSuccess": m11,
    "name": MessageLookupByLibrary.simpleMessage("नाम"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("नाम अपडेट किया गया"),
    "newChat": MessageLookupByLibrary.simpleMessage("नई चैट"),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "कोई बॉट उपलब्ध नहीं है",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("अभी तक कोई चैट नहीं"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "कोई सामग्री नहीं मिली",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "कोई मॉडल प्राप्त नहीं हुआ",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("आउटपुट टोकन"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("आंशिक उत्तर"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("उत्पादन रोकें"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "कृपया पहले API कुंजी दर्ज करें",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("टेक्स्ट प्रीव्यू"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("गोपनीयता नीति"),
    "processCommandCount": m12,
    "processDuration": m13,
    "processFileCount": m14,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "प्रक्रिया जानकारी",
    ),
    "processToolCount": m15,
    "profile": MessageLookupByLibrary.simpleMessage("प्रोफाइल"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "अपने सुझाव और प्रतिक्रिया प्रदान करें",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("प्रदाता"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("तर्क पूर्ण"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("तर्क जारी"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("तर्क बाधित"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "उत्तर रद्द किया गया",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "रोक दिया गया · आंशिक उत्तर रखा गया",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage(
      "डिफ़ॉल्ट पर रीसेट करें",
    ),
    "responseError": m16,
    "save": MessageLookupByLibrary.simpleMessage("सहेजें"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("परिवर्तन सहेजें"),
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
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "चैट शुरू करने के लिए नीचे इनपुट फील्ड में संदेश भेजें",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("चैटिंग शुरू करें"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("संलग्न"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("रद्द"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("पूर्ण"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("विफल"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("जनरेट किया गया"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("प्रगति में"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("दर्ज"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("चल रहा है"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "संरचित प्रक्रिया जानकारी",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("प्रतिक्रिया भेजें"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("सिस्टम प्रॉम्प्ट"),
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
    "thinkingCompletedWithDuration": m17,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("सोच रहा है…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("टूल कॉल"),
    "typing": MessageLookupByLibrary.simpleMessage("टाइप कर रहा है..."),
    "uploadFile": MessageLookupByLibrary.simpleMessage("फ़ाइल अपलोड करें"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("छवि अपलोड करें"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("उपयोगकर्ता समझौता"),
    "version": MessageLookupByLibrary.simpleMessage("संस्करण 1.0.0"),
  };
}
