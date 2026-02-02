# Supabase Backend Setup Guide 🚀

To connect your Chess App to a real backend, you need to set up a free Supabase project. This will allow:
- ✅ User Sign Up & Sign In
- ✅ Progress Cloud Sync
- ✅ Settings Backup

## Step 1: Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Click **"Start your project"** (Login with GitHub)
3. Create a new project:
   - **Name**: Chess Master
   - **Database Password**: (Generate a strong one and save it)
   - **Region**: Choose one close to you

## Step 2: Get API Keys
1. Once your project is created (takes ~1 minute), go to **Project Settings** (Cog icon ⚙️).
2. Go to **API**.
3. Copy **Project URL**.
4. Copy **anon public** Key.

## Step 3: Update Code
Open `lib/services/supabase_service.dart` in your code editor and update these lines:

```dart
static const String supabaseUrl = 'PASTE_YOUR_PROJECT_URL_HERE';
static const String supabaseAnonKey = 'PASTE_YOUR_ANON_KEY_HERE';
```

## Step 4: Create Database Table
You need a table to store user progress.
1. Go to the **SQL Editor** tab in Supabase (on the left sidebar).
2. Click **"New Query"**.
3. Paste the following SQL code and click **Run**:

```sql
-- Create a table for user profiles
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  completed_stage int default 1,
  sound_enabled boolean default true,
  dark_mode boolean default false,
  last_login timestamp with time zone,
  avatar_url text
);

-- Set up Row Level Security (RLS)
-- This ensures users can only edit their OWN data
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile."
  on profiles for update
  using ( auth.uid() = id );
```

## Step 5: Test It!
1. Restart your app.
2. Click **Sign Up**.
3. Create an account.
4. Play a game and complete a stage.
5. Your progress is now saved to the cloud! ☁️

---

## Troubleshooting
- **Box has grey screen?** Check if you updated the keys in `supabase_service.dart` correctly.
- **Sign Up fails?** Check if "Email Auth" is enabled in Supabase Authentication > Providers (it is on by default).
