import express from "express";
import cors from "cors";
import helmet from "helmet";
import { createClient } from "@supabase/supabase-js";
import { z } from "zod";

const app = express();
app.disable("x-powered-by");
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN?.split(",") ?? false }));
app.use(express.json({ limit: "64kb" }));

const port = Number(process.env.PORT ?? 8080);
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_PUBLISHABLE_KEY;

const db = supabaseUrl && supabaseKey
  ? createClient(supabaseUrl, supabaseKey, { auth: { persistSession: false, autoRefreshToken: false } })
  : null;

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "zeekdrop-api", databaseConfigured: Boolean(db) });
});

app.get("/v1/series", async (req, res) => {
  if (!db) return res.status(503).json({ error: "Database is not configured" });
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
  if (!db) return res.status(503).json({ error: "Database is not configured" });
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

app.use((_req, res) => res.status(404).json({ error: "Not found" }));
app.listen(port, () => {
  console.log(`ZeekDrop API listening on ${port}`);
});
