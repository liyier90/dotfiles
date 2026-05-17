import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { exec } from "child_process";
import { promisify } from "util";

const execP = promisify(exec);

async function getSessionLabel(): Promise<string> {
	if (!process.env.TMUX) return "(shell)";
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

export default function notifyExtension(pi: ExtensionAPI) {
	pi.on("agent_end", async () => notify("agent_end", "Done"));
}
