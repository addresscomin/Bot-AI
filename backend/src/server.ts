import express, { type Request } from "express";
import cors from "cors";
import helmet from "helmet";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";

const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN?.split(",") ?? false }));
app.use(express.json({ limit: "64kb" }));

const port = Number(process.env.PORT ?? 8080);
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_PUBLISHABLE_KEY;

const db: SupabaseClient | null = supabaseUrl && supabaseKey
  ? createClient(supabaseUrl, supabaseKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    })
  : null;

type UserContext = {
  userId: string;
  email: string | undefined;
  roles: string[];
  client: SupabaseClient;
};

async function getUserContext(req: Request): Promise<UserContext | null> {
  if (!db || !supabaseUrl || !supabaseKey) return null;
  const authorization = req.header("authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) return null;

  const { data, error } = await db.auth.getUser(token);
  if (error || !data.user) return null;

  const client = createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false }
  });
  const { data: roleRows, error: roleError } = await client
    .from("user_roles")
    .select("role")
    .eq("user_id", data.user.id);
  if (roleError) return null;

  return {
    userId: data.user.id,
    email: data.user.email,
    roles: (roleRows ?? []).map((row) => String(row.role)),
    client
  };
}

function unavailable(res: express.Response) {
  return res.status(503).json({ error: "Database is not configured" });
}

async function authenticated(req: Request, res: express.Response) {
  const context = await getUserContext(req);
  if (!context) {
    res.status(401).json({ error: "A valid signed-in session is required" });
    return null;
  }
  return context;
}

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "zeekdrop-api", databaseConfigured: Boolean(db) });
});

app.get("/v1/series", async (req, res) => {
  if (!db) return unavailable(res);
  const querySchema = z.object({
    q: z.string().trim().max(80).optional(),
    genre: z.string().trim().max(40).optional()
  });
  const parsed = querySchema.safeParse(req.query);
  if (!parsed.success) return res.status(400).json({ error: "Invalid query" });

  let query = db.from("series")
    .select("id,title,synopsis,poster_url,banner_url,genres,language_code,age_rating,published_at")
    .eq("status", "published")
    .order("published_at", { ascending: false })
    .limit(30);

  if (parsed.data.q) query = query.ilike("title", `%${parsed.data.q.replace(/[%_]/g, "")}%`);
  if (parsed.data.genre) query = query.contains("genres", [parsed.data.genre]);

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: "Catalogue request failed" });
  return res.json({ items: data ?? [] });
});

app.get("/v1/series/:seriesId/episodes", async (req, res) => {
  if (!db) return unavailable(res);
  const id = z.string().uuid().safeParse(req.params.seriesId);
  if (!id.success) return res.status(400).json({ error: "Invalid series id" });

  const { data, error } = await db.from("episodes")
    .select("id,series_id,episode_number,title,synopsis,duration_seconds,thumbnail_url")
    .eq("series_id", id.data)
    .eq("status", "published")
    .order("episode_number");
  if (error) return res.status(500).json({ error: "Episode request failed" });
  return res.json({ items: data ?? [] });
});

app.get("/v1/me", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const { data: profile, error } = await user.client
    .from("profiles")
    .select("display_name,avatar_url,created_at")
    .eq("id", user.userId)
    .maybeSingle();
  if (error) return res.status(500).json({ error: "Profile request failed" });
  return res.json({ id: user.userId, email: user.email, roles: user.roles, profile });
});

app.get("/v1/watchlist", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const { data, error } = await user.client.from("watchlist")
    .select("series_id,created_at,series(id,title,poster_url,genres,language_code,age_rating)")
    .eq("user_id", user.userId)
    .order("created_at", { ascending: false });
  if (error) return res.status(500).json({ error: "Watchlist request failed" });
  return res.json({ items: data ?? [] });
});

app.post("/v1/watchlist", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const parsed = z.object({ seriesId: z.string().uuid() }).safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: "A valid seriesId is required" });
  const { error } = await user.client.from("watchlist").upsert(
    { user_id: user.userId, series_id: parsed.data.seriesId },
    { onConflict: "user_id,series_id", ignoreDuplicates: true }
  );
  if (error) return res.status(500).json({ error: "Could not update watchlist" });
  return res.status(204).end();
});

app.delete("/v1/watchlist/:seriesId", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const id = z.string().uuid().safeParse(req.params.seriesId);
  if (!id.success) return res.status(400).json({ error: "Invalid series id" });
  const { error } = await user.client.from("watchlist")
    .delete()
    .eq("user_id", user.userId)
    .eq("series_id", id.data);
  if (error) return res.status(500).json({ error: "Could not remove from watchlist" });
  return res.status(204).end();
});

app.get("/v1/progress", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const { data, error } = await user.client.from("watch_progress")
    .select("episode_id,position_seconds,completed_at,updated_at")
    .eq("user_id", user.userId)
    .order("updated_at", { ascending: false })
    .limit(100);
  if (error) return res.status(500).json({ error: "Watch progress request failed" });
  return res.json({ items: data ?? [] });
});

app.put("/v1/progress/:episodeId", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const id = z.string().uuid().safeParse(req.params.episodeId);
  const body = z.object({
    positionSeconds: z.number().int().min(0).max(86400),
    completed: z.boolean().default(false)
  }).safeParse(req.body);
  if (!id.success || !body.success) {
    return res.status(400).json({ error: "Invalid episode id or progress values" });
  }
  const { data: episode, error: episodeError } = await user.client.from("episodes")
    .select("id")
    .eq("id", id.data)
    .eq("status", "published")
    .maybeSingle();
  if (episodeError) return res.status(500).json({ error: "Episode validation failed" });
  if (!episode) return res.status(404).json({ error: "Published episode not found" });

  const { data, error } = await user.client.from("watch_progress").upsert({
    user_id: user.userId,
    episode_id: id.data,
    position_seconds: body.data.positionSeconds,
    completed_at: body.data.completed ? new Date().toISOString() : null,
    updated_at: new Date().toISOString()
  }, { onConflict: "user_id,episode_id" })
    .select("episode_id,position_seconds,completed_at,updated_at")
    .single();
  if (error) return res.status(500).json({ error: "Could not save watch progress" });
  return res.json({ progress: data });
});

app.post("/v1/reports", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const parsed = z.object({
    seriesId: z.string().uuid().optional(),
    episodeId: z.string().uuid().optional(),
    reason: z.string().trim().min(3).max(80),
    details: z.string().trim().max(2000).default("")
  }).refine((value) => Boolean(value.seriesId) !== Boolean(value.episodeId)).safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: "Provide exactly one valid seriesId or episodeId and a reason" });
  }
  const { data, error } = await user.client.from("content_reports").insert({
    reporter_id: user.userId,
    series_id: parsed.data.seriesId ?? null,
    episode_id: parsed.data.episodeId ?? null,
    reason: parsed.data.reason,
    details: parsed.data.details
  }).select("id,status,created_at").single();
  if (error) return res.status(500).json({ error: "Could not submit report" });
  return res.status(201).json({ report: data });
});


app.get("/v1/subscription-plans", async (_req, res) => {
  if (!db) return unavailable(res);
  const { data, error } = await db.from("subscription_plans")
    .select("id,name,amount_paise,currency,billing_interval,interval_count,benefits")
    .eq("is_active", true)
    .order("display_order");
  if (error) return res.status(500).json({ error: "Subscription plans are not available" });
  return res.json({ currency: "INR", items: data ?? [] });
});

app.get("/v1/me/subscription", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const { data, error } = await user.client.from("subscriptions")
    .select("id,plan_id,status,currency,amount_paise,current_period_start,current_period_end,cancel_at_period_end,cancelled_at,created_at")
    .eq("user_id", user.userId)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) return res.status(500).json({ error: "Subscription status request failed" });
  return res.json({ subscription: data, active: Boolean(data?.status === "active" && (!data.current_period_end || new Date(data.current_period_end).getTime() > Date.now())) });
});

app.get("/v1/me/subscription/payments", async (req, res) => {
  if (!db) return unavailable(res);
  const user = await authenticated(req, res);
  if (!user) return;
  const { data, error } = await user.client.from("subscription_payments")
    .select("id,subscription_id,amount_paise,currency,status,receipt_reference,paid_at,created_at")
    .eq("user_id", user.userId)
    .order("created_at", { ascending: false })
    .limit(50);
  if (error) return res.status(500).json({ error: "Payment history request failed" });
  return res.json({ currency: "INR", items: data ?? [] });
});

app.use((_req, res) => res.status(404).json({ error: "Not found" }));
app.listen(port, () => {
  console.log(`ZeekDrop API listening on ${port}`);
});
