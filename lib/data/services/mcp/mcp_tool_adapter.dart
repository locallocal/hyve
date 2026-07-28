import 'dart:convert';

import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_client.dart';

final class McpToolAdapter implements ExecutableTool {
  McpToolAdapter({
    required McpServer server,
    required McpToolDescriptor descriptor,
    required McpClient client,
    Future<bool> Function()? availabilityCheck,
    JsonSchemaValidator schemaValidator = const JsonSchemaValidator(),
  }) : _server = server,
       _descriptor = descriptor,
       _client = client,
       _availabilityCheck = availabilityCheck,
       _schemaValidator = schemaValidator,
       definition = ToolDefinition(
         name: descriptor.canonicalName,
         title: descriptor.title,
         description:
             descriptor.description.isEmpty
                 ? 'Remote MCP Tool ${descriptor.remoteName}'
                 : descriptor.description,
         inputSchema: descriptor.inputSchema,
         outputSchema: descriptor.outputSchema,
         source: ToolSource.mcp,
         riskLevel:
             descriptor.annotations.destructiveHint
                 ? ToolRiskLevel.destructive
                 : descriptor.annotations.readOnlyHint
                 ? ToolRiskLevel.readOnly
                 : ToolRiskLevel.write,
         capabilities: {
           ToolCapability.network,
           if (descriptor.annotations.readOnlyHint)
             ToolCapability.externalRead
           else
             ToolCapability.externalWrite,
         },
       );

  final McpServer _server;
  final McpToolDescriptor _descriptor;
  final McpClient _client;
  final Future<bool> Function()? _availabilityCheck;
  final JsonSchemaValidator _schemaValidator;

  @override
  final ToolDefinition definition;

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    try {
      cancellationToken.throwIfCancelled();
      final currentlyAvailable = await _availabilityCheck?.call();
      cancellationToken.throwIfCancelled();
      if (!_server.enabled ||
          !_descriptor.enabled ||
          currentlyAvailable == false) {
        return ToolResult(
          callId: call.callId,
          name: call.name,
          content: 'The MCP Tool is disabled.',
          isError: true,
          errorCode: 'mcp_tool_disabled',
        );
      }
      final result = await _client.callTool(
        server: _server,
        remoteName: _descriptor.remoteName,
        arguments: call.arguments,
        cancellationToken: cancellationToken,
      );
      final outputSchema = _descriptor.outputSchema;
      if (outputSchema != null && result.structuredContent != null) {
        final issues = _schemaValidator.validate(
          result.structuredContent,
          outputSchema,
        );
        if (issues.isNotEmpty) {
          return ToolResult(
            callId: call.callId,
            name: call.name,
            content: 'The MCP Tool returned invalid structured output.',
            isError: true,
            errorCode: 'mcp_output_schema_validation_failed',
          );
        }
      }
      final content =
          result.content.isNotEmpty
              ? result.content
              : result.structuredContent == null
              ? ''
              : jsonEncode(result.structuredContent);
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: content,
        structuredContent: result.structuredContent,
        isError: result.isError,
        errorCode: result.isError ? 'mcp_tool_error' : '',
      );
    } on AgentRunCancelledException {
      rethrow;
    } on McpException catch (error) {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The MCP Tool call failed (${error.code}).',
        isError: true,
        errorCode: error.code,
      );
    } on Object {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The MCP Tool call failed.',
        isError: true,
        errorCode: 'mcp_tool_call_failed',
      );
    }
  }
}
