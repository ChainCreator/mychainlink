-- Add pending_balance to profiles for creator payouts
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pending_balance DECIMAL(10,2) DEFAULT 0;
