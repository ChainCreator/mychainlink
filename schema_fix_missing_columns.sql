-- ============================================================
-- MYCHAINLINK — SCHEMA FIX for missing columns
-- Run this in Supabase SQL Editor (all at once)
-- ============================================================

-- ============================================================
-- 1. PROFILES — add email column (synced from auth.users)
-- ============================================================
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Populate email from auth.users for existing profiles
UPDATE profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND (p.email IS NULL OR p.email = '');

-- Create trigger to keep email in sync
CREATE OR REPLACE FUNCTION sync_profile_email()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles SET email = NEW.email WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS sync_auth_email ON auth.users;
CREATE TRIGGER sync_auth_email
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW EXECUTE FUNCTION sync_profile_email();

-- ============================================================
-- 2. CONVERSATIONS — rename columns + add last_message fields
-- ============================================================

-- Add participant aliases if user1_id/user2_id exist
DO $$
BEGIN
  -- Only rename if old columns exist and new ones don't
  IF EXISTS (SELECT 1 FROM information_schema.columns 
             WHERE table_name = 'conversations' AND column_name = 'user1_id')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                     WHERE table_name = 'conversations' AND column_name = 'participant_1')
  THEN
    ALTER TABLE conversations RENAME COLUMN user1_id TO participant_1;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns 
             WHERE table_name = 'conversations' AND column_name = 'user2_id')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                     WHERE table_name = 'conversations' AND column_name = 'participant_2')
  THEN
    ALTER TABLE conversations RENAME COLUMN user2_id TO participant_2;
  END IF;
END $$;

-- Add missing columns for last message preview
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_text TEXT;
ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ;

-- Create function + trigger to auto-update last_message on new message
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations 
  SET last_message_text = NEW.content,
      last_message_at = NEW.created_at,
      updated_at = NOW()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_last_message ON messages;
CREATE TRIGGER trg_last_message
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();

-- ============================================================
-- 3. FOLLOWS — rename followed_id to following_id
-- ============================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns 
             WHERE table_name = 'follows' AND column_name = 'followed_id')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                     WHERE table_name = 'follows' AND column_name = 'following_id')
  THEN
    ALTER TABLE follows RENAME COLUMN followed_id TO following_id;
  END IF;
END $$;

-- Also add subscribed column if missing (used in frontend)
ALTER TABLE follows ADD COLUMN IF NOT EXISTS subscribed BOOLEAN DEFAULT FALSE;

-- Recreate the unique index on new column names
DROP INDEX IF EXISTS idx_follows_followed;
CREATE UNIQUE INDEX IF NOT EXISTS idx_follows_unique ON follows(follower_id, following_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);

-- Update RLS policy to use new column name
DROP POLICY IF EXISTS "Users can follow" ON follows;
CREATE POLICY "Users can follow" ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);

-- ============================================================
-- 4. TRANSACTIONS — rename user_id to payer_id, add type column
-- ============================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns 
             WHERE table_name = 'transactions' AND column_name = 'user_id')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                     WHERE table_name = 'transactions' AND column_name = 'payer_id')
  THEN
    ALTER TABLE transactions RENAME COLUMN user_id TO payer_id;
  END IF;
END $$;

-- Add type column (used by frontend for premium_subscription checks)
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS type TEXT;

-- ============================================================
-- 5. RLS POLICY FIXES — ensure policies match new column names
-- ============================================================

-- Conversations policies
DROP POLICY IF EXISTS "Users can read their conversations" ON conversations;
CREATE POLICY "Users can read their conversations" ON conversations FOR SELECT 
  USING (auth.uid() = participant_1 OR auth.uid() = participant_2);

DROP POLICY IF EXISTS "Users can create conversations" ON conversations;
CREATE POLICY "Users can create conversations" ON conversations FOR INSERT 
  WITH CHECK (auth.uid() = participant_1 OR auth.uid() = participant_2);

-- Follows read policy
DROP POLICY IF EXISTS "Anyone can read follows" ON follows;
CREATE POLICY "Anyone can read follows" ON follows FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can unfollow" ON follows;
CREATE POLICY "Users can unfollow" ON follows FOR DELETE USING (auth.uid() = follower_id);

-- Transactions policies
DROP POLICY IF EXISTS "Users can read own transactions" ON transactions;
CREATE POLICY "Users can read own transactions" ON transactions FOR SELECT 
  USING (auth.uid() = payer_id OR auth.uid() = creator_id);

-- ============================================================
-- 6. REALTIME FIX — re-add tables with new publication
-- ============================================================
ALTER TABLE conversations REPLICA IDENTITY FULL;
ALTER TABLE follows REPLICA IDENTITY FULL;

-- ============================================================
-- DONE — all columns should match frontend expectations now.
-- ============================================================

-- ============================================================
-- 7. USER_SONGS TABLE (profile music — referenced by frontend)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_songs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT DEFAULT 'Untitled',
  artist TEXT DEFAULT 'Unknown artist',
  song_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

ALTER TABLE user_songs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read user songs" ON user_songs FOR SELECT USING (true);
CREATE POLICY "Users can manage own songs" ON user_songs FOR ALL USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_user_songs_user ON user_songs(user_id);
CREATE INDEX IF NOT EXISTS idx_user_songs_active ON user_songs(user_id, is_active);
