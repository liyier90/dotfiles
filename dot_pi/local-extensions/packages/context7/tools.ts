import { Text } from "@earendil-works/pi-tui";
import { CONTEXT7_MCP_URL } from "./constants.js";
import { call } from "./mcp-context7.js";

interface ToolConfig {
	piToolName: string;
	mcpToolName: string;
	label: string;
	description: string;
	promptSnippet: string;
	promptGuidelines: string[];
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	parameters: any;
	timeout: number;
	loadingText: string;
	errorPrefix: string;
	fallbackText:
		| string
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		| ((params: Record<string, any>) => string);
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	toArgs: (params: Record<string, any>) => Record<string, any>;
	renderArgKey: string;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function createContext7Tool(config: ToolConfig): any {
	return {
		name: config.piToolName,
		label: config.label,
		description: config.description,
		promptSnippet: config.promptSnippet,
		promptGuidelines: config.promptGuidelines,
		parameters: config.parameters,

		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		async execute(
			_toolCallId: any,
			params: any,
			signal: any,
			_onUpdate: any,
			_ctx: any,
		) {
			const args = config.toArgs(params);
			try {
				const result = await call(CONTEXT7_MCP_URL, config.mcpToolName, args, {
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

		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		renderCall(args: any, theme: any, _context: any) {
			let text = theme.fg("toolTitle", theme.bold(config.piToolName + " "));
			text += theme.fg("muted", `"${args[config.renderArgKey]}"`);
			return new Text(text, 0, 0);
		},

		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		renderResult(result: any, options: any, theme: any, _context: any) {
			if (options.isPartial) {
				return new Text(theme.fg("warning", config.loadingText), 0, 0);
			}
			const textBlocks = (result.content ?? []).filter(
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				(c: any) => c.type === "text",
			);
			const content: string = textBlocks[0]?.text ?? "";
			const preview = options.expanded
				? content
				: content.slice(0, 300) + (content.length > 300 ? "..." : "");
			return new Text(preview, 0, 0);
		},
	};
}
