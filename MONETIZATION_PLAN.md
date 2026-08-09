# MyChainLink Monetization Plan
## For Kendal — Simple Version

---

## HOW MONEY FLOWS (The Simple Version)

```
FAN wants to pay CREATOR $10

FAN pays:           $11.50 total
├─ CREATOR gets:    $10.00  (85%)
├─ PLATFORM gets:   $1.50   (15% — this is YOU, Kendal)
└─ PayPal takes:    ~$0.59  (PayPal's fee, taken from the $11.50)

You collect: $1.50 per transaction
Creator gets: $10.00
```

**Your job:** Invoice creators monthly for the 15% fee, OR have fans pay YOU first and you send creators their share.

---

## PAYMENT OPTIONS FOR FANS

| Method | Needs PayPal Account? | How It Works |
|--------|----------------------|--------------|
| PayPal Balance | Yes | Fan logs into PayPal, pays with their balance |
| Credit/Debit Card | NO | PayPal shows a "Pay with Card" button. Fan enters card info directly. No PayPal account needed! |
| Apple Pay / Google Pay | Maybe | PayPal handles these automatically if available |

**Bottom line:** Fans DO NOT need a PayPal account. They can pay with any credit/debit card.

---

## REVENUE SPLIT OPTIONS

### Option A: Fan Pays Creator Directly (EASIEST — What we built)
- Fan enters their card on YOUR site
- Money goes STRAIGHT to creator's PayPal
- You invoice the creator monthly for 15%
- **Pros:** No money passes through your hands, less legal headache
- **Cons:** You have to trust creators to pay their invoice

### Option B: Fan Pays You, You Pay Creators (MORE CONTROL)
- Fan pays YOUR PayPal business account
- You keep 15%
- You send 85% to creators via PayPal
- **Pros:** You control the money, guaranteed income
- **Cons:** You need a business PayPal, more accounting work, possible tax implications

### Option C: PayPal Marketplace (PROFESSIONAL — Needs Approval)
- PayPal automatically splits the money
- Fan pays once, PayPal sends creator 85% and you 15%
- **Pros:** Fully automated, looks professional
- **Cons:** Need PayPal Partner approval, takes weeks/months

**RECOMMENDATION: Start with Option A.** It's live today. You can switch to Option B or C later.

---

## WHAT YOU NEED TO DO RIGHT NOW

| Step | What To Do | How Long |
|------|-----------|----------|
| 1 | Create a PayPal Business account (if you don't have one) | 10 minutes |
| 2 | Go to developer.paypal.com → Create App → Copy Client ID | 5 minutes |
| 3 | Replace `client-id=sb` in the code with your REAL Client ID | 2 minutes |
| 4 | Run the `transactions_table.sql` in Supabase | 2 minutes |
| 5 | Test with a small $1 payment to yourself | 5 minutes |

---

## HOW MUCH YOU'LL MAKE

| Monthly Creators | Avg Fan Payment | Your 15% Cut | Monthly Income |
|-----------------|----------------|-------------|---------------|
| 10 | $10 | $1.50 each | $15 |
| 50 | $10 | $1.50 each | $75 |
| 100 | $10 | $1.50 each | $150 |
| 500 | $10 | $1.50 each | $750 |
| 1,000 | $10 | $1.50 each | $1,500 |

**If creators charge more or get more fans, you scale automatically.**

---

## PREMIUM vs CREATOR INCOME (Two Different Things)

### Premium Subscriptions ($4.99/month)
- Fan pays to unlock features (live streaming, profile songs, colors, media)
- THIS money goes to YOU (the platform)
- Creators don't get this money

### Creator Tips/Support (Custom amounts)
- Fan pays a creator directly
- 85% to creator, 15% to you
- THIS is the revenue split we built

**You make money from BOTH.**

---

## WHAT'S ALREADY BUILT

✅ PayPal button with custom amounts
✅ 15% / 85% split calculation
✅ Fee breakdown shown to fan before payment
✅ Transaction recording in database
✅ Premium gating (songs, colors, live, media)

## WHAT'S NOT BUILT YET

❌ Real PayPal Client ID (still sandbox)
❌ Automatic payouts to creators (manual for now)
❌ Subscription billing (one-time payments only)
❌ Tax forms / 1099 handling

---

## QUESTIONS & ANSWERS

**Q: Do fans need PayPal?**
A: NO. PayPal handles credit cards directly. Fans see a "Pay with Debit or Credit Card" button.

**Q: How do I get my 15%?**
A: For now, invoice creators monthly OR switch to Option B where fans pay you first.

**Q: Can I change the percentage?**
A: YES. Change `PLATFORM_FEE_PERCENT = 15` to whatever you want. Just edit one number.

**Q: What currency?**
A: CAD (Canadian dollars) right now. Can add USD later.

**Q: Is this legal?**
A: You should talk to an accountant about taxes. You're earning income, so you need to report it.

---

**Last Updated:** August 9, 2026
**Built by:** Mr Chomp 🔥
