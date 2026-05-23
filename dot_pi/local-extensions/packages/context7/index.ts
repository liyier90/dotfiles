import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "@earendil-works/pi-ai";

import {
	PI_TOOL_RESOLVE,
	PI_TOOL_QUERY,
	MCP_TOOL_RESOLVE,
	MCP_TOOL_QUERY,
	RESOLVE_TIMEOUT,
	QUERY_TIMEOUT,
} from "./constants.js";
import { createContext7Tool } from "./tools.js";

const ResolveLibraryIdParameters = Type.Object({
	libraryName: Type.String({
		description:
			"Library name to search for and retrieve a Context7-compatible library ID. Use the official library name with proper punctuation — e.g., 'Next.js' instead of 'nextjs', 'Customer.io' instead of 'customerio', 'Three.js' instead of 'threejs'.",
	}),
	query: Type.String({
		description:
			"The question or task you need help with. This is used to rank library results by relevance to what the user is trying to accomplish. The query is sent to the Context7 API for processing. Do not include any sensitive or confidential information such as API keys, passwords, credentials, personal data, or proprietary code in your query.",
	}),
});

const QueryDocsParams = Type.Object({
	libraryId: Type.String({
		description:
			"Exact Context7-compatible library ID (e.g., '/mongodb/docs', '/vercel/next.js', '/supabase/supabase', '/vercel/next.js/v14.3.0-canary.87') retrieved from 'resolve-library-id' or directly from user query in the format '/org/project' or '/org/project/version'.",
	}),
	query: Type.String({
		description:
			"The question or task you need help with. Be specific and include relevant details. Good: 'How to set up authentication with JWT in Express.js' or 'React useEffect cleanup function examples'. Bad: 'auth' or 'hooks'. The query is sent to the Context7 API for processing. Do not include any sensitive or confidential information such as API keys, passwords, credentials, personal data, or proprietary code in your query.",
	}),
});

// ── Extension ──────────────────────────────────────────────────────────

export default function context7Extension(pi: ExtensionAPI) {
	const year = new Date().getFullYear();

	pi.registerTool(
		createContext7Tool({
			piToolName: PI_TOOL_RESOLVE,
			mcpToolName: MCP_TOOL_RESOLVE,
			label: "Context7 Resolve Library ID",
			description:
				"Resolves a library or package name to a Context7-compatible library ID. Call this first when you don't know the exact Context7 library ID for a library the user wants documentation for.",
			promptSnippet: "Resolve a library name to a Context7 library ID",
			promptGuidelines: [
				`Use ${PI_TOOL_RESOLVE} when the user asks for library documentation and you do not already know the exact Context7 library ID.`,
				`After resolving, use ${PI_TOOL_QUERY} with the returned library ID to fetch the actual documentation.`,
			],
			parameters: ResolveLibraryIdParameters,
			timeout: RESOLVE_TIMEOUT,
			loadingText: "Resolving...",
			errorPrefix: "Context7 resolve failed",
			fallbackText: (params: Record<string, unknown>) =>
				`No Context7 libraries matched "${params.libraryName}". Try a different search term.`,
			toArgs: (params) => ({
				libraryName: params.libraryName,
				query: params.query,
			}),
			renderArgKey: "libraryName",
		}),
	);

	pi.registerTool(
		createContext7Tool({
			piToolName: PI_TOOL_QUERY,
			mcpToolName: MCP_TOOL_QUERY,
			label: "Context7 Query Docs",
			description: `- Fetches up-to-date documentation and code examples for a library using its Context7-compatible library ID.
- Returns curated, version-specific documentation with code examples.

Usage notes:
  - Obtain the library ID from ${PI_TOOL_RESOLVE} first, unless the user provides an explicit ID like '/vercel/next.js'.`,
			promptSnippet: "Fetch up-to-date Context7 docs for a library",
			promptGuidelines: [
				`Prefer ${PI_TOOL_QUERY} for fetching library documentation. Call ${PI_TOOL_RESOLVE} first if you don't know the exact Context7 library ID.`,
				`The current year is ${year}. Context7 provides up-to-date docs that reflect recent library changes.`,
				"Use context7 for documentation even for well-known libraries — your training data may not reflect recent changes.",
			],
			parameters: QueryDocsParams,
			timeout: QUERY_TIMEOUT,
			loadingText: "Fetching docs...",
			errorPrefix: "Context7 docs fetch failed",
			fallbackText: `No documentation found for that library ID. Try resolving the library ID again with ${PI_TOOL_RESOLVE}.`,
			toArgs: (params) => ({
				libraryId: params.libraryId,
				query: params.query,
			}),
			renderArgKey: "libraryId",
		}),
	);
}
