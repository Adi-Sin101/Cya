# Cya! — EmbeddingGemma 2 Core Requirement Clarification

This note resolves an ambiguity in the product-direction PRD. **EmbeddingGemma 2 is not optional.** Its on-device semantic and multimodal embedding capability is central to Cya!'s intended evolution from an intention manager into a personal memory that can connect, retrieve, and explore the user's own thoughts.

## Required behavior
- Local semantic retrieval for text memories.
- Direct embedding of original voice recordings, so text queries can retrieve semantically relevant audio even with no transcript.
- Similar-memory discovery and candidate links, labeled as suggestions and never treated as facts or auto-merged.
- Image/video modality support on the roadmap using the model's shared multimodal embedding space; stage UI work if needed but do not downgrade the core model requirement.
- No remote inference. All indexing and search run on device.

## Important technical distinction
EmbeddingGemma 2 is an embedding model, not speech-to-text and not a generative assistant. It can represent audio for semantic retrieval, but a readable transcript requires a separate offline ASR component. Text capture, original audio capture, persistence, reminders, and keyword search must remain responsive if model inference fails; that is a resilience fallback, not permission to ship without semantic memory.

## Engineering rule
Benchmarking determines the exact artifact, modular encoder loading, quantization, runtime and background scheduling. It does not decide whether semantic/multimodal memory is part of the product. If no configuration meets the target-device budget after reasonable optimization, Codex must report measured results and request an explicit product decision rather than silently making this capability optional.

Official sources (verify again during implementation because model tooling evolves):
- https://ai.google.dev/gemma/docs/embeddinggemma/model_card_2?hl=en
- https://ai.google.dev/gemma/docs/embeddinggemma/multimodal-embeddinggemma-with-sentence-transformers
- https://developers.googleblog.com/google-ai-edge-with-embeddinggemma-2/
