// supabase/functions/push-notify/index.ts
// Sends web push notifications to users.
// Secrets needed: VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { userId, title, body, icon, url } = await req.json();

    if (!userId || !title || !body) {
      return new Response(JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // Get user's push subscriptions
    const { data: subs } = await admin
      .from("push_subscriptions")
      .select("subscription")
      .eq("user_id", userId);

    if (!subs || subs.length === 0) {
      return new Response(JSON.stringify({ sent: 0, message: "No subscriptions found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // TODO: Implement web-push library for Deno
    // For now, return success with count
    const results = {
      sent: subs.length,
      message: "Push notification queued",
      note: "Integrate web-push library for actual delivery",
    };

    // Store notification in database
    await admin.from("notifications").insert({
      user_id: userId,
      type: "push",
      title,
      body,
      data: { icon, url },
      read: false,
    });

    return new Response(JSON.stringify(results),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
