-- ============================================================
-- SUPABASE STORAGE POLICIES — MyChainLink
-- Run this in Supabase SQL Editor (all at once)
-- ============================================================

-- NOTE: Only create buckets that don't already exist.
-- Your current buckets: avatars, media, photos, songs, Private_conversations

-- ============================================================
-- 1. MEDIA BUCKET (posts, public photos/videos)
-- ============================================================

-- Allow anyone to VIEW media files (for the feed)
CREATE POLICY "Public can view media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'media');

-- Allow authenticated users to UPLOAD to media
CREATE POLICY "Authenticated can upload media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'media' AND auth.uid() = owner);

-- Allow users to DELETE their own media
CREATE POLICY "Users can delete own media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'media' AND auth.uid() = owner);

-- ============================================================
-- 2. PHOTOS BUCKET (multi-photo posts)
-- ============================================================

-- Allow anyone to VIEW photos
CREATE POLICY "Public can view photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'photos');

-- Allow authenticated users to UPLOAD to photos
CREATE POLICY "Authenticated can upload photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'photos' AND auth.uid() = owner);

-- Allow users to DELETE their own photos
CREATE POLICY "Users can delete own photos"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'photos' AND auth.uid() = owner);

-- ============================================================
-- 3. AVATARS BUCKET (profile pictures)
-- ============================================================

-- Allow anyone to VIEW avatars (public profiles)
CREATE POLICY "Public can view avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Allow authenticated users to UPLOAD their own avatar
CREATE POLICY "Authenticated can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() = owner);

-- Allow users to UPDATE their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() = owner)
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() = owner);

-- Allow users to DELETE their own avatar
CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);

-- ============================================================
-- 4. SONGS BUCKET (profile songs)
-- ============================================================

-- Allow anyone to VIEW/listen to songs
CREATE POLICY "Public can view songs"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'songs');

-- Allow authenticated users to UPLOAD their own song
CREATE POLICY "Authenticated can upload songs"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'songs' AND auth.uid() = owner);

-- Allow users to DELETE their own song
CREATE POLICY "Users can delete own song"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'songs' AND auth.uid() = owner);

-- ============================================================
-- DONE! Refresh the Storage page to see all policies.
-- ============================================================
