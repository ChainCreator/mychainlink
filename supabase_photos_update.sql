-- ============================================================
-- SUPABASE SCHEMA UPDATE: Multi-Photo Support
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. Add photos column to posts table (stores array of photo data URLs)
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS photos JSONB DEFAULT NULL;

-- 2. Add index for faster queries on photos (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_posts_photos ON posts USING GIN (photos);

-- 3. Update RLS policy if needed - ensure authenticated users can insert photos
-- (This assumes you already have insert policies for the posts table)
-- If not, run:
-- CREATE POLICY "Users can insert posts" ON posts FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- 4. Verify the column was added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'posts' AND column_name = 'photos';
