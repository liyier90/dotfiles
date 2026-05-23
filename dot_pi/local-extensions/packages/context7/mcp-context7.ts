import { CONTEXT7_MCP_URL, SESSION_TIMEOUT, DEFAULT_TIMEOUT } from "./constants.js";
import type { McpContentItem, McpResultPayload, CallOptions } from "./types.js";

let sessionId: string | null = null;

async function ensureSession(options?: {
	signal?: AbortSignal;
}): Promise<void> {
	if (sessionId) return;

	const controller = new AbortController();
	const timer = setTimeout(() => controller.abort(), SESSION_TIMEOUT);

	if (options?.signal) {
		if (options.signal.aborted) throw new Error("Request aborted");
		options.signal.addEventListener("abort", () => controller.abort(), {
			once: true,
		});
	}

	try {
		const response = await fetch(CONTEXT7_MCP_URL, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Accept: "application/json, text/event-stream",
			},
			body: JSON.stringify({
				jsonrpc: "2.0",
				id: 0,
				method: "initialize",
				params: {
					protocolVersion: "2024-11-05",
					capabilities: {},
					clientInfo: { name: "pi", version: "1.0.0" },
				},
			}),
			signal: controller.signal,
		});

		if (!response.ok) {
			throw new Error(
				`Context7 MCP initialize returned HTTP ${response.status}: ${response.statusText}`,
			);
		}

		const newSessionId = response.headers.get("mcp-session-id");
		if (!newSessionId) {
			throw new Error("Context7 MCP initialize did not return a session ID");
		}

		sessionId = newSessionId;
	} finally {
		clearTimeout(timer);
	}
}



/** Try to parse a JSON object from a string, extracting text from content array. */
function tryParsePayload(payload: string): string | undefined {
	const trimmed = payload.trim();
	if (!trimmed.startsWith("{")) return undefined;
	try {
		const data = JSON.parse(trimmed) as McpResultPayload;
		// MCP tool result format: { result: { content: [...] } }
		if (data.result?.content) {
			return data.result.content
				.filter((item) => item.type === "text")
				.map((item) => item.text)
				.join("\n\n");
		}
		// Direct content format (SSE-style)
		if (data.content) {
			return data.content
				.filter((item) => item.type === "text")
				.map((item) => item.text)
				.join("\n\n");
		}
		return undefined;
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
		if (direct) return direct;
	}

	// Try SSE lines: "data: {...}"
	for (const line of body.split("\n")) {
		if (!line.startsWith("data: ")) continue;
		const data = tryParsePayload(line.slice(6));
		if (data) return data;
	}

	return undefined;
}



function buildMcpRequest(toolName: string, args: Record<string, unknown>) {
	return {
		jsonrpc: "2.0" as const,
		id: 1,
		method: "tools/call" as const,
		params: { name: toolName, arguments: args },
	};
}



export async function call(
	url: string,
	tool: string,
	args: Record<string, unknown>,
	options?: CallOptions,
): Promise<string | undefined> {
	const { signal: externalSignal, timeout = DEFAULT_TIMEOUT } = options ?? {};

	// Ensure we have a session before making tool calls
	await ensureSession({ signal: externalSignal });

	const controller = new AbortController();
	const timer = setTimeout(() => controller.abort(), timeout);

	if (externalSignal) {
		if (externalSignal.aborted) {
			throw new Error("Request aborted");
		}
		externalSignal.addEventListener("abort", () => controller.abort(), {
			once: true,
		});
	}

	try {
		const headers: Record<string, string> = {
			"Content-Type": "application/json",
			Accept: "application/json, text/event-stream",
			"MCP-Session-Id": sessionId!,
		};

		const response = await fetch(url, {
			method: "POST",
			headers,
			body: JSON.stringify(buildMcpRequest(tool, args)),
			signal: controller.signal,
		});

		if (!response.ok) {
			throw new Error(
				`Context7 MCP returned HTTP ${response.status}: ${response.statusText}`,
			);
		}

		const text = await response.text();
		const result = parseResponse(text);

		if (!result) {
			// If we couldn't parse structured content, return raw text if it looks like a plain result
			const trimmed = text.trim();
			if (trimmed && !trimmed.startsWith("{") && !trimmed.startsWith("data:")) {
				return trimmed;
			}
		}

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
