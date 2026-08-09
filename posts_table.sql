-- Run this in your Supabase SQL Editor
-- Creates the posts table with proper columns and RLS policies

-- Drop existing posts table if schema is wrong (it's empty anyway)
DROP TABLE IF EXISTS posts CASCADE;

-- Create posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  display_name TEXT,
  handle TEXT,
  avatar_url TEXT,
  text TEXT NOT NULL,
  font_class TEXT DEFAULT 'font-inter',
  text_color TEXT DEFAULT '#DEDAD2',
  media_url TEXT,
  is_video BOOLEAN DEFAULT FALSE,
  location TEXT,
  tags TEXT,
  comments_enabled BOOLEAN DEFAULT TRUE,
  subscribers_only BOOLEAN DEFAULT FALSE,
  likes UUID[] DEFAULT '{}',
  dislikes UUID[] DEFAULT '{}',
  comments JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read all posts (public feed)
CREATE POLICY "Anyone can read posts"
  ON posts FOR SELECT
  USING (true);

-- Allow authenticated users to insert their own posts
CREATE POLICY "Users can create own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own posts
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

-- Allow users to delete their own posts
CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);

-- Create index for fast feed loading
CREATE INDEX idx_posts_created_at ON posts (created_at DESC);
CREATE INDEX idx_posts_user_id ON posts (user_id);
