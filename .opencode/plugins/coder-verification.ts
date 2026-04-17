import type { Plugin } from "@opencode-ai/plugin";

/**
 * CoderAgent Assistant Plugin - Simplified Version
 * 
 * Actively helps CoderAgent by showing reminders and toasts
 */

export const CoderAgentAssistantPlugin: Plugin = async (ctx) => {
  const { client } = ctx;

  // ✅ Đúng format theo docs: { body: { service, level, message } }
  await client.app.log({
    body: { service: "coder-agent-assistant", level: "info", message: "CoderAgent Assistant Plugin initialized" }
  });

  return {
    // Hook 1: Before CoderAgent starts
    "tool.execute.before": async (input: any, output: any) => {
      if (input.tool === "task" && input.args?.subagent_type === "CoderAgent") {
        // ✅ Đúng cú pháp: client.tui.showToast({ body: {...} })
        await client.tui.showToast({
          body: {
            title: "🤖 CoderAgent Assistant",
            message: "Monitoring CoderAgent work - checks will be validated",
            variant: "info",
            duration: 4000,
          },
        }).catch(() => { });
      }
    },

    // Hook 2: After CoderAgent completes
    "tool.execute.after": async (input: any, output: any) => {
      if (input.tool === "task" && input.args?.subagent_type === "CoderAgent") {
        const result = output.result || "";

        // Check for self-review
        const hasSelfReview =
          result.includes("Self-Review") ||
          result.includes("✅ Types clean");

        // Check for deliverables
        const hasDeliverables =
          result.includes("Deliverables:") ||
          result.includes("created");

        console.log("\n🤖 CoderAgent Assistant: Validation");
        console.log(`   Self-Review: ${hasSelfReview ? '✅' : '⚠️'}`);
        console.log(`   Deliverables: ${hasDeliverables ? '✅' : '⚠️'}`);

        // ✅ variant thay cho type: "success" | "warning" | "info" | "error"
        if (hasSelfReview && hasDeliverables) {
          await client.tui.showToast({
            body: {
              title: "✅ CoderAgent Checks Passed",
              message: "All validation checks completed successfully",
              variant: "success",
              duration: 5000,
            },
          }).catch(() => { });
        } else {
          await client.tui.showToast({
            body: {
              title: "⚠️ CoderAgent Validation",
              message: "Some checks need attention",
              variant: "warning",
              duration: 6000,
            },
          }).catch(() => { });
        }
      }
    },

    // Hook 3: Session idle — ⚠️ Docs liệt kê "session.idle" là event, không phải hook trực tiếp
    // Dùng qua event handler thay vì hook tên trực tiếp
    async event({ event }) {
      if (event.type === "session.idle") {
        await client.tui.showToast({
          body: {
            title: "🤖 Session Summary",
            message: "CoderAgent Assistant monitoring complete",
            variant: "info",
            duration: 4000,
          },
        }).catch(() => { });
      }
    }
  };
};

export default CoderAgentAssistantPlugin;
