import type { Plugin } from "@opencode-ai/plugin"

// 🔧 CONFIGURATION: Set to true to enable this plugin
const ENABLED = true

export const Notify: Plugin = async ({ $ }) => {
  // Plugin disabled - set ENABLED = true to activate
  if (!ENABLED) return {}

  return {
    async event(input) {
      if (input.event.type === "session.idle") {
        try {
          const message = "Task completed!"

          // Cross-platform text-to-speech
          if (process.platform === "win32") {
            // Windows: Use PowerShell speech synthesis
            await $`powershell -Command "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('${message}')"`
          } else {
            // macOS/Linux: Use say command
            await $`say "${message}"`
          }
        } catch (error) {
          // Silently fail if speech synthesis is not available
          console.error("Speech notification failed:", error)
        }
      }
    },
  }
}
