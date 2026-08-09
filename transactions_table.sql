-- Transactions table for PayPal payments
CREATE TABLE IF NOT EXISTS transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  payer_id UUID REFERENCES auth.users(id),
  creator_id UUID REFERENCES auth.users(id),
  amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  creator_amount DECIMAL(10,2) NOT NULL,
  paypal_order_id TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own transactions"
  ON transactions FOR SELECT
  USING (payer_id = auth.uid() OR creator_id = auth.uid());

CREATE POLICY "Users can create transactions"
  ON transactions FOR INSERT
  WITH CHECK (payer_id = auth.uid());
