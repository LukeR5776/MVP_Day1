# Day1 — Supabase Backend Setup & Test Procedure

## Overview

The app uses Supabase for:
- **User accounts** — sign-up at end of onboarding, login for returning users
- **Profiles** — stores onboarding answers (name, goal, habit categories, frequency, time of day)
- **Habits** — persisted and loaded from the cloud so they survive app restarts
- **XP / progress** — levels, streaks, achievements synced to cloud
- **Vlog metadata** — date, habit, duration (video files stay on device)

---

## Step 1: Create the Supabase Project

1. Go to [supabase.com](https://supabase.com) → New project
2. Name it `Day1` (or similar), choose a region close to your users
3. Wait for the project to spin up (~1 min)

---

## Step 2: Run the Database Schema

Open **SQL Editor** in your Supabase dashboard and run the full DDL block below.
Run it as one statement (it's safe to re-run).

```sql
-- ── PROFILES ────────────────────────────────────────────────────────────────
create table public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  name          text not null default '',
  goal          text,
  preferred_habit_categories  text[] default '{}',
  frequency     text,
  time_of_day   text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

alter table public.profiles enable row level security;
create policy "Users can view own profile"   on public.profiles for select using (auth.uid() = id);
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Auto-create blank profile row when a new auth user is created
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── HABITS ──────────────────────────────────────────────────────────────────
create table public.habits (
  id                    text primary key,
  user_id               uuid not null references auth.users(id) on delete cascade,
  name                  text not null,
  description           text,
  category              text not null,
  frequency             text not null,
  notifications_enabled boolean not null default true,
  reminder_hour         int,
  reminder_minute       int,
  current_streak        int not null default 0,
  best_streak           int not null default 0,
  total_days_completed  int not null default 0,
  current_day_number    int not null default 1,
  created_at            timestamptz not null,
  archived_at           timestamptz,
  updated_at            timestamptz not null default now()
);

create index if not exists habits_user_id_idx on public.habits(user_id);
alter table public.habits enable row level security;
create policy "Users CRUD own habits" on public.habits
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── USER PROGRESS ────────────────────────────────────────────────────────────
create table public.user_progress (
  user_id                   uuid primary key references auth.users(id) on delete cascade,
  total_xp                  int not null default 0,
  total_vlogs_created       int not null default 0,
  total_vlogs_shared        int not null default 0,
  total_recording_seconds   int not null default 0,
  unlocked_achievement_ids  text[] not null default '{}',
  updated_at                timestamptz not null default now()
);

alter table public.user_progress enable row level security;
create policy "Users CRUD own progress" on public.user_progress
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── DAILY LOGS ───────────────────────────────────────────────────────────────
create table public.daily_logs (
  id              text primary key,
  user_id         uuid not null references auth.users(id) on delete cascade,
  habit_id        text not null references public.habits(id) on delete cascade,
  date            date not null,
  day_number      int not null,
  status          text not null default 'notStarted',
  completed_at    timestamptz,
  xp_earned       int not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists daily_logs_user_id_idx on public.daily_logs(user_id);
alter table public.daily_logs enable row level security;
create policy "Users CRUD own daily logs" on public.daily_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── VLOGS ────────────────────────────────────────────────────────────────────
create table public.vlogs (
  id                  uuid primary key,
  user_id             uuid not null references auth.users(id) on delete cascade,
  habit_id            text not null references public.habits(id) on delete cascade,
  daily_log_id        text references public.daily_logs(id) on delete set null,
  habit_name          text not null,
  day_number          int not null,
  date                date not null,
  duration_seconds    int not null default 0,
  file_size_bytes     int not null default 0,
  is_shared           boolean not null default false,
  shared_at           timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists vlogs_user_id_idx on public.vlogs(user_id);
alter table public.vlogs enable row level security;
create policy "Users CRUD own vlogs" on public.vlogs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

---

## Step 3: Auth Settings

In **Authentication → Settings**:
- **Disable** "Enable email confirmations" (for dev/MVP — users log in immediately after sign-up)
- Site URL: leave as-is for mobile (not needed for a native app)

---

## Step 4: Add Your Credentials to the App

Open [lib/core/config/supabase_config.dart](lib/core/config/supabase_config.dart) and fill in:

```dart
class SupabaseConfig {
  static const String url = 'https://your-project-ref.supabase.co';
  static const String anonKey = 'eyJ...your-anon-key...';
}
```

Find both values at: **Project Settings → API → Project URL** and **anon / public key**.

---

## Step 5: Build and Run

```bash
flutter pub get
flutter run
```

---

## Test Procedure

### Test A: New User — Onboarding → Account Creation → Profile

**Goal:** Verify that onboarding data (name, goal, habits) is stored in Supabase and shown on the profile screen.

1. Fresh install (or delete app from simulator)
2. Run app → should show onboarding splash screen
3. Complete all 7 onboarding steps:
   - Enter your name (e.g. **Alex**)
   - Pick a goal (e.g. **Get fit & strong**)
   - Select habits (e.g. **Physical + Creative**)
   - Pick frequency and time of day
4. Tap **"Create your account 🚀"** on the celebration screen → sign-up form appears
5. Enter `test@example.com` / `password123` → tap **Create Account**
6. App navigates to the home screen

**Verify in app:**
- Navigate to the **Profile** tab (bottom nav)
- Username should show **Alex** (not "Day1 Athlete")

**Verify in Supabase dashboard:**
- Table Editor → `profiles` → find the new row → `name` = "Alex", `goal` = "fitness", etc.
- Table Editor → `auth.users` → new user row exists

---

### Test B: Create a Habit — Verify Supabase Sync

**Goal:** Confirm a created habit appears in the Supabase `habits` table.

1. From home screen, tap **+ New Habit**
2. Create a habit: "Morning Run", Physical, Daily
3. Tap Save

**Verify in Supabase dashboard:**
- Table Editor → `habits` → new row with your habit name, linked `user_id`

---

### Test C: Session Persistence — Returning User

**Goal:** Confirm habits and progress load correctly on app restart (no re-onboarding).

1. Kill the app (don't delete it)
2. Relaunch
3. App should go directly to the **home screen** (not onboarding, not login)
4. The habit created in Test B should still appear

---

### Test D: Sign Out → Sign In

**Goal:** Confirm sign-out clears data, and sign-in reloads it from Supabase.

1. Go to **Profile** tab → tap **Sign Out**
2. App navigates to the **login screen**
3. Log in with `test@example.com` / `password123`
4. App navigates to home — habit from Test B should reappear
5. Check profile tab — username should still be **Alex**

---

### Test E: Progress Sync

**Goal:** Confirm XP and level persist across sessions.

1. Complete a recording (all 3 clips: Intention, Evidence, Reflection)
2. Compile the vlog → note XP awarded
3. Check **Profile** tab → XP and level reflect the new progress
4. Kill and relaunch the app
5. Profile tab should show the same XP and level (loaded from Supabase)

**Verify in Supabase dashboard:**
- Table Editor → `user_progress` → row with `total_xp > 0`, `total_vlogs_created = 1`
- Table Editor → `vlogs` → row with your vlog metadata (no `video_path` column — files stay local)

---

### Test F: Second Device / Account Isolation

**Goal:** Confirm data is user-scoped and not shared between accounts.

1. Create a second account with a different email
2. That account should have **no habits** and **0 XP**
3. Sign out, sign back in with the first account
4. First account's habits and progress reappear

---

## Debugging Tips

**Supabase logs:** Dashboard → **Logs → Postgres** — shows all queries hitting the DB  
**Auth logs:** Dashboard → **Authentication → Users** — see all registered users  
**RLS issues:** If queries return empty instead of data, check that RLS policies are created correctly. Run the DDL again or check **Authentication → Policies** in the dashboard.  

**App-side debug output** (visible in Xcode console or `flutter run` terminal):
- `Supabase habit load failed: ...` → auth or RLS issue
- `Supabase progress sync failed: ...` → network or schema mismatch
- `Supabase habit sync failed: ...` → check habits table schema

**Common issues:**
| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Profile shows "Day1 Athlete" after sign-up | Profile upsert failed | Check Supabase logs for the `profiles` table insert |
| Habits empty after login | `habits` RLS policy missing | Re-run DDL, check policies tab |
| App stuck on onboarding after sign-up | `onboardingCompleteProvider` not updating | Check `SignUpScreen._submit()` — should set `ref.read(onboardingCompleteProvider.notifier).state = true` |
| Redirect loop between login and home | Supabase session not restoring | Check `main.dart` — `Supabase.initialize()` must complete before `runApp()` |
| XP doesn't persist after restart | `user_progress` table missing or RLS blocked | Check Supabase dashboard for the table and run DDL again |
