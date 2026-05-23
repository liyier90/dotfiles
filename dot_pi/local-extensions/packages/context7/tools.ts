import { Text } from "@earendil-works/pi-tui";
import { type Static, type TSchema } from "typebox";
import { CONTEXT7_MCP_URL } from "./constants.js";
import { createMcpClient } from "./mcp-client.js";
import { ToolDefinition } from "@earendil-works/pi-coding-agent";

const context7Client = createMcpClient({
	url: CONTEXT7_MCP_URL,
	clientInfo: { name: "pi", version: "1.0.0" },
	errorLabel: "Context7",
});

interface ToolConfig<TParams extends TSchema> {
	piToolName: string;
	mcpToolName: string;
	label: string;
	description: string;
	promptSnippet: string;
	promptGuidelines: string[];
	parameters: TParams;
	timeout: number;
	loadingText: string;
	errorPrefix: string;
	fallbackText: string | ((params: Static<TParams>) => string);
	toArgs: (params: Static<TParams>) => Record<string, unknown>;
	renderArgKey: string;
}

export function createContext7Tool<TParams extends TSchema>(
	config: ToolConfig<TParams>,
): ToolDefinition<TParams, Record<string, unknown>> {
	return {
		name: config.piToolName,
		label: config.label,
		description: config.description,
		promptSnippet: config.promptSnippet,
		promptGuidelines: config.promptGuidelines,
		parameters: config.parameters,

		async execute(
			_toolCallId: string,
			params: Static<TParams>,
			signal: AbortSignal | undefined,
			_onUpdate: undefined,
			_ctx,
		) {
			const args = config.toArgs(params);
			try {
				const result = await context7Client.call(config.mcpToolName, args, {
					signal,
					timeout: config.timeout,
				});
				const fallback =
					typeof config.fallbackText === "function"
						? config.fallbackText(params)
						: config.fallbackText;
				return {
					content: [{ type: "text", text: result ?? fallback }],
					details: { ...params },
				};
			} catch (err) {
				const message = err instanceof Error ? err.message : String(err);
				throw new Error(`${config.errorPrefix}: ${message}`);
			}
		},

		renderCall(args: Static<TParams>, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold(config.piToolName + " "));
			text += theme.fg("muted", `"${args[config.renderArgKey]}"`);
			return new Text(text, 0, 0);
		},

		renderResult(result, options, theme, _context) {
			if (options.isPartial) {
				return new Text(theme.fg("warning", config.loadingText), 0, 0);
			}
			const textContent = (result.content ?? [])
				.filter((c): c is { type: "text"; text: string } => c.type === "text")
				.map((c) => c.text)
				.join("\n");
			const preview = options.expanded
				? textContent
				: textContent.slice(0, 300) + (textContent.length > 300 ? "..." : "");
			return new Text(preview, 0, 0);
		},
	};
}
