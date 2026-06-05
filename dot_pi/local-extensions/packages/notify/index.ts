import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type { AssistantMessage, TextContent } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { exec } from "child_process";
import { promisify } from "util";

const execP = promisify(exec);

async function getSessionLabel(): Promise<string> {
	if (!process.env.TMUX) {
		return "(shell)";
	}
	try {
		const { stdout } = await execP("tmux display-message -p '#S'", {
			encoding: "utf-8",
		});
		return `(${stdout.trim()})`;
	} catch {
		return "(shell)";
	}
}

async function notify(title: string, message: string): Promise<void> {
	const sessionLabel = await getSessionLabel();
	execP(`wsl-notify "${title} ${sessionLabel}" "${message}"`).catch((err) =>
		console.error("notify failed:", err),
	);
}

function extractPreview(messages: AgentMessage[]): string {
	const last = [...messages]
		.reverse()
		.find((m): m is AssistantMessage => m.role === "assistant");
	if (!last) {
		return "(no assistant message)";
	}

	const text = last.content
		.filter((c): c is TextContent => c.type === "text")
		.map((c) => c.text)
		.join(" ");
	if (!text) {
		return "(no text content)";
	}

	const preview = text.slice(0, 200);
	return preview.length < text.length ? `${preview}...` : preview;
}

export default function notifyExtension(pi: ExtensionAPI) {
	pi.on("agent_end", async (event) =>
		notify("agent_end", extractPreview(event.messages)),
	);
}
