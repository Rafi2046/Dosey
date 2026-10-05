// Sends a caregiver nudge to the patient's devices through FCM, so it
// arrives while Dosey is in the background or closed.
//
// Called by the `family_nudges_push` trigger (see family_sharing_schema.sql)
// with `{ "nudge_id": "<uuid>" }`. It loads the nudge itself with the service
// role, so a forged call can at most re-send a real, still-unread nudge.
//
// Secrets: FIREBASE_SERVICE_ACCOUNT (the Firebase service-account JSON).
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by Supabase.

import { createClient } from "npm:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5";

// Same key as AppConstants.channelGentle in the app.
const ANDROID_CHANNEL = "dosey_gentle_v2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!);

let cachedToken: { value: string; expiresAt: number } | null = null;

/** OAuth access token for the FCM HTTP v1 API, cached until near expiry. */
async function accessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt - 60 > now) return cachedToken.value;

  const key = await importPKCS8(serviceAccount.private_key, "RS256");
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`OAuth token: ${res.status} ${await res.text()}`);
  const json = await res.json();
  cachedToken = { value: json.access_token, expiresAt: now + json.expires_in };
  return cachedToken.value;
}

/** Sends one push. Returns "ok", "stale" (token no longer valid) or "failed". */
async function send(
  token: string,
  title: string,
  body: string,
  nudgeId: string,
): Promise<"ok" | "stale" | "failed"> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await accessToken()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: { type: "caregiver_nudge", nudge_id: nudgeId },
          android: {
            priority: "HIGH",
            notification: { channel_id: ANDROID_CHANNEL, sound: "default" },
          },
          apns: {
            headers: { "apns-priority": "10" },
            payload: { aps: { sound: "default" } },
          },
        },
      }),
    },
  );
  if (res.ok) return "ok";
  const text = await res.text();
  console.error(`FCM send failed: ${res.status} ${text}`);
  return res.status === 404 || text.includes("UNREGISTERED") ? "stale" : "failed";
}

Deno.serve(async (req) => {
  const { nudge_id: nudgeId } = await req.json().catch(() => ({}));
  if (typeof nudgeId !== "string") {
    return new Response("nudge_id required", { status: 400 });
  }

  // Claim the nudge so the app's in-app listener doesn't show it again.
  // If the app already claimed it (it was open), there's nothing to do.
  const { data: nudge, error } = await supabase
    .from("family_nudges")
    .update({ is_read: true })
    .eq("id", nudgeId)
    .eq("is_read", false)
    .select()
    .maybeSingle();
  if (error) return new Response(error.message, { status: 500 });
  if (!nudge) return Response.json({ sent: 0, reason: "already delivered" });

  const release = () =>
    supabase.from("family_nudges").update({ is_read: false }).eq("id", nudgeId);

  const { data: devices } = await supabase
    .from("device_push_tokens")
    .select("token")
    .eq("uid", nudge.patient_uid);
  if (!devices?.length) {
    // No registered device: leave it for the app to deliver when opened.
    await release();
    return Response.json({ sent: 0, reason: "no devices" });
  }

  const title = `🔔 Reminder from ${nudge.caregiver_name ?? "Your Family Member"}`;
  const body = nudge.message ?? "It is time to take your scheduled medicines!";

  let sent = 0;
  for (const { token } of devices) {
    const result = await send(token, title, body, nudgeId);
    if (result === "ok") sent++;
    if (result === "stale") {
      await supabase.from("device_push_tokens").delete().eq("token", token);
    }
  }
  if (sent === 0) await release();
  return Response.json({ sent });
});
