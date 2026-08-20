# My Chain Link

**Get connected. Stay connected.**

A social platform built for real people. No filters. No gallery uploads. Camera captures only. Your content, your price.

🔗 [mychainlink.ca](https://mychainlink.ca)

---

## What Is It?

My Chain Link is a creator-first social network where authenticity is the default:

- **Camera-only posts** — No filtered uploads. Real moments only.
- **Direct messaging** — Free for everyone. Connect and chat.
- **Premium creator tools** — Lock your content, set your price, keep 100% of earnings.
- **Live streaming** — Go live to your connections in real time.
- **Video chat** — Encrypted one-on-one calls.

## Premium Features

| Feature | Free | Premium |
|---|---|---|
| Post to feed | ✅ | ✅ |
| Direct messaging | ✅ | ✅ |
| Search & connect | ✅ | ✅ |
| Lock content / set price | — | ✅ |
| Premium badge | — | ✅ |
| Video chat | — | ✅ |
| Camera-only DMs | — | ✅ |
| Go Live | — | ✅ |
| Custom themes | — | ✅ |

**Pricing:** CAD $10.99/month or CAD $109.99/year (save 17%). 7-day free trial.

## Tech Stack

| Layer | Tech |
|---|---|
| Frontend | Vanilla HTML/CSS/JS (single SPA file) |
| Backend | Supabase (Auth, Postgres, Realtime, Storage) |
| Payments | PayPal |
| Hosting | GitHub Pages |
| Domain | mychainlink.ca |

## Project Structure

```
mychainlink/
├── index.html          # Main SPA (feed, explore, messages, profile, settings)
├── login.html          # Dedicated login page with saved accounts
├── terms.html          # Terms of Service
├── privacy.html        # Privacy Policy
├── purchase-terms.html # Terms of Purchase (subscriptions)
├── complete_schema.sql # Full Supabase schema
└── logo-v4.png         # Brand logo
```

## Supabase Setup

1. Create project at [supabase.com](https://supabase.com)
2. Run `complete_schema.sql` in the SQL Editor
3. Configure Auth providers (Email, Google, Facebook)
4. Set Site URL and Redirect URLs to `https://mychainlink.ca`
5. Enable Realtime on `messages`, `notifications`, `posts` tables

## Local Development

```bash
cd mychainlink
python3 -m http.server 8080
```

Open http://localhost:8080

## Deployment

Push to the `main` branch. GitHub Pages deploys automatically.

```bash
git add -A
git commit -m "your changes"
git push origin main
```

## Environment Variables (Supabase)

Set these in your Supabase project:

- `SURL` — Supabase project URL
- `SKEY` — Supabase anon key

## Legal

- [Terms of Service](https://mychainlink.ca/terms.html)
- [Privacy Policy](https://mychainlink.ca/privacy.html)
- [Terms of Purchase](https://mychainlink.ca/purchase-terms.html)

## Operator

**Kendal Symes** — British Columbia, Canada  
📧 [Kendalchaincreator@proton.me](mailto:Kendalchaincreator@proton.me)

---

© 2026 Kendal Symes. All rights reserved.
