import {
	getMarkdownTheme,
	keyText,
	type ExtensionAPI,
	type Theme,
} from "@earendil-works/pi-coding-agent";
import { StringEnum, Type } from "@earendil-works/pi-ai";
import { Container, Markdown, Spacer, Text } from "@earendil-works/pi-tui";
import { Parser } from "htmlparser2";
import TurndownService from "turndown";

const MAX_RESPONSE_SIZE = 5 * 1024 * 1024; // 5MB
const DEFAULT_TIMEOUT = 30; // 30 seconds
const MAX_TIMEOUT = 120; // 2 minutes
const COLLAPSED_PREVIEW_LINES = 7;

interface WebFetchDetails {
	url: string;
	contentType: string;
	format: string;
	displayTitle: string;
	size?: number;
	isImage?: boolean;
	imageDataUrl?: string;
	error?: boolean;
	errorSummary?: string;
}

const Parameters = Type.Object({
	url: Type.String({ description: "The URL to fetch content from" }),
	format: Type.Optional(
		StringEnum(["text", "markdown", "html"] as const, {
			description:
				"The format to return the content in - text, markdown, or html (default: 'markdown')",
		}),
	),
	timeout: Type.Optional(
		Type.Number({ description: "Optional timeout in seconds (max 120)" }),
	),
});

export default function webFetchExtension(pi: ExtensionAPI) {
	pi.registerTool<typeof Parameters, WebFetchDetails>({
		name: "webfetch",
		label: "Web Fetch",
		description: `- Fetches content from a specified URL
- Takes a URL and optional format as input
- Fetches the URL content, converts to requested format (markdown by default)
- Returns the content in the specified format
- Use this tool when you need to retrieve and analyze web content

Usage notes:
  - IMPORTANT: if another tool is present that offers better web fetching capabilities, is more targeted to the task, or has fewer restrictions, prefer using that tool instead of this one.
  - The URL must be a fully-formed valid URL
  - HTTP URLs will be automatically upgraded to HTTPS
  - Format options: "markdown" (default), "text", or "html"
  - This tool is read-only and does not modify any files
  - Results may be summarized if the content is very large`,
		promptSnippet: "Fetch content from a URL",
		parameters: Parameters,

		async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
			const url = params.url;
			const format = params.format ?? "markdown";

			// Check for cancellation
			if (signal?.aborted) {
				return {
					content: [{ type: "text", text: "Cancelled" }],
					details: {
						url,
						contentType: "",
						format,
						displayTitle: url,
						error: true,
						errorSummary: "Request cancelled",
					},
				};
			}

			if (!url.startsWith("http://") && !url.startsWith("https://")) {
				throw new Error("URL must start with http:// or https://");
			}

			const timeoutMs =
				Math.min(params.timeout ?? DEFAULT_TIMEOUT, MAX_TIMEOUT) * 1000;
			if (timeoutMs <= 0) {
				throw new Error("Timeout must be greater than 0");
			}

			let acceptHeader = "*/*";
			switch (format) {
				case "markdown":
					acceptHeader =
						"text/markdown;q=1.0, text/x-markdown;q=0.9, text/plain;q=0.8, text/html;q=0.7, */*;q=0.1";
					break;
				case "text":
					acceptHeader =
						"text/plain;q=1.0, text/markdown;q=0.9, text/html;q=0.8, */*;q=0.1";
					break;
				case "html":
					acceptHeader =
						"text/html;q=1.0, application/xhtml+xml;q=0.9, text/plain;q=0.8, text/markdown;q=0.7, */*;q=0.1";
					break;
				default:
					acceptHeader =
						"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8";
			}
			const headers = {
				"User-Agent":
					"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36",
				Accept: acceptHeader,
				"Accept-Language": "en-US,en;q=0.9",
			};

			const { body, contentType } = await fetchWithRetry(
				url,
				headers,
				signal,
				timeoutMs,
			);

			const mime = contentType.split(";")[0]?.trim().toLowerCase() || "";
			const displayTitle = `${url} (${contentType})`;

			// Handle images
			if (isImageAttachment(mime)) {
				const base64Content = Buffer.from(body).toString("base64");
				const dataUrl = `data:${mime};base64,${base64Content}`;
				return {
					content: [
						{
							type: "text",
							text: `Image fetched successfully: ${url}\nMIME type: ${mime}\nSize: ${body.byteLength} bytes`,
						},
						{
							type: "image",
							data: base64Content,
							mimeType: mime,
						},
					],
					details: {
						url,
						contentType: mime,
						format,
						displayTitle,
						size: body.byteLength,
						isImage: true,
						imageDataUrl: dataUrl,
					},
				};
			}

			// Decode body as text
			const text = new TextDecoder().decode(body);

			// Convert based on requested format
			switch (format) {
				case "markdown": {
					const output = contentType.includes("text/html")
						? convertHTMLToMarkdown(text)
						: text;
					return {
						content: [{ type: "text", text: output }],
						details: {
							url,
							contentType,
							format: "markdown",
							displayTitle,
							size: body.byteLength,
						},
					};
				}

				case "text": {
					const output = contentType.includes("text/html")
						? extractTextFromHTML(text)
						: text;
					return {
						content: [{ type: "text", text: output }],
						details: {
							url,
							contentType,
							format: "text",
							displayTitle,
							size: body.byteLength,
						},
					};
				}

				case "html":
					return {
						content: [{ type: "text", text }],
						details: {
							url,
							contentType,
							format: "html",
							displayTitle,
							size: body.byteLength,
						},
					};

				default:
					return {
						content: [{ type: "text", text }],
						details: {
							url,
							contentType,
							format,
							displayTitle,
							size: body.byteLength,
						},
					};
			}
		},

		renderResult(result, { expanded, isPartial }, theme) {
			const details = result.details;

			// Partial state: nothing to show yet
			if (isPartial && !details.url) {
				return new Text(theme.fg("muted", "Fetching..."), 0, 0);
			}

			// Image result — pass through; TUI framework auto-renders image content blocks
			if (details.isImage) {
				const sizeStr =
					details.size !== undefined
						? formatSize(details.size)
						: "unknown size";
				return new Text(
					theme.fg(
						"muted",
						`Image: ${details.displayTitle ?? details.url} (${sizeStr})`,
					),
					0,
					0,
				);
			}

			// Error result
			if (details.error) {
				return new Text(
					theme.fg("error", details.errorSummary ?? "Request failed"),
					0,
					0,
				);
			}

			const textContent = result.content
				.filter((c): c is { type: "text"; text: string } => c.type === "text")
				.map((c) => c.text)
				.join("\n");
			return createContentResultComponent(
				details,
				textContent,
				expanded,
				theme,
			);
		},
	});
}

function createContentResultComponent(
	details: WebFetchDetails,
	textContent: string,
	expanded: boolean,
	theme: Theme,
) {
	const container = new Container();

	// Title line
	const title = details.displayTitle ?? details.url ?? "Unknown URL";
	const formatLabel = details.format ? ` [${details.format}]` : "";
	container.addChild(
		new Text(
			theme.fg("syntaxKeyword", "url: ") +
				theme.fg("syntaxString", title + formatLabel),
			0,
			0,
		),
	);

	if (details.size !== undefined) {
		container.addChild(
			new Text(
				theme.fg("syntaxKeyword", "size: ") +
					theme.fg("syntaxString", formatSize(details.size)),
				0,
				0,
			),
		);
	}

	if (!textContent) {
		return container;
	}

	container.addChild(new Spacer(1));

	if (expanded) {
		// Full content rendered as markdown (or code block for non-markdown formats)
		const format = details.format ?? "markdown";
		if (format === "markdown") {
			container.addChild(new Markdown(textContent, 0, 0, getMarkdownTheme()));
		} else {
			// Render as code block for html/text formats
			const highlighted = `\`\`\`${format}\n${textContent}\n\`\`\``;
			container.addChild(new Markdown(highlighted, 0, 0, getMarkdownTheme()));
		}
	} else {
		// Collapsed: show N-line preview
		const lines = textContent
			.split("\n")
			.filter(
				(line, index, arr) =>
					line.length > 0 || index === 0 || index < arr.length - 1,
			);
		const previewLines = lines.slice(0, COLLAPSED_PREVIEW_LINES);
		const remaining = Math.max(0, lines.length - previewLines.length);

		const preview = previewLines.join("\n");
		const format = details.format ?? "markdown";
		if (format === "markdown") {
			container.addChild(new Markdown(preview, 0, 0, getMarkdownTheme()));
		} else {
			container.addChild(new Text(preview, 0, 0));
		}

		if (remaining > 0) {
			container.addChild(new Spacer(1));
			const expandKey = keyText("app.tools.expand") || "Ctrl+O";
			container.addChild(
				new Text(
					theme.fg("muted", `... (${remaining} more lines, `) +
						theme.fg("dim", expandKey) +
						theme.fg("muted", " to expand)"),
					0,
					0,
				),
			);
		}
	}

	return container;
}

async function fetchWithRetry(
	url: string,
	headers: Record<string, string>,
	signal: AbortSignal | undefined,
	timeoutMs: number,
): Promise<{ body: ArrayBuffer; contentType: string }> {
	// Set up timeout
	const controller = new AbortController();
	const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

	// Forward external signal
	const onAbort = () => controller.abort();
	if (signal) {
		if (signal.aborted) {
			throw new Error("Request aborted");
		}
		signal.addEventListener("abort", onAbort, { once: true });
	}

	try {
		const doFetch = async (ua: string) => {
			return await fetch(url, {
				method: "GET",
				headers: { ...headers, "User-Agent": ua },
				signal: controller.signal,
				redirect: "follow",
			});
		};

		let response = await doFetch(headers["User-Agent"]);
		// Retry with honest UA if blocked by Cloudflare bot detection
		if (
			response.status === 403 &&
			response.headers.get("cf-mitigated") === "challenge"
		) {
			response = await doFetch("opencode");
		}

		if (!response.ok) {
			throw new Error(`HTTP ${response.status}: ${response.statusText}`);
		}

		// Check content length
		const contentLength = response.headers.get("content-length");
		if (contentLength && parseInt(contentLength) > MAX_RESPONSE_SIZE) {
			throw new Error("Response too large (exceeds 5MB limit)");
		}

		const arrayBuffer = await response.arrayBuffer();
		if (arrayBuffer.byteLength > MAX_RESPONSE_SIZE) {
			throw new Error("Response too large (exceeds 5MB limit)");
		}

		return {
			body: arrayBuffer,
			contentType: response.headers.get("content-type") || "text/html",
		};
	} catch (err) {
		if (controller.signal.aborted && !signal?.aborted) {
			throw new Error("Request timed out");
		}
		throw err;
	} finally {
		clearTimeout(timeoutId);
		if (signal) {
			signal.removeEventListener("abort", onAbort);
		}
	}
}

function isImageAttachment(mime: string): boolean {
	return (
		mime.startsWith("image/") &&
		mime !== "image/svg+xml" &&
		mime !== "image/vnd.fastbidsheet"
	);
}

function extractTextFromHTML(html: string): string {
	let text = "";
	let skipDepth = 0;

	const parser = new Parser({
		onopentag(name) {
			if (
				skipDepth > 0 ||
				["script", "style", "noscript", "iframe", "object", "embed"].includes(
					name,
				)
			) {
				skipDepth++;
			}
		},
		ontext(input) {
			if (skipDepth === 0) {
				text += input;
			}
		},
		onclosetag() {
			if (skipDepth > 0) {
				skipDepth--;
			}
		},
	});

	parser.write(html);
	parser.end();

	return text.trim();
}

function convertHTMLToMarkdown(html: string): string {
	const turndownService = new TurndownService({
		headingStyle: "atx",
		hr: "---",
		bulletListMarker: "-",
		codeBlockStyle: "fenced",
		emDelimiter: "*",
	});
	turndownService.remove(["script", "style", "meta", "link"]);
	return turndownService.turndown(html);
}

function formatSize(bytes: number): string {
	if (bytes < 1024) return `${bytes} B`;
	if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
	return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
