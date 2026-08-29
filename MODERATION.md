# Content Moderation & Report System — What's New

## 1. Automatic Content Moderation (PayPal-safe)

### Two-Layer Defense

**Layer 1 — Client-Side Image Scanner (always on)**
- Runs entirely in the browser. No API key needed. No external calls.
- Draws every image to a hidden canvas, samples pixels across the image
- Detects skin-tone colors using HSL heuristics (human skin detection)
- If >35% of sampled pixels are skin-toned AND enough pixels qualify, the image is **blocked before it goes live**
- Catches obvious nudity/porn without any external dependency

**Layer 2 — Google Cloud Vision SafeSearch (optional, your call)**
- Placeholder function `scanImageWithVisionAPI()` is wired and ready
- You just need to add your API key and it automatically gets used as a stronger check
- To enable: get a Google Cloud Vision API key → call `setVisionKey('your-key')` in console, or add it to localStorage as `cl_vision_key`
- Uses Google's trained ML model to classify: `adult`, `violence`, `racy`
- Flags `LIKELY` or `VERY_LIKELY` on adult or racy categories

**Text Filter (always on)**
- Checks post text against a profanity / inappropriate language list
- Blocks posts containing sexual/explicit language before publishing
- Covers: nude, porn, sexual content terms, slurs, harassment language

### Where checks happen
1. **Creating a post** (`postCam`) — text checked first, then image checked if photo (not video)
2. **Taking a profile photo** (`snapProfilePhoto`) — image scanned before saving
3. **Cropping a photo** (`applyCrop`) — cropped image scanned before applying

If anything is flagged, the user sees: `⚠️ Image blocked: [reason]` and the content never goes live.

---

## 2. Report System

### Report Button on Every Post
- Every post you DON'T own now has a `⋯` menu button (three dots)
- Click it → `🚩 Report` option appears in red
- Opens a report modal with reason dropdown:
  - Nudity / Sexual content
  - Harassment / Bullying
  - Hate speech
  - Spam
  - Impersonation
  - Violence
  - Other
- Optional details text field

### Report Button on Every Profile
- On every profile view (next to Block button): `🚩 Report` in orange
- Same modal, pre-filled with the profile being reported

### Where reports go
- **LocalStorage** first: `cl_reports` array stores all reports locally
- **Supabase sync**: if online, reports are also inserted into the `reports` table
- Report object includes: reporter_id, target_id, target_type ('post'|'profile'), reason, details, timestamp, status ('open')

### Functions you can call in console
```js
setVisionKey('your-google-vision-api-key')  // enable stronger image scanning
```

---

## 3. Google Vision Setup (when you're ready)

1. Go to https://console.cloud.google.com/
2. Create a project → enable **Cloud Vision API**
3. Create an API key (restrict it to Vision API only for security)
4. In your app, open browser console and run: `setVisionKey('YOUR_KEY')`
5. Done — all image uploads now get double-checked by Google's model

---

## Files Changed
- `index.html` — all moderation + report logic added inline

## GitHub
- Committed and pushed to `main` branch
- Clean working tree
