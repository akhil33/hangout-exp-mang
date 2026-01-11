# Fix: Clear Service Worker Cache

## Problem Solved
The Service Worker was caching API requests to Supabase, causing stale data to be served instead of fresh data from the database.

## What Was Fixed
Updated [sw.js](sw.js) to:
1. Never cache Supabase API requests (lines 85-94)
2. Updated cache version from v1 to v2 (line 4-6)
3. All API calls now bypass cache and fetch fresh data

## How to Apply the Fix

### Method 1: Automatic Update (Recommended)
1. **Close all tabs** with the app open
2. **Wait 30 seconds**
3. **Reopen the app**
4. Service Worker should auto-update

### Method 2: Force Update (Instant)
1. Open the app
2. **Open DevTools** (F12 or Cmd+Option+I)
3. Go to **Application** tab
4. Click **Service Workers** in the left sidebar
5. Check **"Update on reload"**
6. Click **"Unregister"** next to the service worker
7. **Hard refresh** (Cmd+Shift+R or Ctrl+Shift+F5)

### Method 3: Manual Cache Clear
1. Open DevTools (F12)
2. Go to **Application** tab
3. Click **Storage** in the left sidebar
4. Click **"Clear site data"**
5. Check all boxes
6. Click **"Clear site data"**
7. Refresh the page

## Verification

After clearing the cache, check the console. You should see:

**Before (cached):**
```
[ServiceWorker] Serving from cache: https://ygimmhtjlzdmpiggynxl.supabase.co/rest/v1/expenses...
```

**After (fresh):**
```
[ServiceWorker] Bypassing cache for API request: https://ygimmhtjlzdmpiggynxl.supabase.co/rest/v1/expenses...
```

And the data should now show all 8 expenses:
```
✅ Successfully fetched 8 expenses from database
📊 Expense IDs: [1, 3, 4, 5, 6, 7, 8, 9]
```

## Technical Details

### What Was Caching API Requests?

**Before (sw.js lines 86-92):**
```javascript
caches.match(request).then((cachedResponse) => {
  if (cachedResponse) {
    return cachedResponse;  // Returns cached API response
  }
  // ...fetch from network
});
```

**After (sw.js lines 85-94):**
```javascript
// Skip caching for API requests
if (request.url.includes('/rest/v1/') ||
    request.url.includes('/auth/v1/') ||
    request.url.includes('supabase.co')) {
  return fetch(request);  // Always fetch fresh
}
```

### Why This Happened

1. Service Worker cached the first API response (6 expenses)
2. Subsequent requests returned the cached data
3. New expenses (7, 8, 9) were in the database but not in the cache
4. App showed stale data from cache

### What's Fixed Now

- ✅ API requests are never cached
- ✅ All data is fetched fresh from Supabase
- ✅ Service Worker only caches static assets (HTML, CSS, JS, fonts)
- ✅ Real-time updates work properly

## Prevention

The Service Worker now intelligently caches:

**✅ Cached (for offline support):**
- HTML files
- CSS/JavaScript files
- Fonts
- Images
- CDN libraries (React, Chart.js)

**❌ Never Cached (always fresh):**
- Supabase API requests (`/rest/v1/`)
- Authentication requests (`/auth/v1/`)
- Any Supabase URLs

## Troubleshooting

### If you still see cached data:

**1. Check Service Worker version:**
```javascript
// In console:
navigator.serviceWorker.getRegistrations().then(registrations => {
  console.log('Active registrations:', registrations);
});
```

**2. Force unregister:**
```javascript
// In console:
navigator.serviceWorker.getRegistrations().then(registrations => {
  registrations.forEach(reg => reg.unregister());
  location.reload();
});
```

**3. Clear all caches manually:**
```javascript
// In console:
caches.keys().then(keys => {
  keys.forEach(key => caches.delete(key));
  location.reload();
});
```

### If Service Worker won't update:

1. Open DevTools → Application → Service Workers
2. Check "Update on reload"
3. Click "Skip waiting" if button appears
4. Hard refresh multiple times

## Future Improvements

Consider implementing:
- [ ] Cache invalidation strategy
- [ ] Cache-Control headers from API
- [ ] ETag support for conditional requests
- [ ] Offline queue for POST/PUT/DELETE
- [ ] Network-first strategy for real-time data
