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
      "Excluir o bot também removerá todas as conversas associadas. Tem certeza de que deseja excluir ${botName}?";

  static String m7(botName) =>
      "Excluir a conversa apagará todo o histórico de conversas. Tem certeza de que deseja excluir a conversa com ${botName}?";

  static String m8(name) =>
      "Excluir ${name}? Seu catálogo de ferramentas em cache e credencial segura também serão removidos.";

  static String m9(name) =>
      "Desinstalar ${name}? Os vínculos com bots também serão removidos.";

  static String m10(year) => "© ${year} Equipe Hyve";

  static String m11(error) => "Não foi possível criar o chat: ${error}";

  static String m12(error) => "Não foi possível criar o projeto: ${error}";

  static String m13(error) => "Não foi possível excluir o bate-papo: ${error}";

  static String m14(milliseconds) => "${milliseconds} ms";

  static String m15(seconds) => "${seconds}s";

  static String m16(name) =>
      "Permitir que ${name} registre os scripts declarados como ferramentas. Cada chamada ainda exigirá aprovação.";

  static String m17(count) => "${count} arquivos";

  static String m18(error) => "Falha ao gerar imagem: ${error}";

  static String m19(error) => "Não foi possível gerar música: ${error}";

  static String m20(error) => "Não foi possível gerar fala: ${error}";

  static String m21(error) => "Não foi possível gerar o vídeo: ${error}";

  static String m22(count) => "${count} itens";

  static String m23(language) => "Idioma alterado para ${language}";

  static String m24(error) => "Falha na conexão MCP: ${error}";

  static String m25(count) => "${count} configurado (valores ocultos)";

  static String m26(minutes) => "há ${minutes} minutos";

  static String m27(count) => "${count} modelos recuperados com sucesso";

  static String m28(count) => "${count} execuções de comando";

  static String m29(duration) => "Duração ${duration}";

  static String m30(count) => "${count} alterações de arquivo";

  static String m31(count) => "${count} chamadas de ferramenta";

  static String m32(id) => "Agente ${id}";

  static String m33(changeKind, artifactId) =>
      "${changeKind} · Artefato ${artifactId}";

  static String m34(code) => "Falha na operação do artefato (${code})";

  static String m35(ids) => "Versões do artefato: ${ids}";

  static String m36(index) => "Anexo ${index}";

  static String m37(count) => "${count} pendente";

  static String m38(path) =>
      "Excluir todas as versões de ${path}? Os artefatos referenciados por uma mensagem ou entrega não podem ser excluídos.";

  static String m39(depth) => "Profundidade de entrega: ${depth}";

  static String m40(id, status) => "Execução de entrega: ${id} · ${status}";

  static String m41(value) => "Duração: ${value}";

  static String m42(value) => "Erro: ${value}";

  static String m43(id) => "Evento: ${id}";

  static String m44(sequence) => "Evento #${sequence}";

  static String m45(count) =>
      "${Intl.plural(count, one: '${count} artefato', other: '${count} artefatos')}";

  static String m46(code) => "Falha na atualização do membro (${code})";

  static String m47(agentId, previous, current) =>
      "${agentId} alterado de ${previous} para ${current}";

  static String m48(agentId, current) => "${agentId} é agora ${current}";

  static String m49(id) => "ID da mensagem: ${id}";

  static String m50(code) => "Falha ao enviar mensagem (${code})";

  static String m51(sequence) => "Mensagem #${sequence}";

  static String m52(processed, latest) =>
      "Processado ${processed} / mais recente ${latest}";

  static String m53(count) =>
      "${Intl.plural(count, one: '${count} destinatário', other: '${count} destinatários')}";

  static String m54(count) =>
      "${Intl.plural(count, one: '${count} mensagem de referência', other: '${count} mensagens de referência')}";

  static String m55(name) => "Remover ${name}?";

  static String m56(name) => "Arraste para reordenar ${name}";

  static String m57(sequence) => "Respondendo à mensagem #${sequence}";

  static String m58(id) => "Execução raiz: ${id}";

  static String m59(count) =>
      "${Intl.plural(count, one: '${count} execução', other: '${count} execuções')}";

  static String m60(runId) => " · execução ${runId}";

  static String m61(value) => "Fonte: ${value}";

  static String m62(id) => "Execução de origem: ${id}";

  static String m63(value) => "Execuções alvo: ${value}";

  static String m64(input, output) => "Entrada ${input} · saída ${output}";

  static String m65(id, status) => "Turno: ${id} · ${status}";

  static String m66(mime, digest) =>
      "A visualização no aplicativo não é compatível com este tipo. \n MIME: ${mime} \n SHA-256: ${digest}";

  static String m67(version, actor, run) =>
      "Versão ${version} · agente ${actor}${run}";

  static String m68(error) => "Falha ao obter resposta: ${error}";

  static String m69(error) => "Não foi possível salvar a imagem: ${error}";

  static String m70(count) => "${count} selecionado";

  static String m71(error) =>
      "Não foi possível compartilhar a imagem: ${error}";

  static String m72(error) =>
      "Não foi possível importar a habilidade: ${error}";

  static String m73(duration) => "Pensamento concluído · ${duration}";

  static String m74(error) => "Erro na reprodução do vídeo: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Bots": MessageLookupByLibrary.simpleMessage("Robôs"),
    "about": MessageLookupByLibrary.simpleMessage("Sobre"),
    "aboutApp": MessageLookupByLibrary.simpleMessage("Sobre o Hyve"),
    "activeRequestCannotCancel": MessageLookupByLibrary.simpleMessage(
      "A solicitação ativa não pode ser cancelada. Espere terminar.",
    ),
    "activeRequestCannotStop": MessageLookupByLibrary.simpleMessage(
      "A solicitação ativa não pode ser interrompida",
    ),
    "addAttachment": MessageLookupByLibrary.simpleMessage("Anexo"),
    "addBot": MessageLookupByLibrary.simpleMessage("Adicionar bot"),
    "addMcpServer": MessageLookupByLibrary.simpleMessage(
      "Adicionar servidor MCP",
    ),
    "addSkill": MessageLookupByLibrary.simpleMessage("Adicionar habilidade"),
    "adjustAppFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamanho da fonte do aplicativo",
    ),
    "adjustFontSize": MessageLookupByLibrary.simpleMessage(
      "Ajustar tamanho da fonte",
    ),
    "agentContextMemoryUnavailable": MessageLookupByLibrary.simpleMessage(
      "Abra um projeto que use este agente para visualizar e gerenciar seu contexto e sua memória.",
    ),
    "agentMemory": MessageLookupByLibrary.simpleMessage("Memória do agente"),
    "agentMemoryAutoEvolution": MessageLookupByLibrary.simpleMessage(
      "Evolução automática da memória",
    ),
    "agentMemoryDescription": MessageLookupByLibrary.simpleMessage(
      "A memória de longo prazo pertence a este agente e pode ser reutilizada entre projetos.",
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
    "appName": MessageLookupByLibrary.simpleMessage("Hyve"),
    "appTitle": MessageLookupByLibrary.simpleMessage(
      "Hyve - Assistente de chat com IA",
    ),
    "applicationInjectedPrompt": MessageLookupByLibrary.simpleMessage(
      "Prompt do sistema",
    ),
    "applicationInjectedPromptDescription": MessageLookupByLibrary.simpleMessage(
      "Gerenciado pelo Hyve e adicionado a cada solicitação ao modelo. Os identificadores do agente e da conversa atuais são incluídos em tempo de execução e não podem ser editados.",
    ),
    "attachedFiles": MessageLookupByLibrary.simpleMessage("Arquivos anexados"),
    "attachedImages": MessageLookupByLibrary.simpleMessage("Imagens anexadas"),
    "attachments": MessageLookupByLibrary.simpleMessage("Anexos"),
    "autoActivation": MessageLookupByLibrary.simpleMessage("Automática"),
    "autoActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Permite que modelos compatíveis ativem esta habilidade pela descrição.",
    ),
    "autoActivationUnavailable": MessageLookupByLibrary.simpleMessage(
      "Este provedor aceita apenas habilidades manuais.",
    ),
    "automaticMemory": MessageLookupByLibrary.simpleMessage(
      "Memória automática",
    ),
    "automaticSummaryWarning": MessageLookupByLibrary.simpleMessage(
      "Resumos automáticos podem ser imprecisos. A mensagem atual sempre tem prioridade.",
    ),
    "backToDailyUsage": MessageLookupByLibrary.simpleMessage(
      "Voltar ao uso diário",
    ),
    "basicInformation": MessageLookupByLibrary.simpleMessage(
      "Informações Básicas",
    ),
    "botAddedSuccess": m0,
    "botAvatar": MessageLookupByLibrary.simpleMessage("Avatar do bot"),
    "botDeleted": m1,
    "botGreeting": m2,
    "botInformation": MessageLookupByLibrary.simpleMessage(
      "Informações do bot",
    ),
    "botIsTyping": m3,
    "botMcpToolsDescription": MessageLookupByLibrary.simpleMessage(
      "Ative ferramentas MCP para este agente. As chamadas exigem confirmação por padrão.",
    ),
    "botName": MessageLookupByLibrary.simpleMessage("Nome do bot"),
    "botSearchScope": MessageLookupByLibrary.simpleMessage(
      "A pesquisa filtra a lista pelo nome do bot.",
    ),
    "botSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "botSkillsDescription": MessageLookupByLibrary.simpleMessage(
      "Escolha as instruções reutilizáveis disponíveis para este bot.",
    ),
    "botUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "Este bot não está disponível",
    ),
    "botUpdated": m4,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Alterar avatar"),
    "changesSaved": MessageLookupByLibrary.simpleMessage("Salvo"),
    "chatDeleted": m5,
    "chatSearchScope": MessageLookupByLibrary.simpleMessage(
      "A pesquisa corresponde aos nomes dos bots e à mensagem mais recente.",
    ),
    "chats": MessageLookupByLibrary.simpleMessage("Conversas"),
    "chooseFromGallery": MessageLookupByLibrary.simpleMessage("Galeria"),
    "clearAttachments": MessageLookupByLibrary.simpleMessage("Limpar anexos"),
    "clearAutomaticMemory": MessageLookupByLibrary.simpleMessage(
      "Limpar memória automática",
    ),
    "clearChat": MessageLookupByLibrary.simpleMessage("Limpar conversa"),
    "clearPinnedSkills": MessageLookupByLibrary.simpleMessage(
      "Limpar habilidades fixadas",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Limpar pesquisa"),
    "clickDayForHourlyUsage": MessageLookupByLibrary.simpleMessage(
      "Selecione um dia para ver o uso por hora",
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
    "compactNow": MessageLookupByLibrary.simpleMessage("Compactar agora"),
    "compactingContext": MessageLookupByLibrary.simpleMessage(
      "Organizando o contexto…",
    ),
    "compactionFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "compactionStatus": MessageLookupByLibrary.simpleMessage(
      "Status da compactação",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirmar exclusão"),
    "confirmDeleteBot": m6,
    "confirmDeleteChat": m7,
    "confirmDeleteMcpServer": m8,
    "confirmUninstallSkill": m9,
    "contactInfoHint": MessageLookupByLibrary.simpleMessage(
      "Informações de contato (opcional)",
    ),
    "contextAndMemory": MessageLookupByLibrary.simpleMessage(
      "Contexto e memória",
    ),
    "contextCompacted": MessageLookupByLibrary.simpleMessage(
      "Contexto compactado",
    ),
    "contextWindow": MessageLookupByLibrary.simpleMessage("Janela de contexto"),
    "conversationSummary": MessageLookupByLibrary.simpleMessage(
      "Resumo da conversa",
    ),
    "conversationTokenShare": MessageLookupByLibrary.simpleMessage(
      "Proporção de tokens por conversa",
    ),
    "copyApiKey": MessageLookupByLibrary.simpleMessage("Copiar chave API"),
    "copySkillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Copiar local de instalação",
    ),
    "copyright": m10,
    "createChatFailed": m11,
    "createProject": MessageLookupByLibrary.simpleMessage("Criar Projeto"),
    "createProjectFailed": m12,
    "creatingChat": MessageLookupByLibrary.simpleMessage("Criando…"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Hora da Criação"),
    "customProvider": MessageLookupByLibrary.simpleMessage(
      "Provedor personalizado...",
    ),
    "dailyTokenUsage": MessageLookupByLibrary.simpleMessage("Uso diário"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Modo escuro"),
    "databaseDowngradeNotSupported": MessageLookupByLibrary.simpleMessage(
      "Este banco de dados foi criado por uma versão mais recente do Hyve. Atualize o aplicativo antes de abri-lo.",
    ),
    "databaseRecoveryFailed": MessageLookupByLibrary.simpleMessage(
      "A verificação de integridade do banco de dados falhou e não foi possível recuperá-lo pelo backup desta versão.",
    ),
    "deepThinking": MessageLookupByLibrary.simpleMessage("Raciocínio profundo"),
    "defaultSystemPrompt": MessageLookupByLibrary.simpleMessage(
      "Você é um assistente de IA útil. Por favor, responda em português.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Excluir"),
    "deleteBot": MessageLookupByLibrary.simpleMessage("Excluir bot"),
    "deleteChat": MessageLookupByLibrary.simpleMessage("Excluir conversa"),
    "deleteChatFailed": m13,
    "deleteMcpServer": MessageLookupByLibrary.simpleMessage(
      "Excluir servidor MCP",
    ),
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
    "details": MessageLookupByLibrary.simpleMessage("Detalhes"),
    "directPlayback": MessageLookupByLibrary.simpleMessage("Pronto para jogar"),
    "directPreview": MessageLookupByLibrary.simpleMessage(
      "Pronto para visualizar",
    ),
    "disableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Desativar sem confirmação para todas",
    ),
    "disableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Desativar todas as ferramentas",
    ),
    "disableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Desativar scripts",
    ),
    "durationMilliseconds": m14,
    "durationSeconds": m15,
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "editBot": MessageLookupByLibrary.simpleMessage("Editar bot"),
    "editMcpServer": MessageLookupByLibrary.simpleMessage(
      "Editar servidor MCP",
    ),
    "editMemory": MessageLookupByLibrary.simpleMessage("Editar memória"),
    "editName": MessageLookupByLibrary.simpleMessage("Editar nome"),
    "emptyResponseError": MessageLookupByLibrary.simpleMessage(
      "Falha ao obter resposta: o servidor retornou uma resposta vazia",
    ),
    "enableAllMcpToolNoApproval": MessageLookupByLibrary.simpleMessage(
      "Ativar sem confirmação para todas",
    ),
    "enableAllMcpTools": MessageLookupByLibrary.simpleMessage(
      "Ativar todas as ferramentas",
    ),
    "enableSkillScripts": MessageLookupByLibrary.simpleMessage(
      "Ativar scripts",
    ),
    "enableSkillScriptsDescription": m16,
    "enableSkillScriptsTitle": MessageLookupByLibrary.simpleMessage(
      "Ativar scripts isolados?",
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
    "estimatedContextUsage": MessageLookupByLibrary.simpleMessage(
      "Uso estimado",
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
    "feedbackInformation": MessageLookupByLibrary.simpleMessage(
      "Informações de feedback",
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
    "fileAttachment": MessageLookupByLibrary.simpleMessage("Anexo de arquivo"),
    "fileCount": m17,
    "fileResult": MessageLookupByLibrary.simpleMessage("Resultado do arquivo"),
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
    "forgetMemory": MessageLookupByLibrary.simpleMessage("Esquecer"),
    "generateImageFailed": m18,
    "generateMusicFailed": m19,
    "generateSpeechFailed": m20,
    "generateVideoFailed": m21,
    "generatedImage": MessageLookupByLibrary.simpleMessage("Imagem gerada"),
    "generating": MessageLookupByLibrary.simpleMessage("Gerando…"),
    "generatingImage": MessageLookupByLibrary.simpleMessage(
      "Gerando imagem, aguarde...",
    ),
    "generationFailed": MessageLookupByLibrary.simpleMessage(
      "Falha na geração",
    ),
    "generationFailedPartial": MessageLookupByLibrary.simpleMessage(
      "Falha na geração · Resposta parcial mantida",
    ),
    "helpAndFeedback": MessageLookupByLibrary.simpleMessage("Ajuda e Feedback"),
    "hideApiKey": MessageLookupByLibrary.simpleMessage("Ocultar chave API"),
    "hideInspector": MessageLookupByLibrary.simpleMessage(
      "Ocultar informações do bot",
    ),
    "hideSidebar": MessageLookupByLibrary.simpleMessage(
      "Ocultar barra lateral",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Início"),
    "hourlyTokenUsage": MessageLookupByLibrary.simpleMessage("Uso por hora"),
    "idle": MessageLookupByLibrary.simpleMessage("Ocioso"),
    "imageAttachment": MessageLookupByLibrary.simpleMessage("Anexo de imagem"),
    "imageResult": MessageLookupByLibrary.simpleMessage("Resultado de imagem"),
    "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
      "Imagem salva na galeria",
    ),
    "imageSize": MessageLookupByLibrary.simpleMessage("Tamanho da imagem"),
    "imageStyle": MessageLookupByLibrary.simpleMessage("Estilo de imagem"),
    "importSkillFolder": MessageLookupByLibrary.simpleMessage(
      "Importar pasta de habilidades",
    ),
    "importSkillZip": MessageLookupByLibrary.simpleMessage(
      "Importar ZIP de habilidades",
    ),
    "importingSkill": MessageLookupByLibrary.simpleMessage(
      "Importando habilidade…",
    ),
    "includesDuration": MessageLookupByLibrary.simpleMessage("Inclui duração"),
    "inputTokens": MessageLookupByLibrary.simpleMessage("Tokens de entrada"),
    "installSkillUpdate": MessageLookupByLibrary.simpleMessage(
      "Instalar atualização",
    ),
    "invalidSummary": MessageLookupByLibrary.simpleMessage(
      "O resumo gerado não passou na validação",
    ),
    "itemCount": m22,
    "jumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Ir para o mais recente",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Agora mesmo"),
    "languageChanged": m23,
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Configurações de idioma",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Modo claro"),
    "linkOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Não foi possível abrir este link.",
    ),
    "localMcpDisabledDescription": MessageLookupByLibrary.simpleMessage(
      "Os servidores MCP baseados em processos locais permanecem desativados enquanto se aguarda uma revisão de segurança da plataforma.",
    ),
    "manageMemory": MessageLookupByLibrary.simpleMessage("Gerenciar memória"),
    "manualActivation": MessageLookupByLibrary.simpleMessage("Por mensagem"),
    "manualActivationDescription": MessageLookupByLibrary.simpleMessage(
      "Selecione a habilidade no campo de mensagem quando precisar.",
    ),
    "mcpAccessToken": MessageLookupByLibrary.simpleMessage(
      "Token de acesso OAuth/Bearer",
    ),
    "mcpArguments": MessageLookupByLibrary.simpleMessage("Argumentos"),
    "mcpArgumentsDescription": MessageLookupByLibrary.simpleMessage(
      "Insira um argumento por linha.",
    ),
    "mcpAuthentication": MessageLookupByLibrary.simpleMessage("Autenticação"),
    "mcpAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "Autorização necessária",
    ),
    "mcpCommand": MessageLookupByLibrary.simpleMessage("Comando"),
    "mcpCommandDescription": MessageLookupByLibrary.simpleMessage(
      "Nome do executável ou caminho absoluto. O comando é executado diretamente sem shell.",
    ),
    "mcpCommunicationChannel": MessageLookupByLibrary.simpleMessage(
      "Canal de comunicação",
    ),
    "mcpConnected": MessageLookupByLibrary.simpleMessage("Conectado"),
    "mcpConnecting": MessageLookupByLibrary.simpleMessage("Conectando"),
    "mcpConnectionError": MessageLookupByLibrary.simpleMessage(
      "Erro de conexão",
    ),
    "mcpConnectionFailed": m24,
    "mcpConnectionSettings": MessageLookupByLibrary.simpleMessage("Conexão"),
    "mcpDisconnected": MessageLookupByLibrary.simpleMessage("Desconectado"),
    "mcpEndpoint": MessageLookupByLibrary.simpleMessage(
      "Endpoint HTTP streamável",
    ),
    "mcpEnvironment": MessageLookupByLibrary.simpleMessage(
      "Variáveis de ambiente",
    ),
    "mcpEnvironmentDescription": MessageLookupByLibrary.simpleMessage(
      "Insira uma KEY=VALUE por linha. Os valores são armazenados no armazenamento seguro de credenciais do sistema operacional; deixe em branco durante a edição para manter os valores existentes.",
    ),
    "mcpHiddenEnvironmentVariableCount": m25,
    "mcpHttpsRequired": MessageLookupByLibrary.simpleMessage(
      "Os terminais MCP remotos devem usar HTTPS.",
    ),
    "mcpInvalidStdioEnvironment": MessageLookupByLibrary.simpleMessage(
      "As variáveis ​​de ambiente devem usar uma entrada KEY=VALUE por linha.",
    ),
    "mcpLocalProcessSecurityDescription": MessageLookupByLibrary.simpleMessage(
      "servidores stdio executam comandos neste computador. Adicione apenas servidores e variáveis ​​de ambiente em que você confia.",
    ),
    "mcpLocalProcessSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Segurança de processo local",
    ),
    "mcpNoApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Sem confirmação",
    ),
    "mcpNoAuthentication": MessageLookupByLibrary.simpleMessage("Nenhum"),
    "mcpPrivateEndpointBlocked": MessageLookupByLibrary.simpleMessage(
      "Os terminais MCP privados, locais e de link local estão bloqueados.",
    ),
    "mcpProcessId": MessageLookupByLibrary.simpleMessage(
      "ID do processo (PID)",
    ),
    "mcpProcessNotRunning": MessageLookupByLibrary.simpleMessage(
      "Não está correndo",
    ),
    "mcpProcessRunning": MessageLookupByLibrary.simpleMessage("Correndo"),
    "mcpProcessStartedAt": MessageLookupByLibrary.simpleMessage("Começou em"),
    "mcpProcessStatus": MessageLookupByLibrary.simpleMessage(
      "Status do processo",
    ),
    "mcpProgressiveDiscoveryDescription": MessageLookupByLibrary.simpleMessage(
      "As lojas Hyve descobriram catálogos de ferramentas. Habilite ferramentas individuais ao editar um agente; somente esse agente pode expô-los ao modelo.",
    ),
    "mcpRequestTimedOut": MessageLookupByLibrary.simpleMessage(
      "A solicitação MCP expirou.",
    ),
    "mcpSecureEnvironmentVariables": MessageLookupByLibrary.simpleMessage(
      "Variáveis de ambiente seguras",
    ),
    "mcpServerDetails": MessageLookupByLibrary.simpleMessage(
      "Detalhes do servidor",
    ),
    "mcpServerName": MessageLookupByLibrary.simpleMessage("Nome do servidor"),
    "mcpServers": MessageLookupByLibrary.simpleMessage("Servidores MCP"),
    "mcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Conecte servidores MCP e descubra seus catálogos de ferramentas. Configure as ferramentas após criar um agente.",
    ),
    "mcpStdioPipeChannel": MessageLookupByLibrary.simpleMessage(
      "stdin / stdout / stderr (pipes do sistema operacional)",
    ),
    "mcpStdioProcessAndChannel": MessageLookupByLibrary.simpleMessage(
      "Processo local e comunicação",
    ),
    "mcpStdioStartFailed": MessageLookupByLibrary.simpleMessage(
      "O comando stdio MCP não pôde ser iniciado.",
    ),
    "mcpTokenLeaveBlank": MessageLookupByLibrary.simpleMessage(
      "Deixe em branco para manter a credencial segura existente.",
    ),
    "mcpTokenStoredSecurely": MessageLookupByLibrary.simpleMessage(
      "Armazenado no armazenamento seguro de credenciais do sistema operacional.",
    ),
    "mcpToolSchemaUnsupported": MessageLookupByLibrary.simpleMessage(
      "Esta ferramenta possui um esquema de entrada não suportado e não pode ser selecionada.",
    ),
    "mcpTools": MessageLookupByLibrary.simpleMessage("Ferramentas"),
    "mcpTransport": MessageLookupByLibrary.simpleMessage("Transporte"),
    "mcpTransportStdio": MessageLookupByLibrary.simpleMessage(
      "stdio (processo local)",
    ),
    "mcpTransportStreamableHttp": MessageLookupByLibrary.simpleMessage(
      "Streamable HTTP",
    ),
    "mcpUnsupportedProtocol": MessageLookupByLibrary.simpleMessage(
      "O servidor MCP usa uma versão de protocolo não suportada.",
    ),
    "memory": MessageLookupByLibrary.simpleMessage("Memória"),
    "memoryArtifact": MessageLookupByLibrary.simpleMessage("Artefato"),
    "memoryChangedRetry": MessageLookupByLibrary.simpleMessage(
      "A memória mudou; tente novamente",
    ),
    "memoryCorrection": MessageLookupByLibrary.simpleMessage("Correção"),
    "memoryDecision": MessageLookupByLibrary.simpleMessage("Decisão"),
    "memoryFact": MessageLookupByLibrary.simpleMessage("Fato"),
    "memoryPreference": MessageLookupByLibrary.simpleMessage("Preferência"),
    "memoryQuestion": MessageLookupByLibrary.simpleMessage(
      "Pergunta em aberto",
    ),
    "memoryTask": MessageLookupByLibrary.simpleMessage("Tarefa"),
    "mentionAgentToSend": MessageLookupByLibrary.simpleMessage(
      "Use @ para mencionar pelo menos um agente do projeto.",
    ),
    "messageCopied": MessageLookupByLibrary.simpleMessage(
      "Mensagem copiada para a área de transferência",
    ),
    "messageHint": MessageLookupByLibrary.simpleMessage(
      "Digite uma mensagem e mencione agentes com @...",
    ),
    "messageSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "minutesAgo": m26,
    "modalityAudio": MessageLookupByLibrary.simpleMessage("Áudio"),
    "modalityFile": MessageLookupByLibrary.simpleMessage("Arquivo"),
    "modalityImage": MessageLookupByLibrary.simpleMessage("Imagem"),
    "modalityMulti": MessageLookupByLibrary.simpleMessage("Multimodal"),
    "modalityMusic": MessageLookupByLibrary.simpleMessage("Música"),
    "modalityRealtime": MessageLookupByLibrary.simpleMessage("Em tempo real"),
    "modalitySpeech": MessageLookupByLibrary.simpleMessage("Discurso"),
    "modalityText": MessageLookupByLibrary.simpleMessage("Texto"),
    "modalityVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "model": MessageLookupByLibrary.simpleMessage("Modelo"),
    "modelConfiguration": MessageLookupByLibrary.simpleMessage(
      "Configuração do modelo",
    ),
    "modelContextWindow": MessageLookupByLibrary.simpleMessage(
      "Tamanho do contexto do modelo",
    ),
    "modelInputModalities": MessageLookupByLibrary.simpleMessage("Entrada"),
    "modelOutputModalities": MessageLookupByLibrary.simpleMessage("Saída"),
    "modelsRetrievedSuccess": m27,
    "modificationTime": MessageLookupByLibrary.simpleMessage(
      "Tempo de modificação",
    ),
    "musicGenerated": MessageLookupByLibrary.simpleMessage("Música gerada"),
    "musicResult": MessageLookupByLibrary.simpleMessage("Resultado musical"),
    "name": MessageLookupByLibrary.simpleMessage("Nome"),
    "nameUpdated": MessageLookupByLibrary.simpleMessage("Nome atualizado"),
    "newBotWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Novos bots permanecem na área de trabalho para edição.",
    ),
    "newChat": MessageLookupByLibrary.simpleMessage("Nova conversa"),
    "newChatWorkspaceHint": MessageLookupByLibrary.simpleMessage(
      "Um novo chat é aberto diretamente na área de trabalho.",
    ),
    "newProject": MessageLookupByLibrary.simpleMessage("Novo Projeto"),
    "newProjectDescription": MessageLookupByLibrary.simpleMessage(
      "Name the project and add one or more bots.",
    ),
    "noAgentMemory": MessageLookupByLibrary.simpleMessage(
      "Este agente ainda não tem memória de longo prazo.",
    ),
    "noBotMcpToolsAvailable": MessageLookupByLibrary.simpleMessage(
      "Não há ferramentas MCP conectadas disponíveis.",
    ),
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
    "noConversationSummary": MessageLookupByLibrary.simpleMessage(
      "Ainda não há um resumo da conversa disponível.",
    ),
    "noMatchingBots": MessageLookupByLibrary.simpleMessage(
      "Nenhum bot correspondente encontrado",
    ),
    "noMatchingChats": MessageLookupByLibrary.simpleMessage(
      "Nenhum bate-papo correspondente encontrado",
    ),
    "noMatchingMcpServers": MessageLookupByLibrary.simpleMessage(
      "Nenhum servidor MCP correspondente encontrado",
    ),
    "noMatchingMcpTools": MessageLookupByLibrary.simpleMessage(
      "Nenhuma ferramenta correspondente encontrada",
    ),
    "noMatchingSkills": MessageLookupByLibrary.simpleMessage(
      "Nenhuma habilidade correspondente encontrada",
    ),
    "noMcpServers": MessageLookupByLibrary.simpleMessage("Sem servidores MCP"),
    "noMcpServersDescription": MessageLookupByLibrary.simpleMessage(
      "Adicione um servidor Streamable HTTP ou desktop stdio para descobrir seu catálogo de ferramentas.",
    ),
    "noMcpToolsDiscovered": MessageLookupByLibrary.simpleMessage(
      "Nenhuma ferramenta descoberta. Verifique a conexão e atualize.",
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
    "noTokenUsageRecorded": MessageLookupByLibrary.simpleMessage(
      "Nenhum uso de token registrado",
    ),
    "notSupported": MessageLookupByLibrary.simpleMessage("Não suportado"),
    "nothingToCompact": MessageLookupByLibrary.simpleMessage(
      "Não há contexto antigo suficiente para compactar",
    ),
    "orphanedChatGuidance": MessageLookupByLibrary.simpleMessage(
      "Exclua este bate-papo órfão ou recrie o bot ausente.",
    ),
    "outputTokens": MessageLookupByLibrary.simpleMessage("Tokens de saída"),
    "partialResponse": MessageLookupByLibrary.simpleMessage("Resposta parcial"),
    "pauseAudio": MessageLookupByLibrary.simpleMessage("Pausar áudio"),
    "pauseGeneration": MessageLookupByLibrary.simpleMessage("Pausar geração"),
    "pinMemory": MessageLookupByLibrary.simpleMessage("Fixar"),
    "pinSelectedSkills": MessageLookupByLibrary.simpleMessage(
      "Fixar seleção nesta conversa",
    ),
    "pinnedSkill": MessageLookupByLibrary.simpleMessage("Fixada"),
    "playAudio": MessageLookupByLibrary.simpleMessage("Reproduzir áudio"),
    "pleaseEnterApiKey": MessageLookupByLibrary.simpleMessage(
      "Por favor, insira a chave API primeiro",
    ),
    "pleaseEnterImageDescription": MessageLookupByLibrary.simpleMessage(
      "Insira uma descrição para geração de imagem",
    ),
    "pleaseEnterMusicDescription": MessageLookupByLibrary.simpleMessage(
      "Insira uma descrição para geração de música",
    ),
    "pleaseEnterSpeechDescription": MessageLookupByLibrary.simpleMessage(
      "Insira uma descrição para geração de fala",
    ),
    "pleaseEnterVideoDescription": MessageLookupByLibrary.simpleMessage(
      "Insira uma descrição para geração de vídeo",
    ),
    "previewText": MessageLookupByLibrary.simpleMessage(
      "Visualização do texto",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidade",
    ),
    "processCommandCount": m28,
    "processDuration": m29,
    "processFileCount": m30,
    "processInformation": MessageLookupByLibrary.simpleMessage(
      "Informações do processo",
    ),
    "processToolCount": m31,
    "profile": MessageLookupByLibrary.simpleMessage("Perfil"),
    "projectActive": MessageLookupByLibrary.simpleMessage("Ativo"),
    "projectActivityCatchingUp": MessageLookupByLibrary.simpleMessage(
      "Recuperando o atraso",
    ),
    "projectActivityCaughtUp": MessageLookupByLibrary.simpleMessage(
      "Alcançado",
    ),
    "projectActivityDeciding": MessageLookupByLibrary.simpleMessage(
      "Decidindo",
    ),
    "projectActivityFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "projectActivityPaused": MessageLookupByLibrary.simpleMessage("Pausado"),
    "projectActivityReplying": MessageLookupByLibrary.simpleMessage(
      "Respondendo",
    ),
    "projectActivitySkipped": MessageLookupByLibrary.simpleMessage("Ignorado"),
    "projectActivityWillReply": MessageLookupByLibrary.simpleMessage(
      "Responderei",
    ),
    "projectAddAgent": MessageLookupByLibrary.simpleMessage("Adicionar agente"),
    "projectAddAgentDescription": MessageLookupByLibrary.simpleMessage(
      "Procure um agente disponível e adicione-o a este projeto.",
    ),
    "projectAddAttachment": MessageLookupByLibrary.simpleMessage(
      "Adicionar anexo",
    ),
    "projectAgent": MessageLookupByLibrary.simpleMessage("Agente"),
    "projectAgentMemories": MessageLookupByLibrary.simpleMessage(
      "Memória do agente",
    ),
    "projectAgentNamed": m32,
    "projectAllTypes": MessageLookupByLibrary.simpleMessage("Todos os tipos"),
    "projectArtifactChange": m33,
    "projectArtifactIsReferenced": MessageLookupByLibrary.simpleMessage(
      "Este artefato é referenciado e não pode ser excluído.",
    ),
    "projectArtifactKindArchive": MessageLookupByLibrary.simpleMessage(
      "Arquivo",
    ),
    "projectArtifactKindAttachment": MessageLookupByLibrary.simpleMessage(
      "Anexo",
    ),
    "projectArtifactKindAudio": MessageLookupByLibrary.simpleMessage("Áudio"),
    "projectArtifactKindCode": MessageLookupByLibrary.simpleMessage("Código"),
    "projectArtifactKindDataset": MessageLookupByLibrary.simpleMessage(
      "Conjunto de dados",
    ),
    "projectArtifactKindDocument": MessageLookupByLibrary.simpleMessage(
      "Documento",
    ),
    "projectArtifactKindGenerated": MessageLookupByLibrary.simpleMessage(
      "Gerado",
    ),
    "projectArtifactKindImage": MessageLookupByLibrary.simpleMessage("Imagem"),
    "projectArtifactKindOther": MessageLookupByLibrary.simpleMessage("Outro"),
    "projectArtifactKindVideo": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "projectArtifactOperationFailed": m34,
    "projectArtifactPathConflict": MessageLookupByLibrary.simpleMessage(
      "Esse caminho do projeto já existe.",
    ),
    "projectArtifactPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Use um caminho relativo ao projeto válido.",
    ),
    "projectArtifactRoot": MessageLookupByLibrary.simpleMessage(
      "Todos os artefatos",
    ),
    "projectArtifactSizeExceeded": MessageLookupByLibrary.simpleMessage(
      "O arquivo excede o limite de tamanho do artefato.",
    ),
    "projectArtifactSymlinkRejected": MessageLookupByLibrary.simpleMessage(
      "Links simbólicos não podem ser importados.",
    ),
    "projectArtifactVersionConflict": MessageLookupByLibrary.simpleMessage(
      "A versão atual foi alterada. Abra-o novamente antes de editar.",
    ),
    "projectArtifactVersionIds": MessageLookupByLibrary.simpleMessage(
      "Versões de artefato",
    ),
    "projectArtifactVersions": m35,
    "projectArtifacts": MessageLookupByLibrary.simpleMessage(
      "Artefatos do projeto",
    ),
    "projectArtifactsDescription": MessageLookupByLibrary.simpleMessage(
      "Navegue pelos arquivos do projeto, visualize o histórico de versões e abra arquivos com aplicativos do sistema.",
    ),
    "projectAttachment": m36,
    "projectAuditDetails": MessageLookupByLibrary.simpleMessage(
      "Detalhes da auditoria",
    ),
    "projectAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Eventos de auditoria",
    ),
    "projectBackToMessages": MessageLookupByLibrary.simpleMessage(
      "Voltar às mensagens",
    ),
    "projectBackToParentFolder": MessageLookupByLibrary.simpleMessage(
      "Voltar para a pasta pai",
    ),
    "projectBacklog": m37,
    "projectBroadcastHint": MessageLookupByLibrary.simpleMessage(
      "Digite uma mensagem. Sem @ será transmitido para todos os agentes ativos.",
    ),
    "projectCancelRootChain": MessageLookupByLibrary.simpleMessage(
      "Cancelar cadeia raiz",
    ),
    "projectCancelRootChainDescription": MessageLookupByLibrary.simpleMessage(
      "As execuções ativas nesta cadeia de mensagens raiz, incluindo entregas descendentes, serão interrompidas. Outras cadeias continuarão.",
    ),
    "projectCancelRootChainTitle": MessageLookupByLibrary.simpleMessage(
      "Cancelar esta cadeia de mensagens raiz?",
    ),
    "projectCancelRun": MessageLookupByLibrary.simpleMessage(
      "Cancelar execução",
    ),
    "projectCancelRunDescription": MessageLookupByLibrary.simpleMessage(
      "Somente esta execução será interrompida. As demais execuções ativas do turno continuarão.",
    ),
    "projectCancelRunTitle": MessageLookupByLibrary.simpleMessage(
      "Cancelar esta execução?",
    ),
    "projectCancelTurn": MessageLookupByLibrary.simpleMessage("Cancelar turno"),
    "projectCancelTurnDescription": MessageLookupByLibrary.simpleMessage(
      "Todas as execuções ativas neste turno serão interrompidas. Os resultados concluídos serão mantidos.",
    ),
    "projectCancelTurnTitle": MessageLookupByLibrary.simpleMessage(
      "Cancelar este turno?",
    ),
    "projectClose": MessageLookupByLibrary.simpleMessage("Fechar"),
    "projectContent": MessageLookupByLibrary.simpleMessage("Conteúdo"),
    "projectContextReport": MessageLookupByLibrary.simpleMessage(
      "Relatório de contexto",
    ),
    "projectCoveredThroughMessage": MessageLookupByLibrary.simpleMessage(
      "Coberto por mensagem",
    ),
    "projectCreate": MessageLookupByLibrary.simpleMessage("Criar"),
    "projectCreateText": MessageLookupByLibrary.simpleMessage("Novo texto"),
    "projectCreateVersion": MessageLookupByLibrary.simpleMessage(
      "Criar versão",
    ),
    "projectDecisionCancelled": MessageLookupByLibrary.simpleMessage(
      "Decisão cancelada",
    ),
    "projectDecisionFailed": MessageLookupByLibrary.simpleMessage(
      "Falha na solicitação de decisão",
    ),
    "projectDecisionInvalid": MessageLookupByLibrary.simpleMessage(
      "Resposta de decisão inválida",
    ),
    "projectDecisionTimeout": MessageLookupByLibrary.simpleMessage(
      "A decisão expirou",
    ),
    "projectDecisions": MessageLookupByLibrary.simpleMessage("Decisões"),
    "projectDeleteArtifactDescription": m38,
    "projectDeleteArtifactTitle": MessageLookupByLibrary.simpleMessage(
      "Excluir artefato?",
    ),
    "projectDeleteKeepsAgentData": MessageLookupByLibrary.simpleMessage(
      "Agentes, habilidades, configuração e memória de longo prazo não são excluídos.",
    ),
    "projectDeletedAgent": MessageLookupByLibrary.simpleMessage(
      "Agente excluído",
    ),
    "projectDeliveryDepth": m39,
    "projectDeliveryRun": m40,
    "projectDropFilesToImport": MessageLookupByLibrary.simpleMessage(
      "Solte os arquivos aqui para importar",
    ),
    "projectDuration": m41,
    "projectEmptyTimeline": MessageLookupByLibrary.simpleMessage(
      "Envie uma mensagem para começar a colaborar. Mensagens sem @ são transmitidas.",
    ),
    "projectEmptyTimelineTitle": MessageLookupByLibrary.simpleMessage(
      "Nenhuma mensagem ainda",
    ),
    "projectError": m42,
    "projectEventAgentDelivery": MessageLookupByLibrary.simpleMessage(
      "Entrega do agente",
    ),
    "projectEventAgentMessage": MessageLookupByLibrary.simpleMessage(
      "Mensagem do agente",
    ),
    "projectEventArtifactChanged": MessageLookupByLibrary.simpleMessage(
      "Artefato alterado",
    ),
    "projectEventId": m43,
    "projectEventMembershipChanged": MessageLookupByLibrary.simpleMessage(
      "Associação alterada",
    ),
    "projectEventParticipationDecision": MessageLookupByLibrary.simpleMessage(
      "Decisão de participação",
    ),
    "projectEventRunStatusChanged": MessageLookupByLibrary.simpleMessage(
      "Status de execução alterado",
    ),
    "projectEventSequence": m44,
    "projectEventSystemNotice": MessageLookupByLibrary.simpleMessage(
      "Aviso do sistema",
    ),
    "projectEventUserMessage": MessageLookupByLibrary.simpleMessage(
      "Mensagem do usuário",
    ),
    "projectExecutionDescription": MessageLookupByLibrary.simpleMessage(
      "Revise o histórico de execução, decisões de participação, uso de token e eventos de auditoria.",
    ),
    "projectExecutionDetails": MessageLookupByLibrary.simpleMessage(
      "Detalhes de execução",
    ),
    "projectExecutionRuns": MessageLookupByLibrary.simpleMessage(
      "Histórico de execução",
    ),
    "projectFolderArtifactCount": m45,
    "projectImportFiles": MessageLookupByLibrary.simpleMessage(
      "Importar arquivos",
    ),
    "projectJumpToLatest": MessageLookupByLibrary.simpleMessage(
      "Ir para o mais recente",
    ),
    "projectLoadEarlierEvents": MessageLookupByLibrary.simpleMessage(
      "Carregar eventos anteriores",
    ),
    "projectLoadingWorkspace": MessageLookupByLibrary.simpleMessage(
      "Carregando projeto",
    ),
    "projectMemberUpdateFailed": m46,
    "projectMembers": MessageLookupByLibrary.simpleMessage(
      "Membros do projeto",
    ),
    "projectMembersDescription": MessageLookupByLibrary.simpleMessage(
      "Monitore o processamento e gerencie a ordem dos agentes, o acesso aos artefatos e a participação.",
    ),
    "projectMembershipChanged": m47,
    "projectMembershipCurrent": m48,
    "projectMemoryRevision": MessageLookupByLibrary.simpleMessage(
      "Revisão de memória",
    ),
    "projectMentionedAgentInactive": MessageLookupByLibrary.simpleMessage(
      "Um agente mencionado não está mais ativo. Remova ou selecione-o novamente.",
    ),
    "projectMessageId": m49,
    "projectMessageSendFailed": m50,
    "projectMessageSequence": m51,
    "projectMoveOrRename": MessageLookupByLibrary.simpleMessage(
      "Mover ou renomear",
    ),
    "projectName": MessageLookupByLibrary.simpleMessage("Nome do projeto"),
    "projectNameHint": MessageLookupByLibrary.simpleMessage(
      "Insira um nome de projeto",
    ),
    "projectNameRequired": MessageLookupByLibrary.simpleMessage(
      "Insira um nome de projeto.",
    ),
    "projectNewTextArtifact": MessageLookupByLibrary.simpleMessage(
      "Novo artefato de texto",
    ),
    "projectNoAgentsNotice": MessageLookupByLibrary.simpleMessage(
      "Este projeto não possui agentes ativos. As mensagens são salvas, mas nenhuma resposta será gerada.",
    ),
    "projectNoAgentsTitle": MessageLookupByLibrary.simpleMessage(
      "Nenhum agente ativo",
    ),
    "projectNoArtifacts": MessageLookupByLibrary.simpleMessage(
      "Nenhum artefato de projeto correspondente",
    ),
    "projectNoAuditEvents": MessageLookupByLibrary.simpleMessage(
      "Nenhum evento de auditoria ainda",
    ),
    "projectNoAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Nenhum agente está disponível para adicionar",
    ),
    "projectNoExecutions": MessageLookupByLibrary.simpleMessage(
      "Ainda não há registros de execução",
    ),
    "projectNoMatchingAgents": MessageLookupByLibrary.simpleMessage(
      "Nenhum agente correspondente",
    ),
    "projectNoMembers": MessageLookupByLibrary.simpleMessage(
      "Nenhum membro do projeto ainda",
    ),
    "projectNoParticipant": MessageLookupByLibrary.simpleMessage(
      "Nenhum agente precisou adicionar nada a esta mensagem.",
    ),
    "projectOpenInSystemApp": MessageLookupByLibrary.simpleMessage(
      "Abrir com aplicativo do sistema",
    ),
    "projectParticipationPass": MessageLookupByLibrary.simpleMessage("Ignorar"),
    "projectParticipationReply": MessageLookupByLibrary.simpleMessage(
      "Responder",
    ),
    "projectPassed": MessageLookupByLibrary.simpleMessage("Ignorado"),
    "projectPause": MessageLookupByLibrary.simpleMessage("Pausa"),
    "projectPausedStatus": MessageLookupByLibrary.simpleMessage("Pausado"),
    "projectPreviewAndHistory": MessageLookupByLibrary.simpleMessage(
      "Visualização e histórico de versões",
    ),
    "projectPreviewTruncated": MessageLookupByLibrary.simpleMessage(
      "Apenas os primeiros 32 KiB são mostrados. Os agentes podem continuar lendo em partes.",
    ),
    "projectProcessed": m52,
    "projectRecipientCount": m53,
    "projectReferencingMessages": m54,
    "projectRelativePath": MessageLookupByLibrary.simpleMessage(
      "Caminho relativo ao projeto",
    ),
    "projectReleaseToImport": MessageLookupByLibrary.simpleMessage(
      "Solte para importar",
    ),
    "projectRemove": MessageLookupByLibrary.simpleMessage("Remover"),
    "projectRemoveActiveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "O agente tem uma execução ativa. Removê-lo cancela essa execução; outros agentes continuam.",
    ),
    "projectRemoveMemberDescription": MessageLookupByLibrary.simpleMessage(
      "O agente deixará de receber novas mensagens do projeto.",
    ),
    "projectRemoveMemberTitle": m55,
    "projectReorderMember": m56,
    "projectReplyingTo": m57,
    "projectRequestedPublicReply": MessageLookupByLibrary.simpleMessage(
      "Resposta pública solicitada",
    ),
    "projectResume": MessageLookupByLibrary.simpleMessage("Retomar"),
    "projectRootRun": m58,
    "projectRoutingBroadcast": MessageLookupByLibrary.simpleMessage(
      "Transmissão",
    ),
    "projectRoutingDelivery": MessageLookupByLibrary.simpleMessage("Entrega"),
    "projectRoutingTargeted": MessageLookupByLibrary.simpleMessage(
      "Direcionado",
    ),
    "projectRunCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "projectRunCompleted": MessageLookupByLibrary.simpleMessage("Concluído"),
    "projectRunCount": m59,
    "projectRunDeciding": MessageLookupByLibrary.simpleMessage("Decidindo"),
    "projectRunDelivering": MessageLookupByLibrary.simpleMessage("Entregando"),
    "projectRunFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "projectRunIdentifierLabel": MessageLookupByLibrary.simpleMessage(
      "ID da execução",
    ),
    "projectRunInterrupted": MessageLookupByLibrary.simpleMessage(
      "Interrompido",
    ),
    "projectRunLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Limite excedido",
    ),
    "projectRunPassed": MessageLookupByLibrary.simpleMessage("Ignorado"),
    "projectRunPhaseDecision": MessageLookupByLibrary.simpleMessage("Decisão"),
    "projectRunPhaseDelivery": MessageLookupByLibrary.simpleMessage("Entrega"),
    "projectRunPhaseReply": MessageLookupByLibrary.simpleMessage("Responder"),
    "projectRunPreparing": MessageLookupByLibrary.simpleMessage("Preparando"),
    "projectRunQueued": MessageLookupByLibrary.simpleMessage("Na fila"),
    "projectRunRunning": MessageLookupByLibrary.simpleMessage("Em execução"),
    "projectRunSuffix": m60,
    "projectRunTimedOut": MessageLookupByLibrary.simpleMessage(
      "Tempo limite esgotado",
    ),
    "projectRuns": MessageLookupByLibrary.simpleMessage("Execuções"),
    "projectSaveAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Salvar como artefato do projeto",
    ),
    "projectSavedAsArtifact": MessageLookupByLibrary.simpleMessage(
      "Será salvo como artefato do Projeto",
    ),
    "projectSearch": MessageLookupByLibrary.simpleMessage("Pesquisa"),
    "projectSearchAgents": MessageLookupByLibrary.simpleMessage(
      "Procurar agentes",
    ),
    "projectSearchArtifacts": MessageLookupByLibrary.simpleMessage(
      "Pesquise nome, caminho e conteúdo",
    ),
    "projectSearchAvailableAgents": MessageLookupByLibrary.simpleMessage(
      "Pesquise agentes disponíveis",
    ),
    "projectSending": MessageLookupByLibrary.simpleMessage("Enviando"),
    "projectSkills": MessageLookupByLibrary.simpleMessage("Habilidades"),
    "projectSource": m61,
    "projectSourceRun": m62,
    "projectStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Acesso ao artefato",
    ),
    "projectStorageAccessNone": MessageLookupByLibrary.simpleMessage("Nenhum"),
    "projectStorageAccessRead": MessageLookupByLibrary.simpleMessage("Leia"),
    "projectStorageAccessReadWrite": MessageLookupByLibrary.simpleMessage(
      "Ler e escrever",
    ),
    "projectSummarySegments": MessageLookupByLibrary.simpleMessage(
      "Segmentos de resumo",
    ),
    "projectSystem": MessageLookupByLibrary.simpleMessage("Sistema"),
    "projectSystemLowercase": MessageLookupByLibrary.simpleMessage("sistema"),
    "projectTargetRuns": m63,
    "projectTokenBreakdown": m64,
    "projectTools": MessageLookupByLibrary.simpleMessage("Ferramentas"),
    "projectTurnCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "projectTurnCompleted": MessageLookupByLibrary.simpleMessage("Concluído"),
    "projectTurnCreated": MessageLookupByLibrary.simpleMessage("Criado"),
    "projectTurnDeciding": MessageLookupByLibrary.simpleMessage("Decidindo"),
    "projectTurnDelivering": MessageLookupByLibrary.simpleMessage("Entregando"),
    "projectTurnDispatching": MessageLookupByLibrary.simpleMessage("Envio"),
    "projectTurnFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "projectTurnId": m65,
    "projectTurnPartial": MessageLookupByLibrary.simpleMessage("Parcial"),
    "projectTurnReplying": MessageLookupByLibrary.simpleMessage("Respondendo"),
    "projectUnableToOpenArtifact": MessageLookupByLibrary.simpleMessage(
      "Não foi possível abrir este arquivo com um aplicativo do sistema.",
    ),
    "projectUnableToReadVersion": MessageLookupByLibrary.simpleMessage(
      "Não foi possível ler esta versão",
    ),
    "projectUnknown": MessageLookupByLibrary.simpleMessage("desconhecido"),
    "projectUnsupportedPreview": m66,
    "projectUpdatingStorageAccess": MessageLookupByLibrary.simpleMessage(
      "Atualizando acesso ao artefato",
    ),
    "projectUser": MessageLookupByLibrary.simpleMessage("Usuário"),
    "projectVersionProvenance": m67,
    "projectWorkspace": MessageLookupByLibrary.simpleMessage(
      "Espaço de trabalho do projeto",
    ),
    "projectWriteNewVersion": MessageLookupByLibrary.simpleMessage(
      "Escreva uma nova versão",
    ),
    "provideFeedback": MessageLookupByLibrary.simpleMessage(
      "Forneça suas sugestões e feedback",
    ),
    "provider": MessageLookupByLibrary.simpleMessage("Provedor"),
    "providerInformation": MessageLookupByLibrary.simpleMessage(
      "Informações do Provedor",
    ),
    "reasoningCompleted": MessageLookupByLibrary.simpleMessage(
      "Raciocínio concluído",
    ),
    "reasoningInProgress": MessageLookupByLibrary.simpleMessage(
      "Raciocínio em andamento",
    ),
    "reasoningInterrupted": MessageLookupByLibrary.simpleMessage(
      "Raciocínio interrompido",
    ),
    "rebuildMemory": MessageLookupByLibrary.simpleMessage("Reconstruir"),
    "referenceAudio": MessageLookupByLibrary.simpleMessage(
      "Áudio de referência",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Atualizar"),
    "refreshMcpTools": MessageLookupByLibrary.simpleMessage(
      "Ferramentas de atualização",
    ),
    "refreshSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Atualizar catálogos",
    ),
    "refreshingSkillCatalogs": MessageLookupByLibrary.simpleMessage(
      "Atualizando catálogos…",
    ),
    "remoteMcpOnly": MessageLookupByLibrary.simpleMessage("Apenas MCP remoto"),
    "removeFileAttachment": MessageLookupByLibrary.simpleMessage(
      "Remover arquivo",
    ),
    "removeImageAttachment": MessageLookupByLibrary.simpleMessage(
      "Remover imagem",
    ),
    "removeMcpServer": MessageLookupByLibrary.simpleMessage(
      "Remover servidor MCP",
    ),
    "removeSkill": MessageLookupByLibrary.simpleMessage("Remover habilidade"),
    "replyCancelled": MessageLookupByLibrary.simpleMessage(
      "Resposta cancelada",
    ),
    "replyStoppedPartial": MessageLookupByLibrary.simpleMessage(
      "Interrompido · Resposta parcial mantida",
    ),
    "resetToDefault": MessageLookupByLibrary.simpleMessage("Restaurar padrão"),
    "responseError": m68,
    "restoreMemory": MessageLookupByLibrary.simpleMessage("Restaurar"),
    "retainedRecentTurns": MessageLookupByLibrary.simpleMessage(
      "Turnos recentes mantidos",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Tente novamente"),
    "runSkillDescriptionTest": MessageLookupByLibrary.simpleMessage(
      "Executar teste",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Salvar"),
    "saveAndConnect": MessageLookupByLibrary.simpleMessage("Salve e conecte"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Salvar alterações"),
    "saveImage": MessageLookupByLibrary.simpleMessage("Salvar imagem"),
    "saveImageFailed": m69,
    "saveToGalleryFailed": MessageLookupByLibrary.simpleMessage(
      "Não foi possível salvar na galeria",
    ),
    "savingChanges": MessageLookupByLibrary.simpleMessage("Salvando..."),
    "searchBots": MessageLookupByLibrary.simpleMessage("Pesquisar bots"),
    "searchChats": MessageLookupByLibrary.simpleMessage("Pesquisar conversas"),
    "searchMcpServers": MessageLookupByLibrary.simpleMessage(
      "Pesquise servidores MCP",
    ),
    "searchMcpTools": MessageLookupByLibrary.simpleMessage(
      "Ferramentas de pesquisa",
    ),
    "searchMemory": MessageLookupByLibrary.simpleMessage("Pesquisar memória"),
    "searchSkills": MessageLookupByLibrary.simpleMessage("Buscar habilidades"),
    "selectAtLeastOneBot": MessageLookupByLibrary.simpleMessage(
      "Selecione pelo menos um bot.",
    ),
    "selectBot": MessageLookupByLibrary.simpleMessage("Selecionar bot"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Selecionar idioma"),
    "selectModel": MessageLookupByLibrary.simpleMessage("Selecionar modelo:"),
    "selectProjectBots": MessageLookupByLibrary.simpleMessage("Add bots"),
    "selectProvider": MessageLookupByLibrary.simpleMessage(
      "Selecionar provedor:",
    ),
    "selectTheme": MessageLookupByLibrary.simpleMessage("Selecionar tema"),
    "selectedBotCount": m70,
    "send": MessageLookupByLibrary.simpleMessage("Enviar"),
    "settings": MessageLookupByLibrary.simpleMessage("Configurações"),
    "shareImage": MessageLookupByLibrary.simpleMessage("Compartilhar imagem"),
    "shareImageFailed": m71,
    "sharedImageFromHyve": MessageLookupByLibrary.simpleMessage(
      "Imagem de Hyve",
    ),
    "showApiKey": MessageLookupByLibrary.simpleMessage("Mostrar chave de API"),
    "showExecutionStatusDescription": MessageLookupByLibrary.simpleMessage(
      "Quando ativado, as conversas do projeto mostram o uso de tokens e os detalhes de chamadas de ferramentas, MCP e outros recursos nas mensagens dos agentes.",
    ),
    "showInspector": MessageLookupByLibrary.simpleMessage(
      "Mostrar informações do bot",
    ),
    "showSidebar": MessageLookupByLibrary.simpleMessage(
      "Mostrar barra lateral",
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
    "skillImportFailed": m72,
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
    "skillPublisher": MessageLookupByLibrary.simpleMessage("Publicador"),
    "skillReferencesAvailable": MessageLookupByLibrary.simpleMessage(
      "Arquivos de referência disponíveis",
    ),
    "skillSafetyDescription": MessageLookupByLibrary.simpleMessage(
      "O SKILL.md é carregado apenas como orientação controlada de prompt; scripts, comandos e ferramentas externas permanecem desativados.",
    ),
    "skillSandboxAvailable": MessageLookupByLibrary.simpleMessage(
      "Sandbox de scripts disponível",
    ),
    "skillSandboxAvailableDescription": MessageLookupByLibrary.simpleMessage(
      "Os scripts permanecem desativados até sua aprovação. Cada chamada ainda exige aprovação.",
    ),
    "skillSandboxUnavailable": MessageLookupByLibrary.simpleMessage(
      "Scripts de habilidades indisponíveis",
    ),
    "skillSandboxUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Esta plataforma não oferece o isolamento necessário. Instruções e recursos continuam disponíveis.",
    ),
    "skillScriptSettingUpdated": MessageLookupByLibrary.simpleMessage(
      "Configuração dos scripts atualizada.",
    ),
    "skillScriptsDisabled": MessageLookupByLibrary.simpleMessage(
      "Os scripts estão instalados, mas a execução está desativada.",
    ),
    "skillScriptsEnabled": MessageLookupByLibrary.simpleMessage(
      "Scripts ativados",
    ),
    "skillSignature": MessageLookupByLibrary.simpleMessage("Assinatura"),
    "skillSignatureInvalid": MessageLookupByLibrary.simpleMessage(
      "Assinatura inválida",
    ),
    "skillSignatureUnknownPublisher": MessageLookupByLibrary.simpleMessage(
      "Publicador desconhecido",
    ),
    "skillSignatureUnsigned": MessageLookupByLibrary.simpleMessage(
      "Sem assinatura",
    ),
    "skillSignatureVerified": MessageLookupByLibrary.simpleMessage(
      "Assinatura verificada",
    ),
    "skillSource": MessageLookupByLibrary.simpleMessage("Origem"),
    "skillStorageLocation": MessageLookupByLibrary.simpleMessage(
      "Local de instalação",
    ),
    "skillStorageLocationCopied": MessageLookupByLibrary.simpleMessage(
      "Local de instalação copiado para a área de transferência",
    ),
    "skillUpdateAutomatic": MessageLookupByLibrary.simpleMessage("Automática"),
    "skillUpdateAvailable": MessageLookupByLibrary.simpleMessage(
      "Atualização disponível",
    ),
    "skillUpdateManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "skillUpdateNotify": MessageLookupByLibrary.simpleMessage("Notificar"),
    "skillUpdatePinned": MessageLookupByLibrary.simpleMessage("Fixada"),
    "skillUpdatePolicy": MessageLookupByLibrary.simpleMessage(
      "Política de atualização",
    ),
    "skillUserScope": MessageLookupByLibrary.simpleMessage("Usuário"),
    "skillValidationWarnings": MessageLookupByLibrary.simpleMessage(
      "Notas de validação",
    ),
    "skillVersion": MessageLookupByLibrary.simpleMessage("Versão"),
    "speechGenerated": MessageLookupByLibrary.simpleMessage("Fala gerada"),
    "speechResult": MessageLookupByLibrary.simpleMessage("Resultado da fala"),
    "startChatPrompt": MessageLookupByLibrary.simpleMessage(
      "Envie uma mensagem no campo de texto abaixo para começar a conversar",
    ),
    "startChatting": MessageLookupByLibrary.simpleMessage("Comece a conversar"),
    "startupFailed": MessageLookupByLibrary.simpleMessage(
      "Falha ao iniciar. Tente novamente.",
    ),
    "startupStarting": MessageLookupByLibrary.simpleMessage("Iniciando…"),
    "statusActivated": MessageLookupByLibrary.simpleMessage("Ativado"),
    "statusAttached": MessageLookupByLibrary.simpleMessage("Anexado"),
    "statusAwaitingApproval": MessageLookupByLibrary.simpleMessage(
      "Aguardando aprovação",
    ),
    "statusCancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Concluído"),
    "statusDenied": MessageLookupByLibrary.simpleMessage("Negado"),
    "statusDuplicate": MessageLookupByLibrary.simpleMessage(
      "Chamada duplicada",
    ),
    "statusFailed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "statusGenerated": MessageLookupByLibrary.simpleMessage("Gerado"),
    "statusInProgress": MessageLookupByLibrary.simpleMessage("Em andamento"),
    "statusRecorded": MessageLookupByLibrary.simpleMessage("Registrado"),
    "statusRequested": MessageLookupByLibrary.simpleMessage("Solicitado"),
    "statusRunning": MessageLookupByLibrary.simpleMessage("Em execução"),
    "statusSkipped": MessageLookupByLibrary.simpleMessage("Ignorado"),
    "statusTimedOut": MessageLookupByLibrary.simpleMessage("Tempo esgotado"),
    "statusUnknown": MessageLookupByLibrary.simpleMessage("Desconhecido"),
    "stop": MessageLookupByLibrary.simpleMessage("Pare"),
    "stopAndContinue": MessageLookupByLibrary.simpleMessage("Pare e continue"),
    "stopGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Parar a geração antes de partir?",
    ),
    "stopGenerationBeforeLeavingDescription":
        MessageLookupByLibrary.simpleMessage(
          "A resposta parcial será mantida.",
        ),
    "stopping": MessageLookupByLibrary.simpleMessage("Parando…"),
    "structuredProcessInfo": MessageLookupByLibrary.simpleMessage(
      "Informações estruturadas do processo",
    ),
    "submitFeedback": MessageLookupByLibrary.simpleMessage("Enviar Feedback"),
    "summarizedTurns": MessageLookupByLibrary.simpleMessage(
      "Mensagens resumidas",
    ),
    "supported": MessageLookupByLibrary.simpleMessage("Suportado"),
    "supportsMcp": MessageLookupByLibrary.simpleMessage("Suporta MCP"),
    "supportsSkills": MessageLookupByLibrary.simpleMessage(
      "Habilidades de suporte",
    ),
    "systemPrompt": MessageLookupByLibrary.simpleMessage("Prompt do sistema"),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Câmera"),
    "testSkill": MessageLookupByLibrary.simpleMessage("Testar"),
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
    "thinkingCompletedWithDuration": m73,
    "thinkingInProgress": MessageLookupByLibrary.simpleMessage("Pensando…"),
    "tokenUsage": MessageLookupByLibrary.simpleMessage("Uso de tokens"),
    "tokens": MessageLookupByLibrary.simpleMessage("tokens"),
    "toolApprovalAllowOnce": MessageLookupByLibrary.simpleMessage(
      "Permitido uma vez",
    ),
    "toolApprovalDenied": MessageLookupByLibrary.simpleMessage("Negado"),
    "toolCalls": MessageLookupByLibrary.simpleMessage("Chamadas de ferramenta"),
    "toolRiskDestructive": MessageLookupByLibrary.simpleMessage("Destrutivo"),
    "toolRiskReadOnly": MessageLookupByLibrary.simpleMessage("Somente leitura"),
    "toolRiskWrite": MessageLookupByLibrary.simpleMessage("Gravação"),
    "toolSourceBuiltIn": MessageLookupByLibrary.simpleMessage("Integrado"),
    "toolSourceMcp": MessageLookupByLibrary.simpleMessage("MCP"),
    "toolSourceSkillScript": MessageLookupByLibrary.simpleMessage(
      "Script de Skill",
    ),
    "totalTokens": MessageLookupByLibrary.simpleMessage("Total de tokens"),
    "tryDifferentSearch": MessageLookupByLibrary.simpleMessage(
      "Tente uma pesquisa diferente ou crie um novo item.",
    ),
    "typing": MessageLookupByLibrary.simpleMessage("Digitando..."),
    "unableToLoadBots": MessageLookupByLibrary.simpleMessage(
      "Não foi possível carregar os bots",
    ),
    "unableToLoadChats": MessageLookupByLibrary.simpleMessage(
      "Não foi possível carregar os bate-papos",
    ),
    "unableToLoadMessages": MessageLookupByLibrary.simpleMessage(
      "Não foi possível carregar mensagens",
    ),
    "unavailableBot": MessageLookupByLibrary.simpleMessage("Bot indisponível"),
    "uninstall": MessageLookupByLibrary.simpleMessage("Desinstalar"),
    "uninstallSkill": MessageLookupByLibrary.simpleMessage(
      "Desinstalar habilidade",
    ),
    "unpinMemory": MessageLookupByLibrary.simpleMessage("Desafixar"),
    "uploadFile": MessageLookupByLibrary.simpleMessage("Enviar arquivo"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Enviar imagem"),
    "userAgreement": MessageLookupByLibrary.simpleMessage("Acordo do usuário"),
    "version": MessageLookupByLibrary.simpleMessage("Versão 1.0.0"),
    "videoGenerated": MessageLookupByLibrary.simpleMessage("Vídeo gerado"),
    "videoLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Não foi possível carregar o vídeo",
    ),
    "videoPlaybackError": m74,
    "videoResult": MessageLookupByLibrary.simpleMessage("Resultado do vídeo"),
    "viewSummary": MessageLookupByLibrary.simpleMessage("Ver resumo"),
    "waitForGenerationBeforeLeaving": MessageLookupByLibrary.simpleMessage(
      "Aguarde a geração terminar antes de sair deste chat.",
    ),
    "waitForGenerationToFinish": MessageLookupByLibrary.simpleMessage(
      "Aguarde a geração terminar.",
    ),
    "webSearch": MessageLookupByLibrary.simpleMessage("Pesquisa na Web"),
  };
}
