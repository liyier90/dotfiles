import type { Api, Model } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	toOpenAICompletionsModelConfig,
	toOpenAIResponsesModelConfig,
	toStandardModelConfig,
} from "./src/config.js";
import {
	MODELS_DEV_ZEN_PROVIDER_ID,
	ZEN_ANTHROPIC_BASE_URL,
	ZEN_LABEL,
	ZEN_MODELS_ENDPOINT,
	ZEN_PROVIDER_ID,
	ZEN_V1_BASE_URL,
} from "./src/constants.js";
import {
	fetchModelsDevMetadata,
	loadProviderBuckets,
	resolveZenTransport,
} from "./src/discovery.js";
import { createApiKeyBackedOAuthProvider } from "./src/oauth.js";
import type { ModelBuckets } from "./src/types.js";

/** Flatten Zen model buckets into the flat model-config array pi expects. */
function buildZenProviderModels(buckets: ModelBuckets) {
	return [
		...buckets.chat.map(toOpenAICompletionsModelConfig),
		...buckets.responses.map(toOpenAIResponsesModelConfig),
		...buckets.google.map((m) =>
			toStandardModelConfig(m, "google-generative-ai"),
		),
		...buckets.anthropic.map((m) =>
			toStandardModelConfig(m, "anthropic-messages"),
		),
	];
}

/** Point provider models to the correct base URL (Anthropic Messages vs everything else). */
function rewriteProviderModelBaseUrls(
	models: Model<Api>[],
	providerId: string,
	defaultBaseUrl: string,
	anthropicBaseUrl: string,
) {
	return models.map((model) => {
		if (model.provider !== providerId) {
			return model;
		}
		return {
			...model,
			baseUrl:
				model.api === "anthropic-messages" ? anthropicBaseUrl : defaultBaseUrl,
		};
	});
}

export default async function (pi: ExtensionAPI) {
	let modelsDev;
	try {
		modelsDev = await fetchModelsDevMetadata();
	} catch (error) {
		console.warn(`[opencode] Fetch models.dev metadata failed`, error);
	}

	const zenBuckets = await loadProviderBuckets({
		label: ZEN_LABEL,
		officialEndpoint: ZEN_MODELS_ENDPOINT,
		provider: modelsDev?.[MODELS_DEV_ZEN_PROVIDER_ID],
		resolveTransport: (modelId) => resolveZenTransport(modelId),
	});
	pi.registerProvider(ZEN_PROVIDER_ID, {
		baseUrl: ZEN_V1_BASE_URL,
		models: buildZenProviderModels(zenBuckets),
		oauth: createApiKeyBackedOAuthProvider({
			displayName: "OpenCode Zen",
			promptLabel: "OpenCode Zen",
			modifyModels: (models) =>
				rewriteProviderModelBaseUrls(
					models,
					ZEN_PROVIDER_ID,
					ZEN_V1_BASE_URL,
					ZEN_ANTHROPIC_BASE_URL,
				),
		}),
	});
}
