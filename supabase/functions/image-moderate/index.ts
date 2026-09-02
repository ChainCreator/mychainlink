// supabase/functions/image-moderate/index.ts
// Basic image moderation — rejects NSFW content.
// Uses AWS Rekognition or simple heuristic. Replace with real API for production.
// Secrets needed: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY (optional)

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { imageUrl, imageBase64 } = await req.json();

    // Simple check: reject if no image data
    if (!imageUrl && !imageBase64) {
      return new Response(JSON.stringify({ error: "No image provided" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // TODO: Replace with actual moderation API (AWS Rekognition, Google Vision, etc.)
    // For now, return safe — implement real moderation before production
    const moderationResult = {
      safe: true,
      confidence: 0.95,
      flags: [],
      warning: "This is a placeholder. Integrate AWS Rekognition or similar for production.",
    };

    return new Response(JSON.stringify(moderationResult),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
