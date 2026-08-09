# PayPal Testing Guide — Step by Step

## BEFORE YOU TEST

### Step 1: Run the SQL in Supabase
1. Go to https://supabase.com → Your project → SQL Editor
2. Copy and paste everything from `transactions_table.sql`
3. Click "Run"
4. You should see "Success" or "0 rows affected" — that's fine

### Step 2: Set Up a Creator Account with PayPal
1. Log into MyChainLink with any account
2. Go to Profile → Settings (gear icon)
3. Find "Connect PayPal" or "Payment Settings"
4. Enter your PayPal Business email (the one you use at paypal.com)
5. Save it

---

## THE TEST

### Step 3: Create Two Accounts
You need TWO accounts to test:
- **Account A:** The CREATOR (receives money)
- **Account B:** The FAN (pays money)

If you only have one account:
1. Log out
2. Sign up with a different email (use a + alias like kendal+fan@gmail.com)
3. Verify it

### Step 4: Set Up the Creator
1. Log in as Account A (creator)
2. Go to Profile → Settings
3. Enter your PayPal email
4. Save

### Step 5: The Fan Pays
1. Log in as Account B (fan)
2. Find Account A's profile (search or follow them)
3. Click "View Profile"
4. Click the support/tip button
5. Enter an amount (start with **$1.00**)
6. Click the PayPal button
7. A PayPal popup appears
8. Choose "Pay with Debit or Credit Card"
9. Enter a REAL card number
10. Complete the payment

### Step 6: Verify
1. Check Account A's PayPal account → You should see $0.85 (after your 15% cut and PayPal's fee)
2. Check Account B's bank statement → You should see $1.00 charged
3. Check Supabase → Table `transactions` should show the record

---

## IF SOMETHING GOES WRONG

### "PayPal failed to load"
- Check your browser console (F12 → Console tab)
- Make sure the Client ID is correct in the code

### "This creator has not set up PayPal yet"
- The creator needs to go to Profile → Settings → Enter PayPal email

### Payment goes through but no record in Supabase
- Make sure you ran the SQL to create the `transactions` table
- Check browser console for errors

### "Payment failed"
- Make sure you're using a real card
- PayPal sometimes blocks test cards on live accounts
- Try a different card

---

## WHAT TO EXPECT

| Amount | Fan Pays | Creator Gets (85%) | Your Cut (15%) | PayPal Fee |
|--------|----------|-------------------|----------------|------------|
| $1.00 | $1.00 | ~$0.62 | ~$0.11 | ~$0.27 |
| $5.00 | $5.00 | ~$3.92 | ~$0.69 | ~$0.39 |
| $10.00 | $10.00 | ~$8.11 | ~$1.43 | ~$0.46 |
| $20.00 | $20.00 | ~$16.41 | ~$2.90 | ~$0.69 |

**Note:** PayPal's fee varies. These are estimates. The exact fee shows during checkout.

---

## AFTER THE TEST WORKS

1. Tell creators to add their PayPal email in settings
2. Tell fans they can pay with ANY credit/debit card (no PayPal account needed)
3. Your money comes from invoicing creators monthly for their 15%
4. Or switch to backend-controlled payouts later

---

Good luck! 🔥
