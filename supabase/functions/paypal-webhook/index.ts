// supabase/functions/paypal-webhook/index.ts
// Handles PayPal webhooks for subscription events.
// Secrets needed: PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET, PAYPAL_WEBHOOK_ID

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYPAL_API = "https://api-m.paypal.com";

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

    const body = await req.text();
    const headers = req.headers;

    // TODO: Verify PayPal webhook signature
    // const verified = await verifyPayPalWebhook(body, headers);
    // if (!verified) return new Response("Invalid signature", { status: 400 });

    const event = JSON.parse(body);
    const eventType = event.event_type;
    const resource = event.resource;

    switch (eventType) {
      case "BILLING.SUBSCRIPTION.ACTIVATED":
      case "BILLING.SUBSCRIPTION.UPDATED": {
        const subId = resource.id;
        const customId = resource.custom_id; // Your user ID
        
        await admin.from("profiles").update({
          is_premium: true,
          paypal_subscription_id: subId,
          premium_until: resource.billing_info?.next_billing_time,
        }).eq("id", customId);
        break;
      }

      case "BILLING.SUBSCRIPTION.CANCELLED":
      case "BILLING.SUBSCRIPTION.SUSPENDED":
      case "BILLING.SUBSCRIPTION.EXPIRED": {
        const subId = resource.id;
        
        await admin.from("profiles").update({
          is_premium: false,
          premium_until: null,
        }).eq("paypal_subscription_id", subId);
        break;
      }

      case "PAYMENT.SALE.COMPLETED": {
        // Record payment
        await admin.from("transactions").insert({
          paypal_subscription_id: resource.billing_agreement_id,
          amount: parseFloat(resource.amount.total),
          status: "completed",
          type: "premium_payment",
        });
        break;
      }
    }

    return new Response(JSON.stringify({ received: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
