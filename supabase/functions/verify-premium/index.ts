// supabase/functions/verify-premium/index.ts
// Verifies PayPal subscriptions server-side and grants premium.
// Secrets needed (supabase secrets set ...):
//   PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET, PAYPAL_PREMIUM_PLAN_ID
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are auto-injected.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYPAL_API = "https://api-m.paypal.com"; // LIVE. Never sandbox here.
const PLAN_ID = Deno.env.get("PAYPAL_PREMIUM_PLAN_ID")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "https://mychainlink.ca",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

async function getPayPalToken(): Promise<string> {
  const res = await fetch(`${PAYPAL_API}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      "Authorization": "Basic " + btoa(
        `${Deno.env.get("PAYPAL_CLIENT_ID")}:${Deno.env.get("PAYPAL_CLIENT_SECRET")}`
      ),
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  if (!res.ok) throw new Error("PayPal auth failed");
  return (await res.json()).access_token;
}

async function getSubscription(token: string, subId: string) {
  const res = await fetch(`${PAYPAL_API}/v1/billing/subscriptions/${subId}`, {
    headers: { "Authorization": `Bearer ${token}` },
  });
  if (!res.ok) return null;
  return await res.json();
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // Identify the calling user from THEIR Supabase session token
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );
    const { data: { user }, error: authErr } = await admin.auth.getUser(
      authHeader.replace("Bearer ", "")
    );
    if (authErr || !user) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    const { action, subscriptionID } = await req.json();

    // Determine which subscription to check
    let subId = subscriptionID;
    if (action === "refresh") {
      const { data: prof } = await admin
        .from("profiles").select("paypal_subscription_id").eq("id", user.id).single();
      subId = prof?.paypal_subscription_id;
    }
    if (!subId) {
      return new Response(JSON.stringify({ premium: false, reason: "no_subscription" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // Ask PayPal directly — the only source of truth
    const token = await getPayPalToken();
    const sub = await getSubscription(token, subId);
    const active = sub && (sub.status === "ACTIVE" || sub.status === "APPROVED");
    const correctPlan = sub && sub.plan_id === PLAN_ID;

    if (active && correctPlan) {
      const until = sub.billing_info?.next_billing_time ?? null;
      await admin.from("profiles").update({
        is_premium: true,
        premium_until: until,
        paypal_subscription_id: subId,
      }).eq("id", user.id);

      if (action === "verify") {
        await admin.from("transactions").insert({
          payer_id: user.id,
          creator_id: null,
          amount: 10.99,
          platform_fee: 10.99,
          creator_amount: 0,
          paypal_subscription_id: subId,
          status: "completed",
          type: "premium_subscription",
        });
      }
      return new Response(JSON.stringify({ premium: true, until }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // Not active / wrong plan / cancelled → strip premium
    await admin.from("profiles").update({ is_premium: false }).eq("id", user.id);
    return new Response(JSON.stringify({ premium: false, status: sub?.status ?? "not_found" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
