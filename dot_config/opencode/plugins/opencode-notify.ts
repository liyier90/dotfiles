import { Hooks, Plugin } from "@opencode-ai/plugin";
import { Event } from "@opencode-ai/sdk";
import {
	EventPermissionAsked,
	EventQuestionAsked,
	EventSessionError,
	EventSessionIdle,
	Event as EventV2,
} from "@opencode-ai/sdk/v2";
import { exec } from "child_process";

function notify(title: string, message: string): void {
	exec(`notify-send "${title}" "${message}"`, (err) => {
		if (err) console.error("notify failed:", err);
	});
}

function notifyQuestionAsked(event: EventQuestionAsked): void {
	const question = event.properties.questions[0]?.question ?? "(no question)";
	notify(`${event.type} (${event.properties.sessionID})`, question);
}

function notifyPermissionAsked(event: EventPermissionAsked): void {
	notify(
		`${event.type} (${event.properties.sessionID})`,
		event.properties.permission,
	);
}

function notifySessionError(event: EventSessionError): void {
	const error = event.properties.error;
	const errorMessage =
		typeof error === "string" ? error : String(error ?? "Unknown error");
	notify(event.type, errorMessage);
}

function notifySessionIdle(event: EventSessionIdle): void {
	notify(`${event.type} (${event.properties.sessionID})`, "Done");
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

