import type { Hooks, Plugin } from "@opencode-ai/plugin";
import type { Event } from "@opencode-ai/sdk";
import {
	EventPermissionAsked,
	EventQuestionAsked,
	EventSessionError,
	EventSessionIdle,
	Event as EventV2,
} from "@opencode-ai/sdk/v2";
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

function notifyQuestionAsked(event: EventQuestionAsked): void {
	const question = event.properties.questions[0]?.question ?? "(no question)";
	notify(event.type, question);
}

function notifyPermissionAsked(event: EventPermissionAsked): void {
	notify(event.type, event.properties.permission);
}

function notifySessionError(event: EventSessionError): void {
	const error = event.properties.error;
	const errorMessage =
		typeof error === "string" ? error : JSON.stringify(error);
	notify(event.type, errorMessage);
}

function notifySessionIdle(event: EventSessionIdle): void {
	notify(event.type, "Done");
}

export const NotifyPlugin: Plugin = async (): Promise<Hooks> => {
	return {
		event: async ({ event }: { event: Event }): Promise<void> => {
			const runtimeEvent = event as EventV2;
			if (!("type" in runtimeEvent)) {
				return;
			}
			const handlers: Partial<Record<EventV2["type"], () => void>> = {
				"permission.asked": () =>
					notifyPermissionAsked(runtimeEvent as EventPermissionAsked),
				"question.asked": () =>
					notifyQuestionAsked(runtimeEvent as EventQuestionAsked),
				"session.error": () =>
					notifySessionError(runtimeEvent as EventSessionError),
				"session.idle": () =>
					notifySessionIdle(runtimeEvent as EventSessionIdle),
			};
			handlers[runtimeEvent.type]?.();
		},
	};
};
