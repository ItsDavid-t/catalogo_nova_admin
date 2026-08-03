import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { "Content-Type": "application/json" } }
    );
  }

  try {
    const body = await req.json();
    const imagePath = body.imagePath;

    if (!imagePath) {
      return new Response(
        JSON.stringify({ error: "imagePath is required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const response = await supabase.storage
      .from("product-images")
      .remove([imagePath]);

    if (response.error) {
      return new Response(
        JSON.stringify({
          error: response.error.message,
          success: false,
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Image deleted: ${imagePath}`,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    const errorMessage = error instanceof Error
      ? error.message
      : String(error);

    return new Response(
      JSON.stringify({
        error: errorMessage,
        success: false,
      }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
