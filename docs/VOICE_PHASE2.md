# Micru voice: Phase 2

Hermes natively accepts Telegram voice notes, transcribes them, and processes the
text as a normal message. Hold Telegram's microphone button to record and release
to send. No custom phone application or voice server is required.

Current native STT choices include local faster-whisper, Groq Whisper
(`GROQ_API_KEY`) and OpenAI Whisper (`VOICE_TOOLS_OPENAI_KEY`). These are separate
audio-provider calls: they do not automatically go through our LiteLLM text route.
Choose explicitly later based on privacy, measured CPU cost and spending controls.
Phase 1 sets `stt.enabled: false` and installs no transcription model/server.

Hermes also supports speech synthesis and Telegram audio/voice responses. Its
Edge TTS option uses an external service; other providers may charge. Telegram
voice-bubble delivery requires suitable Opus encoding/ffmpeg. Existing image
dependencies may already supply it, but no extra audio stack is installed here.

The shortest later path:

1. Finish the allowlisted Telegram connection in REMOTE.md.
2. Enable one native STT provider in Hermes configuration; explicitly approve its
   download or external processing/cost. Test one short voice note.
3. Keep normal text answers initially. Measure transcription delay and resource use.
4. If desired, enable one native TTS provider and test an optional spoken reply.

Voice does not bypass the supervisor's permissions or spending authorization.
See the official [Telegram voice documentation](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram/).
