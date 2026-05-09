import type { Hooks, Plugin } from "@opencode-ai/plugin";

export const ActivateEnvPlugin: Plugin = async (): Promise<Hooks> => {
	return {
		"shell.env": async (
			_input: { cwd: string; sessionID?: string; callID?: string },
			output: { env: Record<string, string> },
		): Promise<void> => {
			const venvDir = "/home/mmb/.local/packages/oc-package/.venv";
			const currentPath = output.env.PATH || process.env.PATH || "";
			output.env.PATH = `${venvDir}/bin:${currentPath}`;
			output.env.VIRTUAL_ENV = venvDir;
		},
	};
};
