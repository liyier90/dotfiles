export const EXA_URL = "https://mcp.exa.ai/mcp";

interface McpContentItem {
	type: string;
	text: string;
}

interface McpResultPayload {
	result: {
		content: McpContentItem[];
	};
}

/** Try to parse a JSON object from a string, returning the first text content. */
function tryParsePayload(payload: string): string | undefined {
	const trimmed = payload.trim();
	if (!trimmed.startsWith("{")) return undefined;
	try {
		const data = JSON.parse(trimmed) as McpResultPayload;
		return data.result?.content?.find((item) => item.text)?.text;
	} catch {
		return undefined;
	}
}

/** Parse an MCP response body, handling both plain JSON and SSE streams. */
export function parseResponse(body: string): string | undefined {
	const trimmed = body.trim();

	// Try direct JSON parse first
	if (trimmed) {
		const direct = tryParsePayload(trimmed);
		if (direct) {
			return direct;
		}
	}

	// Try SSE lines: "data: {...}"
	for (const line of body.split("\n")) {
		if (!line.startsWith("data: ")) {
			continue;
		}
		const data = tryParsePayload(line.slice(6));
		if (data) {
			return data;
		}
	}

	return undefined;
}

export interface SearchArgs {
	query: string;
	type: string;
	numResults: number;
	livecrawl: string;
	contextMaxCharacters?: number;
}

function buildMcpRequest(toolName: string, args: SearchArgs) {
	const value: Record<string, unknown> = {
		query: args.query,
		type: args.type,
		numResults: args.numResults,
		livecrawl: args.livecrawl,
	};
	if (args.contextMaxCharacters !== undefined) {
		value.contextMaxCharacters = args.contextMaxCharacters;
	}
	return {
		jsonrpc: "2.0" as const,
		id: 1,
		method: "tools/call" as const,
		params: { name: toolName, arguments: value },
	};
}

export interface CallOptions {
	/** AbortSignal for cancellation (e.g. user presses Esc). */
	signal?: AbortSignal;
	/** Timeout in milliseconds. Defaults to 25_000. */
	timeout?: number;
}

export async function call(
	url: string,
	tool: string,
	args: SearchArgs,
	options?: CallOptions,
): Promise<string | undefined> {
	const { signal: externalSignal, timeout = 25_000 } = options ?? {};

	// Internal controller that we can abort on timeout
	const controller = new AbortController();
	// Timeout: abort after the specified duration
	const timer = setTimeout(() => controller.abort(), timeout);

	// Forward external abort signal (e.g. Esc key) to our controller
	if (externalSignal) {
		if (externalSignal.aborted) {
			throw new Error("Request aborted");
		}
		externalSignal.addEventListener("abort", () => controller.abort(), {
			once: true,
		});
	}

	try {
		const response = await fetch(url, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Accept: "application/json, text/event-stream",
			},
			body: JSON.stringify(buildMcpRequest(tool, args)),
			signal: controller.signal,
		});

		if (!response.ok) {
			throw new Error(
				`Exa MCP returned HTTP ${response.status}: ${response.statusText}`,
			);
		}

		const text = await response.text();
		const result = parseResponse(text);

		return result;
	} catch (err) {
		if (controller.signal.aborted && !externalSignal?.aborted) {
			throw new Error(`${tool} request timed out`);
		}
		throw err;
	} finally {
		clearTimeout(timer);
	}
}
