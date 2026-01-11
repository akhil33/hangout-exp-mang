# How to Fix: Expenses Not Showing in App

## Problem
You have 2 expenses in the database, but they're not appearing in the app. This is caused by **Row Level Security (RLS) policies** blocking the SELECT queries.

## Solution

### Step 1: Run the Fix SQL Script
1. Open your Supabase dashboard
2. Navigate to **SQL Editor**
3. Open the file `FIX-EXPENSES-NOT-SHOWING.sql`
4. Copy the entire contents
5. Paste into the Supabase SQL Editor
6. Click **Run** (or press Cmd/Ctrl + Enter)

### Step 2: Verify the Fix
After running the script, you should see output confirming:
- ✓ RLS is enabled on expenses table
- ✓ 4 new policies created (select, insert, update, delete)
- ✓ Total count of expenses in database

### Step 3: Refresh Your App
1. Open your app in the browser
2. Open the browser console (F12 or Cmd+Option+I)
3. Refresh the page
4. Look for these console messages:
   - 🔍 "Fetching expenses from Supabase..."
   - ✅ "Successfully fetched X expenses from database"
   - 📊 "Mapped expenses: [...]"

## What Changed?

### Before
- RLS was enabled but policies were either missing or too restrictive
- The app could authenticate but couldn't read expenses

### After
- Created 4 clear policies:
  - **SELECT**: Allows authenticated users to read all expenses
  - **INSERT**: Allows authenticated users to add expenses
  - **UPDATE**: Allows authenticated users to update expenses (for approvals)
  - **DELETE**: Allows authenticated users to delete expenses

## Troubleshooting

### If expenses still don't show:

#### Check 1: Browser Console
Open browser console and look for error messages. You should see:
```
🔍 Fetching expenses from Supabase...
✅ Successfully fetched 2 expenses from database
```

#### Check 2: Run Diagnostic Script
1. Open `DIAGNOSE-EXPENSES.sql`
2. Run it in Supabase SQL Editor
3. Check the output for each step

#### Check 3: Verify Authentication
Make sure you're logged in as a user. The console should show your user info.

#### Check 4: Check Database Directly
In Supabase:
1. Go to **Table Editor**
2. Open the `expenses` table
3. Verify data is there
4. Check the `user_id` values

## Prevention

### For Future Development
The current policies allow all authenticated users to perform all operations. This is fine for development, but for production you may want to:

1. **Restrict INSERT/UPDATE** to only managers:
   ```sql
   CREATE POLICY "Only managers can insert"
   ON expenses FOR INSERT
   TO authenticated
   WITH CHECK (
     EXISTS (
       SELECT 1 FROM user_roles
       WHERE user_id = auth.uid()
       AND role = 'manager'
     )
   );
   ```

2. **User-specific expenses** (if you want users to only see their own):
   ```sql
   CREATE POLICY "Users see own expenses"
   ON expenses FOR SELECT
   TO authenticated
   USING (user_id = auth.uid());
   ```

## Files Reference
- `FIX-EXPENSES-NOT-SHOWING.sql` - The main fix script
- `DIAGNOSE-EXPENSES.sql` - Diagnostic queries
- `index.html` - Updated with console logging for debugging

## Still Having Issues?
Check the browser console for specific error messages and share them for further troubleshooting.
