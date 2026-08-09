# PayPal Revenue Split - Implementation Plan

## Current State
- Using PayPal Sandbox (`client-id=sb`)
- Using Hosted Buttons (limited functionality)
- No revenue split logic

## What You Need to Do First

### 1. Get Real PayPal Credentials
1. Go to https://developer.paypal.com
2. Log in with your PayPal business account (create one if needed)
3. Create a new app → get your **Client ID**
4. Replace `client-id=sb` with your real Client ID

### 2. Choose Your Revenue Model

**Option A: Platform Fee Added to Price**
- Fan pays: $10 + platform fee
- Creator gets: $10
- Platform gets: the fee
- **Simplest to implement**

**Option B: PayPal Marketplace (Recommended)**
- Fan pays: $10
- PayPal splits: Creator gets 85%, Platform gets 15%
- **Requires PayPal Partner approval**
- **More complex but professional**

**Option C: Platform Collects, Then Pays Out**
- Fan pays Platform
- Platform keeps fee
- Platform sends creator their share via PayPal Payouts
- **Requires server/backend**

## Recommended: Option A (Immediate Implementation)

### Revenue Split Configuration
```javascript
const PLATFORM_FEE_PERCENT = 15;  // You keep 15%
const CREATOR_PERCENT = 85;       // Creator gets 85%

// Example: Fan wants to pay $10 to creator
const creatorAmount = 10.00;
const platformFee = creatorAmount * (PLATFORM_FEE_PERCENT / 100);
const totalCharge = creatorAmount + platformFee;
// Fan pays: $11.50
// Creator gets: $10.00
// Platform gets: $1.50
```

### PayPal Button Configuration
```javascript
paypal.Buttons({
  createOrder: function(data, actions) {
    return actions.order.create({
      purchase_units: [{
        amount: {
          value: totalCharge.toFixed(2),
          breakdown: {
            item_total: { value: creatorAmount.toFixed(2), currency_code: 'CAD' },
            handling: { value: platformFee.toFixed(2), currency_code: 'CAD' }
          }
        },
        payee: {
          email_address: creatorPayPalEmail  // Creator's PayPal
        }
      }]
    });
  },
  onApprove: function(data, actions) {
    return actions.order.capture().then(function(details) {
      // Payment successful - update database
      showToast('Payment successful!');
    });
  }
}).render('#paypal-button-container');
```

## Implementation Steps

1. **Replace sandbox Client ID** in index.html
2. **Add fee calculation logic** to the payment flow
3. **Update the checkout modal** to show fee breakdown
4. **Store transactions** in Supabase for records

## Database Schema Needed

```sql
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
```

## Notes
- PayPal takes their own fee (~2.9% + $0.30) from the TOTAL
- The creator's PayPal must be a Business account to receive payments
- You need to handle currency conversion if fans pay in different currencies
