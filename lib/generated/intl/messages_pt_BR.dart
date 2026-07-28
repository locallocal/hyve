// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt_BR locale. All the
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
  String get localeName => 'pt_BR';

  static String m0(name) => "Bot \"${name}\" foi adicionado";

  static String m1(botName) => "\"${botName}\" foi excluído";

  static String m2(botName) =>
      "Olá! Eu sou ${botName}, um assistente de IA. Você pode me fazer qualquer pergunta e farei o meu melhor para ajudar.";

  static String m3(botName) => "${botName} está digitando...";

  static String m4(botName) => "Bot ${botName} foi atualizado";

  static String m5(botName) => "Conversa com ${botName} excluída";

  static String m6(botName) =>
      "Tem certeza de que deseja limpar todo o histórico de conversa com \"${botName}\"? Esta ação não pode ser desfeita.";

  static String m7(botName) =>
      "Excluir o bot também removerá todas as conversas associadas. Tem certeza de que deseja excluir ${botName}?";

  static String m8(botName) =>
      "Excluir a conversa apagará todo o histórico de conversas. Tem certeza de que deseja excluir a conversa com ${botName}?";

  static String m9(name) =>
      "Desinstalar ${name}? Os vínculos com bots também serão removidos.";

  static String m10(language) => "Idioma alterado para ${language}";

  static String m11(minutes) => "há ${minutes} minutos";

  static String m12(count) => "${count} modelos recuperados com sucesso";

  static String m13(count) => "${count} execuções de comando";

  static String m14(duration) => "Duração ${duration}";

  static String m15(count) => "${count} alterações de arquivo";

  static String m16(count) => "${count} chamadas de ferramenta";

  static String m17(error) => "Falha ao obter resposta: ${error}";

  static String m18(error) =>
      "Não foi possível importar a habilidade: ${error}";

  static String m19(duration) => "Pensamento concluído · ${duration}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Bots"),
    "about": MessageLookupByLibrary.simpleMessage("Sobre"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Sobre o Stars"),
    "addBot": MessageLookupByLibrary.simpleMessage("Adicionar bot"),
    "addSkill": MessageLookupByLibrary.simpleMessage("Adicionar habilidade"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamanho da fonte do aplicativo",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamanho da fonte",
    ),
    "allSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Todas as habilidades instaladas foram adicionadas.",
    ),
    "alwaysActivation": MessageLookupByLibrary.simpleMessage("Sempre ativa"),
    "alwaysActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Insere esta habilidade em cada solicitação de texto.",
    ),
    "alwaysOn": MessageLookupByLibrary.simpleMessage("Sempre ativa"),
    "apiAddress": MessageLookupByLibrary.simpleMessage("Endereço da API:"),
    "apiKey": MessageLookupByLibrary.simpleMessage("Chave API"),
    "apiType": MessageLookupByLibrary.simpleMessage("Tipo de API:"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
      "Um aplicativo de chat com IA simples, mas poderoso, que permite conversar com inteligência artificial a qualquer hora e em qualquer lugar.",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Stars"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Stars - Assistente de chat com IA",
    ),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automática"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permite que modelos compatíveis ativem esta habilidade pela descrição.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Este provedor aceita apenas habilidades manuais.",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar do bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botIsTyping": m3,
    "botName": MessageLookupByLibrary.simpleMessage("Nome do bot"),
    "botSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Escolha as instruções reutilizáveis disponíveis para este bot.",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Alterar avatar"),
    "chatDeleted": m5,
    "chatExecutionStatus": MessageLookupByLibrary.simpleMessage(
      "Status de execução do chat",
    ),
    "chatHistoryCleared": MessageLookupByLibrary.simpleMessage(
      "Histórico de conversa limpo",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Conversas"),
    "clear": MessageLookupByLibrary.simpleMessage("Limpar"),
    "clearChat": MessageLookupByLibrary.simpleMessage("Limpar conversa"),
    "clearChatHistory": MessageLookupByLibrary.simpleMessage(
      "Limpar histórico de conversa",
    ),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Limpar habilidades fixadas",
    ),
    "clickToCreateBot": MessageLookupByLibrary.simpleMessage(
      "Clique em + no canto superior direito para adicionar um bot",
    ),
    "clickToStartChat": MessageLookupByLibrary.simpleMessage(
      "Clique em Nova conversa para criar uma conversa",
    ),
    "commandExecutions": MessageLookupByLibrary.simpleMessage(
      "Execuções de comando",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmClearChat": m6,
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirmar exclusão"),
    "confirmDeleteBot": m7,
    "confirmDeleteChat": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Informações de contato (opcional)",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage("© 2025 Equipe Stars"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Provedor personalizado...",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo escuro"),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Raciocínio profundo"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Você é um assistente de IA útil. Por favor, responda em português.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Excluir"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Excluir bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Excluir conversa"),
    "desktopAboutAndLegal": MessageLookupByLibrary.simpleMessage(
      "Sobre e informações legais",
    ),
    "desktopAppearanceAndLanguage": MessageLookupByLibrary.simpleMessage(
      "Aparência e idioma",
    ),
    "desktopEditProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Altere seu avatar e nome de exibição.",
    ),
    "desktopGeneral": MessageLookupByLibrary.simpleMessage("Geral"),
    "desktopHelpAndSupport": MessageLookupByLibrary.simpleMessage(
      "Ajuda e suporte",
    ),
    "desktopPersonalInformation": MessageLookupByLibrary.simpleMessage(
      "Informações pessoais",
    ),
    "desktopSavedImmediatelyDescription": MessageLookupByLibrary.simpleMessage(
      "As alterações entram em vigor imediatamente e são salvas localmente.",
    ),
    "desktopSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Gerencie seu perfil, aparência, idioma e suporte do aplicativo.",
    ),
    "editBot": MessageLookupByLibrary.simpleMessage("Editar bot"),
    "editName": MessageLookupByLibrary.simpleMessage("Editar nome"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Falha ao obter resposta: o servidor retornou uma resposta vazia",
    ),
    "enterApiAddress": MessageLookupByLibrary.simpleMessage(
      "Digite o endereço da API...",
    ),
    "enterApiKey": MessageLookupByLibrary.simpleMessage(
      "Digite a chave API...",
    ),
    "enterBotName": MessageLookupByLibrary.simpleMessage(
      "Digite o nome do bot...",
    ),
    "enterDisplayName": MessageLookupByLibrary.simpleMessage(
      "Digite um nome de exibição",
    ),
    "enterNewName": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite um novo nome",
    ),
    "enterProviderName": MessageLookupByLibrary.simpleMessage(
      "Digite o nome do provedor...",
    ),
    "enterSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Digite o prompt do sistema...",
    ),
    "errorLoadingContent": MessageLookupByLibrary.simpleMessage(
      "Erro ao carregar conteúdo, por favor tente novamente mais tarde.",
    ),
    "executionStatus": MessageLookupByLibrary.simpleMessage(
      "Status da execução",
    ),
    "feedbackContentRequired": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o conteúdo do feedback",
    ),
    "feedbackDescription": MessageLookupByLibrary.simpleMessage(
      "Por favor, conte-nos seus pensamentos, problemas ou sugestões para nos ajudar a melhorar o aplicativo",
    ),
    "feedbackHint": MessageLookupByLibrary.simpleMessage(
      "Digite seu feedback aqui...",
    ),
    "feedbackSubmitError": MessageLookupByLibrary.simpleMessage(
      "Falha no envio, por favor tente novamente mais tarde",
    ),
    "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
      "Obrigado pelo seu feedback!",
    ),
    "fetchModelList": MessageLookupByLibrary.simpleMessage(
      "Obter lista de modelos",
    ),
    "fetchModelListFirst": MessageLookupByLibrary.simpleMessage(
      "Por favor, obtenha a lista de modelos primeiro",
    ),
    "fileStatus": MessageLookupByLibrary.simpleMessage("Status dos arquivos"),
    "fileTypeMusic": MessageLookupByLibrary.simpleMessage("Música"),
    "fileTypeSpeech": MessageLookupByLibrary.simpleMessage("Fala"),
    "fileTypeVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "fillRequiredFields": MessageLookupByLibrary.simpleMessage(
      "Por favor, preencha o nome do bot, endereço da API e chave API",
    ),
    "followSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "fontSizeSettings": MessageLookupByLibrary.simpleMessage(
      "Tamanho da fonte",
    ),
    "fontSizeUpdated": MessageLookupByLibrary.simpleMessage(
      "Tamanho da fonte atualizado",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Falha na geração",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Falha na geração · Resposta parcial mantida",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Ajuda e Feedback"),
    "home": MessageLookupByLibrary.simpleMessage("Início"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importar pasta de habilidades",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importar ZIP de habilidades",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importando habilidade…",
    ),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Tokens de entrada"),
    "justNow": MessageLookupByLibrary.simpleMessage("Agora mesmo"),
    "languageChanged": m10,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Configurações de idioma",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Por mensagem"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Selecione a habilidade no campo de mensagem quando precisar.",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Digite uma mensagem...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "minutesAgo": m11,
    "model": MessageLookupByLibrary.simpleMessage("Modelo"),
    "modelsRetrievedSuccess": m12,
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nome atualizado"),
    "newChat": MessageLookupByLibrary.simpleMessage("Nova conversa"),
    "noBotSkillsAdded": MessageLookupByLibrary.simpleMessage(
      "Nenhuma habilidade adicionada",
    ),
    "noBotSkillsAddedDescription": MessageLookupByLibrary.simpleMessage(
      "Adicione as habilidades instaladas necessárias para este bot.",
    ),
    "noBotsAvailable": MessageLookupByLibrary.simpleMessage(
      "Nenhum bot disponível",
    ),
    "noChats": MessageLookupByLibrary.simpleMessage("Ainda não há conversas"),
    "noContentReturned": MessageLookupByLibrary.simpleMessage(
      "Nenhum conteúdo retornado",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Nenhuma habilidade correspondente encontrada",
    ),
    "noModelsRetrieved": MessageLookupByLibrary.simpleMessage(
      "Nenhum modelo recuperado",
    ),
    "noSkillsInstalled": MessageLookupByLibrary.simpleMessage(
      "Nenhuma habilidade instalada",
    ),
    "noSkillsInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "Importe uma pasta do Agent Skills ou um ZIP contendo SKILL.md.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Tokens de saída"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Resposta parcial"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("Pausar geração"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fixar seleção nesta conversa",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fixada"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Por favor, insira a chave API primeiro",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Visualização do texto",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidade",
    ),
    "processCommandCount": m13,
    "processDuration": m14,
    "processFileCount": m15,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informações do processo",
    ),
    "processToolCount": m16,
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Forneça suas sugestões e feedback",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Provedor"),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Raciocínio concluído",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Raciocínio em andamento",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Raciocínio interrompido",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Remover habilidade"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "Resposta cancelada",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Interrompido · Resposta parcial mantida",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("Restaurar padrão"),
    "responseError": m17,
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Executar teste",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Salvar"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Salvar alterações"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Buscar habilidades"),
    "selectBot": MessageLookupByLibrary.simpleMessage("Selecionar bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Selecionar idioma"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Selecionar modelo:"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Selecionar provedor:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Selecionar tema"),
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "settings": MessageLookupByLibrary.simpleMessage("Configurações"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Mostrar detalhes da execução nas mensagens da conversa.",
    ),
    "skillAssetsAvailable": MessageLookupByLibrary.simpleMessage(
      "Recursos disponíveis",
    ),
    "skillCompatibility": MessageLookupByLibrary.simpleMessage(
      "Compatibilidade",
    ),
    "skillDescriptionShouldActivate": MessageLookupByLibrary.simpleMessage(
      "Este exemplo deve ativar a habilidade",
    ),
    "skillDescriptionTestInput": MessageLookupByLibrary.simpleMessage(
      "Exemplo de solicitação do usuário",
    ),
    "skillDescriptionTestResult": MessageLookupByLibrary.simpleMessage(
      "Resultado da ativação",
    ),
    "skillDetails": MessageLookupByLibrary.simpleMessage(
      "Detalhes da habilidade",
    ),
    "skillDigest": MessageLookupByLibrary.simpleMessage("Hash do conteúdo"),
    "skillDisabled": MessageLookupByLibrary.simpleMessage("Desativada"),
    "skillEnabled": MessageLookupByLibrary.simpleMessage("Ativada"),
    "skillFiles": MessageLookupByLibrary.simpleMessage("Arquivos"),
    "skillImportFailed": m18,
    "skillImportSucceeded": MessageLookupByLibrary.simpleMessage(
      "Habilidade importada",
    ),
    "skillLibrary": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "skillLibraryDescription": MessageLookupByLibrary.simpleMessage(
      "Instale instruções reutilizáveis e vincule-as aos bots.",
    ),
    "skillNotExecutable": MessageLookupByLibrary.simpleMessage(
      "Esta versão não executa scripts ou comandos das habilidades.",
    ),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Arquivos de referência disponíveis",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "O SKILL.md é carregado apenas como orientação controlada de prompt; scripts, comandos e ferramentas externas permanecem desativados.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Os scripts estão instalados, mas a execução está desativada.",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Origem"),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Usuário"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Notas de validação",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Versão"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envie uma mensagem no campo de texto abaixo para começar a conversar",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Comece a conversar"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Anexado"),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Concluído"),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Gerado"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("Em andamento"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Registrado"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Em execução"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informações estruturadas do processo",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Enviar Feedback"),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt do sistema"),
    "testSkillDescription": MessageLookupByLibrary.simpleMessage(
      "Testar descrição",
    ),
    "themeSetToDark": MessageLookupByLibrary.simpleMessage(
      "Tema configurado para modo escuro",
    ),
    "themeSetToLight": MessageLookupByLibrary.simpleMessage(
      "Tema configurado para modo claro",
    ),
    "themeSetToSystem": MessageLookupByLibrary.simpleMessage(
      "Tema configurado para seguir o sistema",
    ),
    "themeSettings": MessageLookupByLibrary.simpleMessage(
      "Configurações de tema",
    ),
    "thinkingCompleted": MessageLookupByLibrary.simpleMessage(
      "Pensamento concluído",
    ),
    "thinkingCompletedWithDuration": m19,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Pensando…"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Chamadas de ferramenta"),
    "typing": MessageLookupByLibrary.simpleMessage("Digitando..."),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Desinstalar habilidade",
    ),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Enviar arquivo"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Enviar imagem"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Acordo do usuário"),
    "version": MessageLookupByLibrary.simpleMessage("Versão 1.0.0"),
  };
}
