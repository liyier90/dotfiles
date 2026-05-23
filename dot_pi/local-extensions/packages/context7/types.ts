export interface McpContentItem {
	type: string;
	text: string;
}

export interface McpResultPayload {
	result?: {
		content?: McpContentItem[];
	};
	content?: McpContentItem[];
}

export interface ResolveLibraryArgs {
	libraryName: string;
	query: string;
}

export interface QueryDocsArgs {
	libraryId: string;
	query: string;
}

export interface CallOptions {
	/** AbortSignal for cancellation (e.g. user presses Esc). */
	signal?: AbortSignal;
	/** Timeout in milliseconds. Defaults to 25_000. */
	timeout?: number;
}
