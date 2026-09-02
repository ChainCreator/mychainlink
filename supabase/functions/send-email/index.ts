// supabase/functions/send-email/index.ts
// Sends emails via Resend API.
// Secrets needed: RESEND_API_KEY

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { to, subject, html, text } = await req.json();
    
    if (!to || !subject || (!html && !text)) {
      return new Response(JSON.stringify({ error: "Missing required fields: to, subject, html|text" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "MyChainLink <noreply@mychainlink.ca>",
        to,
        subject,
        html,
        text,
      }),
    });

    const data = await res.json();
    
    if (!res.ok) {
      return new Response(JSON.stringify({ error: data }),
        { status: res.status, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    return new Response(JSON.stringify({ success: true, id: data.id }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
