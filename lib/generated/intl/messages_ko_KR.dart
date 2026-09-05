// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko_KR locale. All the
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
  String get localeName => 'ko_KR';

  static String m0(name) => "봇 \"${name}\"이(가) 추가되었습니다";

  static String m1(botName) => "\"${botName}\"이(가) 삭제되었습니다";

  static String m2(botName) =>
      "안녕하세요! 저는 ${botName}이라는 AI 어시스턴트입니다. 어떤 질문이든 편하게 물어보세요, 최선을 다해 도와드리겠습니다.";

  static String m3(botName) => "${botName}이(가) 입력 중...";

  static String m4(botName) => "봇 ${botName}이(가) 업데이트되었습니다";

  static String m5(botName) => "${botName}와(과)의 채팅이 삭제되었습니다";

  static String m6(botName) =>
      "봇을 삭제하면 관련된 모든 채팅도 삭제됩니다. ${botName}을(를) 정말로 삭제하시겠습니까?";

  static String m7(botName) =>
      "채팅을 삭제하면 모든 채팅 기록이 삭제됩니다. ${botName}와(과)의 채팅을 정말로 삭제하시겠습니까?";

  static String m8(name) => "삭제 ${name}? 캐시된 도구 카탈로그와 보안 자격 증명도 제거됩니다.";

  static String m9(name) => "${name} 스킬을 제거할까요? 봇 연결도 함께 삭제됩니다.";

  static String m10(year) => "© ${year} Hyve 팀";

  static String m11(error) => "채팅을 만들 수 없습니다: ${error}";

  static String m12(error) => "프로젝트를 생성할 수 없습니다: ${error}";

  static String m13(error) => "채팅을 삭제할 수 없습니다: ${error}";

  static String m14(milliseconds) => "${milliseconds}밀리초";

  static String m15(seconds) => "${seconds}초";

  static String m16(name) =>
      "${name}에서 선언된 스크립트를 도구로 등록하도록 허용합니다. 각 호출에는 계속 승인이 필요합니다.";

  static String m17(count) => "${count} 파일";

  static String m18(error) => "이미지 생성 실패: ${error}";

  static String m19(error) => "음악을 생성할 수 없습니다: ${error}";

  static String m20(error) => "음성을 생성할 수 없습니다: ${error}";

  static String m21(error) => "동영상을 생성할 수 없습니다: ${error}";

  static String m22(count) => "${count} 항목";

  static String m23(language) => "언어가 ${language}(으)로 설정되었습니다";

  static String m24(error) => "MCP 연결 실패: ${error}";

  static String m25(count) => "${count} 구성됨(값 숨김)";

  static String m26(minutes) => "${minutes}분 전";

  static String m27(count) => "${count}개의 모델을 성공적으로 검색했습니다";

  static String m28(count) => "명령 실행 ${count}회";

  static String m29(duration) => "소요 시간 ${duration}";

  static String m30(count) => "파일 변경 ${count}건";

  static String m31(count) => "도구 호출 ${count}회";

  static String m32(id) => "에이전트 ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · 아티팩트 ${artifactId}";

  static String m34(code) => "아티팩트 작업 실패(${code})";

  static String m35(ids) => "아티팩트 버전: ${ids}";

  static String m36(index) => "첨부파일 ${index}";

  static String m37(count) => "${count} 보류 중";

  static String m38(path) =>
      "${path}의 모든 버전을 삭제하시겠습니까? 메시지나 전달에서 참조하는 아티팩트는 삭제할 수 없습니다.";

  static String m39(depth) => "전달 깊이: ${depth}";

  static String m40(id, status) => "전달 실행: ${id} · ${status}";

  static String m41(value) => "기간: ${value}";

  static String m42(value) => "오류: ${value}";

  static String m43(id) => "이벤트: ${id}";

  static String m44(sequence) => "이벤트 #${sequence}";

  static String m45(count) => "${Intl.plural(count, other: '아티팩트 ${count}개')}";

  static String m46(code) => "회원 업데이트 실패(${code})";

  static String m47(agentId, previous, current) =>
      "${agentId}가 ${previous}에서 ${current}로 변경되었습니다.";

  static String m48(agentId, current) => "${agentId}는 현재 ${current}입니다.";

  static String m49(id) => "메시지 ID: ${id}";

  static String m50(code) => "메시지 전송 실패(${code})";

  static String m51(sequence) => "메시지 #${sequence}";

  static String m52(processed, latest) => "처리됨 ${processed} / 최신 ${latest}";

  static String m53(count) => "${Intl.plural(count, other: '수신자 ${count}명')}";

  static String m54(count) =>
      "${Intl.plural(count, other: '참조 메시지 ${count}개')}";

  static String m55(name) => "${name}을 제거하시겠습니까?";

  static String m56(name) => "드래그하여 재정렬 ${name}";

  static String m57(sequence) => "메시지 #${sequence}에 답장하기";

  static String m58(id) => "루트 실행: ${id}";

  static String m59(count) => "${Intl.plural(count, other: '실행 ${count}개')}";

  static String m60(runId) => " · 실행 ${runId}";

  static String m61(value) => "출처: ${value}";

  static String m62(id) => "소스 실행: ${id}";

  static String m63(value) => "목표 실행: ${value}";

  static String m64(input, output) => "입력 ${input} · 출력 ${output}";

  static String m65(id, status) => "턴: ${id} · ${status}";

  static String m66(mime, digest) =>
      "이 유형에는 인앱 미리보기가 지원되지 않습니다. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "버전 ${version} · 에이전트 ${actor}${run}";

  static String m68(error) => "응답을 가져오지 못했습니다: ${error}";

  static String m69(error) => "이미지를 저장할 수 없습니다: ${error}";

  static String m70(count) => "${count} 선택됨";

  static String m71(error) => "이미지를 공유할 수 없습니다: ${error}";

  static String m72(error) => "스킬을 가져올 수 없습니다: ${error}";

  static String m73(duration) => "생각 완료 · ${duration}";

  static String m74(error) => "동영상 재생 오류: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("봇"),
    "about": MessageLookupByLibrary.simpleMessage("정보"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Hyve 정보"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "활성 요청은 취소할 수 없습니다. 완료될 때까지 기다리세요.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "활성 요청을 중지할 수 없습니다.",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("첨부파일"),
    "addBot": MessageLookupByLibrary.simpleMessage("봇 추가"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage("MCP 서버 추가"),
    "addSkill": MessageLookupByLibrary.simpleMessage("스킬 추가"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage("앱 글꼴 크기 조정"),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage("글꼴 크기 조정"),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "이 에이전트를 사용하는 프로젝트를 열어 컨텍스트와 메모리를 확인하고 관리하세요.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("에이전트 메모리"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "자동 메모리 진화",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "장기 메모리는 이 에이전트에 속하며 프로젝트 간에 재사용할 수 있습니다.",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "설치된 모든 스킬이 추가되었습니다.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("항상 사용"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "모든 텍스트 요청에 이 스킬을 삽입합니다.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("항상 사용"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("API 주소:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("API 키"),
    "apiType": MessageLookupByLibrary.simpleMessage("API 유형:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "언제 어디서나 AI와 채팅할 수 있는 간단하면서도 강력한 AI 채팅 애플리케이션입니다.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Hyve - AI 채팅 어시스턴트"),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "시스템 프롬프트",
    ),
    "applicationInjectedPromptDescription":
        MessageLookupByLibrary.simpleMessage(
          "Hyve에서 관리하며 모든 모델 요청에 주입됩니다. 현재 에이전트와 대화 식별자는 런타임에 추가되며 편집할 수 없습니다.",
        ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("첨부파일"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("첨부된 이미지"),
    "attachments": MessageLookupByLibrary.simpleMessage("첨부파일"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("자동"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "지원되는 모델이 설명을 바탕으로 이 스킬을 활성화합니다.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "이 제공자는 수동 스킬만 지원합니다.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage("자동 메모리"),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "자동 요약은 부정확할 수 있습니다. 현재 메시지가 항상 우선합니다.",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage("일일 사용량으로 돌아가기"),
    "basicInformation": MessageLookupByLibrary.simpleMessage("기본 정보"),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("봇 아바타"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage("봇 정보"),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "이 에이전트에서 MCP 도구를 활성화합니다. 도구 호출에는 기본적으로 확인이 필요합니다.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("봇 이름"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "검색은 봇 이름으로 목록을 필터링합니다.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("스킬"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "이 봇에서 사용할 재사용 가능한 지침을 선택하세요.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "이 봇을 사용할 수 없습니다.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("아바타 변경"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("저장됨"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "검색은 봇 이름과 최신 메시지를 일치시킵니다.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("채팅"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("갤러리"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage("첨부파일 지우기"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage("자동 메모리 지우기"),
    "clearChat": MessageLookupByLibrary.simpleMessage("채팅 지우기"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage("대화 고정 해제"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("검색 지우기"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "날짜를 선택해 시간별 사용량을 확인하세요.",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "오른쪽 상단의 +를 클릭하여 봇 추가",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "새 채팅을 클릭하여 대화를 만드세요",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage("명령 실행"),
    "compactNow": MessageLookupByLibrary.simpleMessage("지금 압축"),
    "compactingContext": MessageLookupByLibrary.simpleMessage("컨텍스트 정리 중…"),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage("압축 상태"),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("삭제 확인"),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage("연락처 정보(선택 사항)"),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage("컨텍스트와 메모리"),
    "contextCompacted": MessageLookupByLibrary.simpleMessage("컨텍스트가 압축되었습니다"),
    "contextWindow": MessageLookupByLibrary.simpleMessage("컨텍스트 창"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage("대화 요약"),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage("대화별 토큰 비율"),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("API 키 복사"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "설치 위치 복사",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("프로젝트 만들기"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("만드는 중…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("생성 시간"),
    "customProvider": MessageLookupByLibrary.simpleMessage("사용자 정의 제공업체..."),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("일일 사용량"),
    "darkMode": MessageLookupByLibrary.simpleMessage("다크 모드"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "이 데이터베이스는 더 최신 버전의 Hyve에서 생성되었습니다. 앱을 업데이트한 후 열어 주세요.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "데이터베이스 무결성 검사에 실패했으며 현재 버전의 백업에서도 복구하지 못했습니다.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("심층 사고"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "당신은 도움이 되는 AI 어시스턴트입니다. 한국어로 대답해 주세요.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("봇 삭제"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("채팅 삭제"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage("MCP 서버 삭제"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "앱 정보 및 법적 고지",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "모양 및 언어",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "아바타와 표시 이름을 변경합니다.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("일반"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage("도움말 및 지원"),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage("개인 정보"),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "변경 사항은 즉시 적용되며 로컬에 저장됩니다.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "프로필, 모양, 언어 및 앱 지원을 관리합니다.",
    ),
    "details": MessageLookupByLibrary.simpleMessage("세부 정보"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("플레이 준비 완료"),
    "directPreview": MessageLookupByLibrary.simpleMessage("미리보기 준비 완료"),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "모두 확인 없이 실행 해제",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage("모든 도구 끄기"),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage("스크립트 비활성화"),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("편집"),
    "editBot": MessageLookupByLibrary.simpleMessage("봇 편집"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage("MCP 서버 편집"),
    "editMemory": MessageLookupByLibrary.simpleMessage("메모리 편집"),
    "editName": MessageLookupByLibrary.simpleMessage("이름 수정"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "응답을 가져오지 못했습니다: 서버가 빈 응답을 반환했습니다",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "모두 확인 없이 실행",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage("모든 도구 켜기"),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage("스크립트 활성화"),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "격리된 스킬 스크립트를 활성화할까요?",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage("API 주소 입력..."),
    "enterApiKey": MessageLookupByLibrary.simpleMessage("API 키 입력..."),
    "enterBotName": MessageLookupByLibrary.simpleMessage("봇 이름 입력..."),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage("표시 이름을 입력하세요"),
    "enterNewName": MessageLookupByLibrary.simpleMessage("새 이름을 입력하세요"),
    "enterProviderName": MessageLookupByLibrary.simpleMessage("제공업체 이름 입력..."),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage("시스템 프롬프트 입력..."),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "콘텐츠를 로드하는 중 오류가 발생했습니다. 나중에 다시 시도해 주세요.",
    ),
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage("예상 사용량"),
    "executionStatus": MessageLookupByLibrary.simpleMessage("실행 상태"),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "피드백 내용을 입력해 주세요",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "앱 개선에 도움이 될 수 있도록 생각, 문제 또는 제안을 알려주세요",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage("여기에 피드백을 입력하세요..."),
    "feedbackInformation": MessageLookupByLibrary.simpleMessage("피드백 정보"),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "제출 실패, 나중에 다시 시도해 주세요",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "피드백을 보내주셔서 감사합니다!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage("모델 목록 가져오기"),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "먼저 모델 목록을 가져오세요",
    ),
    "fileAttachment": MessageLookupByLibrary.simpleMessage("파일첨부"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("파일 결과"),
    "fileStatus": MessageLookupByLibrary.simpleMessage("파일 상태"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("음악"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("음성"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("동영상"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "봇 이름, API 주소 및 API 키를 입력하세요",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("시스템 설정 따르기"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage("글꼴 크기"),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage("글꼴 크기가 업데이트되었습니다"),
    "forgetMemory": MessageLookupByLibrary.simpleMessage("잊기"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("이미지 생성됨"),
    "generating": MessageLookupByLibrary.simpleMessage("생성 중…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "이미지를 생성하는 중입니다. 잠시 기다려 주세요...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage("생성 실패"),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "생성 실패 · 부분 응답 유지",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("도움말 및 피드백"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("API 키 숨기기"),
    "hideInspector": MessageLookupByLibrary.simpleMessage("봇 정보 숨기기"),
    "hideSidebar": MessageLookupByLibrary.simpleMessage("사이드바 숨기기"),
    "home": MessageLookupByLibrary.simpleMessage("홈"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("시간당 사용량"),
    "idle": MessageLookupByLibrary.simpleMessage("유휴"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("이미지 첨부"),
    "imageResult": MessageLookupByLibrary.simpleMessage("이미지 검색결과"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "갤러리에 이미지가 저장되었습니다.",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("이미지 크기"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("이미지 스타일"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage("스킬 폴더 가져오기"),
    "importSkillZip": MessageLookupByLibrary.simpleMessage("스킬 ZIP 가져오기"),
    "importingSkill": MessageLookupByLibrary.simpleMessage("스킬 가져오는 중…"),
    "includesDuration": MessageLookupByLibrary.simpleMessage("기간 포함"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("입력 토큰"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage("업데이트 설치"),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "생성된 요약이 검증을 통과하지 못했습니다",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage("최신으로 이동"),
    "justNow": MessageLookupByLibrary.simpleMessage("방금"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage("언어 설정"),
    "lightMode": MessageLookupByLibrary.simpleMessage("라이트 모드"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage("이 링크를 열 수 없습니다."),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "로컬 프로세스 기반 MCP 서버는 플랫폼 보안 검토가 진행되는 동안 비활성화된 상태로 유지됩니다.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("메모리 관리"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("메시지별"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "필요할 때 메시지 입력창에서 스킬을 선택하세요.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "OAuth/Bearer 액세스 토큰",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("인수"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나의 인수를 입력하세요.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("인증"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage("승인 필요"),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("명령"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "실행 파일 이름 또는 절대 경로. 이 명령은 셸 없이 직접 실행됩니다.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "커뮤니케이션 채널",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("연결됨"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("연결 중"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage("연결 오류"),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("연결"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("연결 끊김"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage("스트리밍 가능한 HTTP 엔드포인트"),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage("환경 변수"),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나의 KEY=VALUE를 입력하세요. 값은 운영 체제의 보안 자격 증명 저장소에 저장됩니다. 기존 값을 유지하려면 편집하는 동안 비워 두세요.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "원격 MCP 엔드포인트는 HTTPS를 사용해야 합니다.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "환경 변수는 한 줄에 하나의 KEY=VALUE 항목을 사용해야 합니다.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "stdio 서버는 이 컴퓨터에서 명령을 실행합니다. 신뢰할 수 있는 서버와 환경 변수만 추가하세요.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "로컬 프로세스 보안",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage("확인 없이 실행"),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("없음"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "개인, 로컬 및 링크-로컬 MCP 엔드포인트가 차단됩니다.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage("프로세스 ID(PID)"),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage("실행되지 않음"),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("달리기"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("시작 시간:"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage("프로세스 상태"),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "Hyve는 발견된 도구 카탈로그를 저장합니다. 에이전트를 편집할 때 개별 도구를 활성화합니다. 해당 에이전트만이 이를 모델에 노출할 수 있습니다.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "MCP 요청 시간이 초과되었습니다.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "보안 환경 변수",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage("서버 세부정보"),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("서버 이름"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("MCP 서버"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "MCP 서버를 연결하고 도구 카탈로그를 검색합니다. 에이전트를 만든 후 도구를 구성하세요.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr(운영 체제 파이프)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "로컬 프로세스 및 통신",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "stdio MCP 명령을 시작할 수 없습니다.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "기존 보안 자격증명을 유지하려면 비워두세요.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "운영 체제의 보안 자격 증명 저장소에 저장됩니다.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "이 도구에는 지원되지 않는 입력 스키마가 있으므로 선택할 수 없습니다.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("도구"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("교통"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (로컬 프로세스)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "MCP 서버가 지원되지 않는 프로토콜 버전을 사용합니다.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("메모리"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("결과물"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "메모리가 변경되었습니다. 다시 시도하세요",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("수정"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("결정"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("사실"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("환경 설정"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage("열린 질문"),
    "memoryTask": MessageLookupByLibrary.simpleMessage("작업"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "@를 사용하여 프로젝트 에이전트를 한 명 이상 언급하세요.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "메시지가 클립보드에 복사되었습니다.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "메시지를 입력하고 @로 에이전트를 멘션하세요...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("스킬"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("오디오"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("파일"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("이미지"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("다중 모드"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("음악"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("실시간"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("연설"),
    "modalityText": MessageLookupByLibrary.simpleMessage("텍스트"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("동영상"),
    "model": MessageLookupByLibrary.simpleMessage("모델"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage("모델 구성"),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage("모델 컨텍스트 크기"),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("입력"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("출력"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage("수정 시간"),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("음악 생성됨"),
    "musicResult": MessageLookupByLibrary.simpleMessage("음악 검색결과"),
    "name": MessageLookupByLibrary.simpleMessage("이름"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("이름이 업데이트되었습니다"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "새로운 봇은 편집을 위해 작업 공간에 남아 있습니다.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("새 채팅"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "작업 공간에서 바로 새 채팅이 열립니다.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("새 프로젝트"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "이 에이전트에는 아직 장기 메모리가 없습니다.",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "연결되어 사용 가능한 MCP 도구가 없습니다.",
    ),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage("추가된 스킬 없음"),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "이 봇에 필요한 설치된 스킬을 추가하세요.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage("사용 가능한 봇이 없습니다"),
    "noChats": MessageLookupByLibrary.simpleMessage("아직 채팅이 없습니다"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage("콘텐츠가 반환되지 않음"),
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "아직 사용할 수 있는 대화 요약이 없습니다.",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage("일치하는 봇이 없습니다."),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "일치하는 채팅을 찾을 수 없습니다.",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "일치하는 MCP 서버를 찾을 수 없습니다.",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "일치하는 도구를 찾을 수 없습니다.",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "일치하는 스킬을 찾을 수 없음",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("MCP 서버 없음"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "스트리밍 가능한 HTTP 또는 데스크톱 stdio 서버를 추가하여 도구 카탈로그를 검색하세요.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "도구가 발견되지 않았습니다. 연결을 확인하고 새로 고침하세요.",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage("검색된 모델이 없습니다"),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage("설치된 스킬 없음"),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md가 포함된 Agent Skills 폴더 또는 ZIP을 가져오세요.",
    ),
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "토큰 사용량이 기록되지 않았습니다.",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("지원되지 않음"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "압축할 이전 컨텍스트가 충분하지 않습니다",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "이 분리된 채팅을 삭제하거나 누락된 봇을 다시 만드세요.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("출력 토큰"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("부분 응답"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("오디오 일시정지"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("생성 일시 중지"),
    "pinMemory": MessageLookupByLibrary.simpleMessage("고정"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "선택한 스킬을 이 대화에 고정",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("고정됨"),
    "playAudio": MessageLookupByLibrary.simpleMessage("오디오 재생"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "API 키를 먼저 입력하세요",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "이미지 생성을 위한 설명을 입력해주세요",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "음악 생성에 대한 설명을 입력하세요.",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "음성 생성에 대한 설명을 입력하세요.",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "동영상 생성에 대한 설명을 입력하세요.",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage("텍스트 효과 미리보기"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("개인정보 처리방침"),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage("프로세스 정보"),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("프로필"),
    "projectActive": MessageLookupByLibrary.simpleMessage("활성"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage("따라잡기"),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage("따라잡았어"),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage("결정"),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("일시중지됨"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage("답글"),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("건너뛰었습니다"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage("답변드립니다"),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("에이전트 추가"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "사용 가능한 에이전트를 검색하여 이 프로젝트에 추가하세요.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage("첨부파일 추가"),
    "projectAgent": MessageLookupByLibrary.simpleMessage("에이전트"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage("에이전트 메모리"),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("모든 유형"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "이 아티팩트는 참조된 것이므로 삭제할 수 없습니다.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage("아카이브"),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "첨부파일",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("오디오"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("코드"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage("데이터세트"),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage("문서"),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage("생성됨"),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("이미지"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("기타"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("동영상"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "해당 프로젝트 경로가 이미 존재합니다.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "유효한 프로젝트 상대 경로를 사용하세요.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage("모든 아티팩트"),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "파일이 아티팩트 크기 제한을 초과했습니다.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "심볼릭 링크를 가져올 수 없습니다.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "현재 버전이 변경되었습니다. 편집하기 전에 다시 엽니다.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "아티팩트 버전",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage("프로젝트 아티팩트"),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "프로젝트 파일을 찾아보고, 버전 기록을 미리 보고, 시스템 앱으로 파일을 엽니다.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage("감사 세부정보"),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage("감사 이벤트"),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage("메시지로 돌아가기"),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "상위 폴더로 돌아가기",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "메시지를 입력하세요. @가 없으면 모든 활성 상담원에게 방송됩니다.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage("루트 체인 취소"),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "하위 전달을 포함하여 이 루트 메시지 체인의 활성 실행이 중지됩니다. 다른 체인은 계속됩니다.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "이 루트 메시지 체인을 취소하시겠습니까?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage("실행 취소"),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "이 실행만 중지됩니다. 해당 차례의 다른 활성 실행은 계속됩니다.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "이 실행을 취소하시겠습니까?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage("회전 취소"),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "이번 턴에 활성화된 모든 실행이 중지됩니다. 완료된 결과는 보관됩니다.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "이번 턴을 취소하시겠습니까?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("닫기"),
    "projectContent": MessageLookupByLibrary.simpleMessage("내용"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage("컨텍스트 보고서"),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "메시지를 통해 다루었습니다.",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("만들기"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("새 텍스트"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage("버전 생성"),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage("결정 취소됨"),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage("결정 요청 실패"),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage("잘못된 결정 응답"),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "결정 시간이 초과되었습니다.",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("결정"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "아티팩트를 삭제하시겠습니까?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "에이전트, 스킬, 구성, 장기 기억은 삭제되지 않습니다.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage("삭제된 에이전트"),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "가져올 파일을 여기에 드롭하세요.",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "공동 작업을 시작하려면 메시지를 보내세요. @가 없는 메시지는 브로드캐스트됩니다.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "아직 메시지가 없습니다",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "에이전트 전달",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage("상담원 메시지"),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "아티팩트 변경됨",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "멤버십 변경됨",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "참가 결정",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "실행 상태가 변경되었습니다.",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage("시스템 공지"),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage("사용자 메시지"),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "실행 내역, 참여 결정, 토큰 사용 및 감사 이벤트를 검토합니다.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage("실행 세부정보"),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage("실행 기록"),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage("파일 가져오기"),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage("최신 항목으로 이동"),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "이전 이벤트 로드",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "프로젝트 로드 중",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage("프로젝트 구성원"),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "처리를 모니터링하고 에이전트 순서, 아티팩트 액세스 및 참여를 관리합니다.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage("메모리 버전"),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "언급된 에이전트는 더 이상 활성 상태가 아닙니다. 제거하거나 다시 선택하세요.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage("이동 또는 이름 바꾸기"),
    "projectName": MessageLookupByLibrary.simpleMessage("프로젝트 이름"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage("프로젝트 이름을 입력하세요"),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "프로젝트 이름을 입력하세요.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "새로운 텍스트 아티팩트",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "이 프로젝트에는 활성 에이전트가 없습니다. 메시지는 저장되지만 답장은 생성되지 않습니다.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage("활성 에이전트 없음"),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "일치하는 프로젝트 아티팩트가 없습니다.",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "아직 감사 이벤트가 없습니다.",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "추가할 수 있는 상담원이 없습니다.",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "아직 실행 기록이 없습니다.",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "일치하는 상담원 없음",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "아직 프로젝트 구성원이 없습니다.",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "상담원은 이 메시지에 아무것도 추가할 필요가 없습니다.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "시스템 앱으로 열기",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("건너뛰기"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage("답장"),
    "projectPassed": MessageLookupByLibrary.simpleMessage("건너뜀"),
    "projectPause": MessageLookupByLibrary.simpleMessage("일시중지"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("일시 중지됨"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "미리보기 및 버전 기록",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "처음 32KiB만 표시됩니다. 에이전트는 계속해서 청크 단위로 읽을 수 있습니다.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage("프로젝트 상대 경로"),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage("놓아서 가져오기"),
    "projectRemove": MessageLookupByLibrary.simpleMessage("제거"),
    "projectRemoveActiveMemberDescription":
        MessageLookupByLibrary.simpleMessage(
          "에이전트가 실행 중입니다. 제거하면 해당 실행이 취소되며 다른 에이전트는 계속 진행합니다.",
        ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "에이전트는 새 프로젝트 메시지 수신을 중단합니다.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "공개 답변 요청됨",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("재개"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage("방송"),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("전달"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage("타겟"),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("취소됨"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("완료됨"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("결정"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("전달 중"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage("실행 ID"),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage("중단됨"),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage("한도 초과"),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("건너뜀"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("결정"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("전달"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("답장"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("준비 중"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("대기 중"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("실행 중"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage("시간이 초과되었습니다"),
    "projectRuns": MessageLookupByLibrary.simpleMessage("실행"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "프로젝트 아티팩트로 저장",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "프로젝트 아티팩트로 저장됩니다.",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("검색"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage("검색 에이전트"),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "이름, 경로, 콘텐츠 검색",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "이용 가능한 에이전트 검색",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("보내는 중"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("스킬"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage("아티팩트 접근 권한"),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("없음"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("읽기"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "읽기 및 쓰기",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage("요약 세그먼트"),
    "projectSystem": MessageLookupByLibrary.simpleMessage("시스템"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("시스템"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("도구"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("취소됨"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("완료됨"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("생성됨"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("결정"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("전달 중"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("파견"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("일부"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("답글"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "이 파일은 시스템 앱으로 열 수 없습니다.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "이 버전을 읽을 수 없습니다",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "아티팩트 액세스 업데이트 중",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("사용자"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage("프로젝트 작업공간"),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage("새 버전 작성"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage("의견과 제안을 제공해 주세요"),
    "provider": MessageLookupByLibrary.simpleMessage("제공자"),
    "providerInformation": MessageLookupByLibrary.simpleMessage("제공자 정보"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage("추론 완료"),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage("추론 진행 중"),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage("추론 중단"),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("다시 구축"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage("참조 오디오"),
    "refresh": MessageLookupByLibrary.simpleMessage("새로 고침"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage("도구 새로 고침"),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage("카탈로그 새로 고침"),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "카탈로그 새로 고치는 중…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("원격 MCP 전용"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage("파일 제거"),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage("이미지 제거"),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage("MCP 서버 제거"),
    "removeSkill": MessageLookupByLibrary.simpleMessage("스킬 제거"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage("응답이 취소되었습니다"),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "중지됨 · 부분 응답 유지",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("기본값으로 재설정"),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("복원"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage("유지된 최근 턴"),
    "retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage("테스트 실행"),
    "save": MessageLookupByLibrary.simpleMessage("저장"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage("저장 및 연결"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("변경사항 저장"),
    "saveImage": MessageLookupByLibrary.simpleMessage("이미지 저장"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "갤러리에 저장할 수 없습니다.",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("저장 중..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("봇 검색"),
    "searchChats": MessageLookupByLibrary.simpleMessage("대화 검색"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage("MCP 서버 검색"),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage("검색 도구"),
    "searchMemory": MessageLookupByLibrary.simpleMessage("메모리 검색"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("스킬 검색"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "하나 이상의 봇을 선택하세요.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("봇 선택"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("언어 선택"),
    "selectModel": MessageLookupByLibrary.simpleMessage("모델 선택:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage("제공업체 선택:"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("테마 선택"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("보내기"),
    "settings": MessageLookupByLibrary.simpleMessage("설정"),
    "shareImage": MessageLookupByLibrary.simpleMessage("이미지 공유"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage("이미지 출처: Hyve"),
    "showApiKey": MessageLookupByLibrary.simpleMessage("API 키 표시"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "사용 설정하면 프로젝트 대화에서 에이전트 메시지의 토큰 사용량과 도구, MCP 등의 호출 세부 정보를 확인할 수 있습니다.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage("봇 정보 표시"),
    "showSidebar": MessageLookupByLibrary.simpleMessage("사이드바 표시"),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage("에셋 사용 가능"),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage("호환성"),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "이 예시는 스킬을 활성화해야 함",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "사용자 요청 예시",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "활성화 결과",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage("스킬 세부 정보"),
    "skillDigest": MessageLookupByLibrary.simpleMessage("콘텐츠 다이제스트"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("꺼짐"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("켜짐"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("파일"),
    "skillImportFailed": m72,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage("스킬을 가져왔습니다"),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("스킬"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "재사용 가능한 지침을 설치하고 봇에 연결합니다.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "이 버전에서는 스킬의 스크립트나 명령을 실행하지 않습니다.",
    ),
    "skillPublisher": MessageLookupByLibrary.simpleMessage("게시자"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "참조 파일 사용 가능",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "SKILL.md는 제어된 프롬프트 지침으로만 불러옵니다. 스크립트, 명령 및 외부 도구는 계속 비활성화됩니다.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "데스크톱 스크립트 샌드박스 사용 가능",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "승인하기 전까지 스크립트는 스킬별로 비활성화됩니다. 각 호출에도 계속 승인이 필요합니다.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "스킬 스크립트 사용 불가",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "이 플랫폼은 필요한 격리 환경을 제공하지 않습니다. 지침과 리소스는 계속 사용할 수 있습니다.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "스킬 스크립트 설정이 업데이트되었습니다.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "스크립트가 설치되었지만 실행은 비활성화되어 있습니다.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage("스크립트 활성화됨"),
    "skillSignature": MessageLookupByLibrary.simpleMessage("서명"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage("잘못된 서명"),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "알 수 없는 게시자",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage("서명되지 않음"),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage("서명 확인됨"),
    "skillSource": MessageLookupByLibrary.simpleMessage("원본"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage("설치 위치"),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "설치 위치가 클립보드에 복사되었습니다.",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("자동"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage("업데이트 있음"),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("수동"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("알림"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("고정"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage("업데이트 정책"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("사용자"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "유효성 검사 참고",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("버전"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage("음성 생성됨"),
    "speechResult": MessageLookupByLibrary.simpleMessage("음성 결과"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "채팅을 시작하려면 아래 입력 필드에 메시지를 보내세요",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("채팅 시작하기"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "시작하지 못했습니다. 다시 시도해 주세요.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("시작하는 중…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("활성화됨"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("첨부됨"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage("승인 대기 중"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("취소됨"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("완료"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("거부됨"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage("중복 호출"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("생성됨"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("진행 중"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("기록됨"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("요청됨"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("실행 중"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("건너뜀"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("시간 초과"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "stop": MessageLookupByLibrary.simpleMessage("중지"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage("중지하고 계속하기"),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "떠나기 전에 세대를 중단하시겠습니까?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage("부분 답변은 그대로 유지됩니다."),
    "stopping": MessageLookupByLibrary.simpleMessage("중지하는 중…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "구조화된 프로세스 정보",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("피드백 제출"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage("요약된 메시지"),
    "supported": MessageLookupByLibrary.simpleMessage("지원됨"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("MCP 지원"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage("기술 지원"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("시스템 프롬프트"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("카메라"),
    "testSkill": MessageLookupByLibrary.simpleMessage("테스트"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage("설명 테스트"),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "테마가 다크 모드로 설정되었습니다",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "테마가 라이트 모드로 설정되었습니다",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "테마가 시스템 설정을 따르도록 설정되었습니다",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage("테마 설정"),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage("생각 완료"),
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("생각 중…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("토큰 사용"),
    "tokens": MessageLookupByLibrary.simpleMessage("토큰"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage("한 번 허용"),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("거부됨"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("도구 호출"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("파괴적"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("읽기 전용"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("쓰기"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("내장"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage("스킬 스크립트"),
    "totalTokens": MessageLookupByLibrary.simpleMessage("총 토큰"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "다른 검색을 시도하거나 새 항목을 만드세요.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("입력 중..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage("봇을 로드할 수 없습니다"),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "채팅을 로드할 수 없습니다.",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "메시지를 로드할 수 없습니다.",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("사용할 수 없는 봇"),
    "uninstall": MessageLookupByLibrary.simpleMessage("제거"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage("스킬 제거"),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("고정 해제"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("파일 업로드"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("이미지 업로드"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("사용자 동의"),
    "version": MessageLookupByLibrary.simpleMessage("버전 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("동영상 생성됨"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage("동영상을 불러올 수 없습니다"),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("동영상 결과"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("요약 보기"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "이 채팅을 떠나기 전에 생성이 완료될 때까지 기다리세요.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "생성이 완료될 때까지 기다립니다.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("웹 검색"),
  };
}
