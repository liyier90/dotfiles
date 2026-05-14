/**
 * Exa Web Search Extension
 *
 * Integrates the Exa MCP server (https://mcp.exa.ai/mcp) as a pi tool.
 * Uses the MCP JSON-RPC 2.0 protocol over HTTP.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { StringEnum, Type } from "@earendil-works/pi-ai";
import { Text } from "@earendil-works/pi-tui";

import { EXA_URL, SearchArgs, call } from "./src/mcp-websearch.js";

const Parameters = Type.Object({
	query: Type.String({ description: "Web search query" }),
	numResults: Type.Optional(
		Type.Number({
			description: "Number of search results to return (default: 8)",
		}),
	),
	livecrawl: Type.Optional(
		StringEnum(["fallback", "preferred"] as const, {
			description:
				"Live crawl mode - 'fallback': use live crawling as backup if cached content unavailable, 'preferred': prioritize live crawling (default: 'fallback')",
		}),
	),
	type: Type.Optional(
		StringEnum(["auto", "fast", "deep"] as const, {
			description:
				"Search type - 'auto': balanced search (default), 'fast': quick results, 'deep': comprehensive search",
		}),
	),
	contextMaxCharacters: Type.Optional(
		Type.Number({
			description:
				"Maximum characters for context string optimized for LLMs (default: 10000)",
		}),
	),
});

export default function webSearch(pi: ExtensionAPI) {
	const year = new Date().getFullYear();

	pi.registerTool({
		name: "websearch",
		label: "Web Search",
		description: `- Search the web using the session's web search provider - performs real-time web searches and can scrape content from specific URLs.
- Provides up-to-date information for current events and recent data.
- Supports configurable result counts and returns the content from the most relevant websites.
- Use this tool for accessing information beyond knowledge cutoff.
- Searches are performed automatically within a single API call.

Usage notes:
  - Supports live crawling modes when available: 'fallback' (backup if cached unavailable) or 'preferred' (prioritize live crawling)
  - Search types when available: 'auto' (balanced), 'fast' (quick results), 'deep' (comprehensive search)
  - Configurable context length for optimal LLM integration`,
		promptSnippet: "Search the web",
		promptGuidelines: [
			"Use websearch to find current information, documentation, or answers that require up-to-date web data. Always cite sources from search results.",
			`The current year is ${year}. You MUST use this year when searching for recent information or current events.\n- Example: If the current year is ${year} and the user asks for "latest AI news", search for "AI news ${year}", NOT "AI news ${year - 1}"`,
		],
		parameters: Parameters,

		async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
			const args: SearchArgs = {
				query: params.query,
				type: params.type ?? "auto",
				numResults: params.numResults ?? 8,
				livecrawl: params.livecrawl ?? "fallback",
				contextMaxCharacters: params.contextMaxCharacters,
			};

			try {
				const result = await call(EXA_URL, "web_search_exa", args, {
					signal,
					timeout: 25_000,
				});

				return {
					content: [
						{
							type: "text",
							text:
								result ??
								"No search results found. Please try a different query.",
						},
					],
					details: { query: params.query, provider: "exa" },
				};
			} catch (err) {
				const message = err instanceof Error ? err.message : String(err);
				throw new Error(`Web search failed: ${message}`);
			}
		},

		renderCall(args, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold("websearch "));
			text += theme.fg("muted", `"${args.query}"`);
			return new Text(text, 0, 0);
		},

		renderResult(result, options, theme, _context) {
			if (options.isPartial) {
				return new Text(theme.fg("warning", "Searching..."), 0, 0);
			}
			const content: string = result.content?.[0]?.text ?? "";
			const preview = options.expanded
				? content
				: content.slice(0, 200) + (content.length > 200 ? "..." : "");
			return new Text(preview, 0, 0);
		},
	});
}
