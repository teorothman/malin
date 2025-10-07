# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup and Running
- Initial setup: `mix setup` (installs deps, runs ash.setup, installs and builds assets, runs seeds)
- Start server: `mix phx.server` or `iex -S mix phx.server`
- Server runs on: http://localhost:4000

### Testing
- Run all tests: `mix test` (runs `ash.setup --quiet` first)
- Run specific file: `mix test test/path/to/file_test.exs`
- Run specific test: `mix test test/path/to/file_test.exs:123`
- Max failures: `mix test --max-failures n`

### Database
- Setup database: `mix ash.setup` (creates, migrates, seeds)
- Reset database: `mix ash.reset` (drops and recreates)
- Create migration: Ash generates migrations automatically

### Assets
- Build assets: `mix assets.build` (tailwind + esbuild)
- Production build: `mix assets.deploy` (minified + digest)
- Install asset tools: `mix assets.setup`

### Documentation and Usage Rules
- Search docs: `mix usage_rules.search_docs "query"`
- Module/function docs: `mix usage_rules.docs Module.function/arity`
- Consult AGENTS.md for Elixir, OTP, and dependency usage rules

## Architecture Overview

### Tech Stack
- **Framework**: Phoenix 1.7.14 with LiveView 1.0.0-rc.1
- **Data Layer**: Ash Framework 3.0 with AshPostgres and Ecto
- **Authentication**: AshAuthentication 4.0 with magic link/email strategy
- **Frontend**: Phoenix LiveView with TailwindCSS and esbuild
- **Email**: Swoosh with Resend adapter
- **Deployment**: Fly.io with Docker
- **Storage**: S3 for file uploads (via ExAws)

### Ash Domain Architecture

The application uses Ash Framework's domain-driven design. All business logic is organized into domains:

- **Malin.Accounts** - User management, authentication, notifications
- **Malin.Posts** - Blog posts, comments, forms
- **Malin.Categories** - Categories and tags for posts
- **Malin.Messages** - Contact/message system
- **Malin.Testimonies** - User testimonials
- **Malin.Analytics** - Page view tracking

Each domain contains:
- **Resources**: Ash resources that define data structures, validations, policies
- **Actions**: CRUD operations defined on resources (create, read, update, destroy)
- **Code Interface**: Domain-level functions that expose resource actions

Example from `lib/malin/accounts/accounts.ex`:
```elixir
defmodule Malin.Accounts do
  use Ash.Domain

  resources do
    resource Malin.Accounts.User do
      define :get_user, action: :show, args: [:id]
      define :register, action: :register
      # ... more actions
    end
  end
end
```

### Ash Resource Pattern

Resources in `lib/malin/*/resources/` follow this structure:
1. **Data Layer**: PostgreSQL via AshPostgres
2. **Attributes**: Fields with types, constraints, defaults
3. **Relationships**: belongs_to, has_many, many_to_many
4. **Policies**: Authorization rules (by default requires authorization)
5. **Actions**: Custom CRUD operations with arguments, validations, changes
6. **Changes**: Side effects (e.g., sending emails, notifications)

Example: `lib/malin/posts/resources/post.ex` shows posts with:
- State machine: :draft, :published, :hidden
- Relationships: author (User), category, tags (many_to_many), comments
- Policy: Public reads, admin-only writes
- Custom change: Sends notifications on post creation

### Authentication and Authorization

**Authentication** (AshAuthentication):
- Magic link via email (no passwords)
- Token-based sessions (JWT)
- User resource at `lib/malin/accounts/user/user.ex`
- Email sender: `Malin.Accounts.User.Senders.SendMagicLinkEmail`

**User Roles**:
- `:applicant` (default) - New users awaiting approval
- `:user` - Regular authenticated users
- `:admin` - Full access

**Authorization** (Ash Policies):
- Posts domain: `authorize :by_default, require_actor? true`
- Categories domain: `authorize :when_requested, require_actor? false`
- Policies defined per resource action (see Post policies for example)

**LiveView Auth Hooks**:
Routes use `on_mount` hooks defined in `lib/malin_web/live_user_auth.ex`:
- `:live_user_required` - Authenticated user must be present
- `:live_user_optional` - User may or may not be authenticated
- `:admin` - User must have admin role
- `:live_no_user` - User must not be authenticated

### Router Organization

See `lib/malin_web/router.ex`:
- `/` - Public routes (posts, about, contact, etc.) with `:live_user_optional`
- `/profil` - User profile (requires authentication)
- `/admin` - Admin routes (requires admin role): post editing, user management, messages, analytics
- `/auth` - Authentication routes (AshAuthentication.Phoenix)
- `/dev` - Development-only routes (LiveDashboard, Swoosh mailbox)

### Key Application Patterns

**Analytics Tracking**:
- `MalinWeb.AnalyticsPlug` in browser pipeline tracks pageviews
- Stored in `Malin.Analytics.Pageview` resource

**Notifications**:
- When posts are created, `Malin.Accounts.Changes.SendNewPostNotifications` change creates notifications
- Notifications shown in `lib/malin_web/components/notifications_live.ex`

**S3 Uploads**:
- `Malin.Uploaders.S3Uploader` handles file uploads
- Posts can have `image_url` attribute

**Email**:
- Configured in `config/runtime.exs` with Resend API
- Email templates in `lib/malin/accounts/emails.ex`

### Database Migrations

Migrations in `priv/repo/migrations/` are managed by Ash:
- Ash generates migrations based on resource definitions
- Run with `mix ash.setup` or standard Ecto commands
- 20 migrations from initial setup to latest features

### Testing

Test files in `test/`:
- `test/test_helper.exs` - Test setup
- Tests use `mix ash.setup --quiet` for database setup
- Phoenix controller and LiveView tests follow standard patterns

### Deployment

**Fly.io Configuration** (`fly.toml`):
- App: malin
- Region: arn (Stockholm)
- Release command: `/app/bin/migrate`
- Port: 8080
- Auto-scaling: 0-1 machines

**Docker** (`Dockerfile`):
- Multi-stage build
- Elixir 1.18.0, OTP 27.2, Debian bullseye
- Assets compiled in build stage
- Release command: `/app/bin/server`

**Release Migration**:
See `lib/malin/release.ex` for migration helper used in Fly.io deployment

## Important Development Notes

### Consulting Usage Rules

**Before using any dependency**, consult AGENTS.md which contains:
- Elixir core patterns and common mistakes
- OTP best practices for GenServers, Tasks, Supervisors
- Igniter usage for code generation
- Standard library usage guidance

Use `mix usage_rules.search_docs` frequently when working with Ash, Phoenix LiveView, or other dependencies.

### Ash Framework Guidelines

- Actions are the interface to resources - don't bypass with direct Ecto queries
- Use `prepare build(load: [...], sort: [...])` to eager load and sort
- Policies authorize actions - check policies when adding new actions
- Changes run side effects - keep them focused and testable
- Use `manage_relationship` for handling associations in actions

### Phoenix LiveView Patterns

- Use `on_mount` hooks for authentication checks
- Load data in `mount/3`, handle events in `handle_event/3`
- Use `assign/3` and `assign_new/3` for socket state
- LiveComponents for reusable UI (see `lib/malin_web/components/`)

### Code Organization

- Business logic: `lib/malin/*/` (Ash domains and resources)
- Web layer: `lib/malin_web/` (LiveViews, controllers, components, plugs)
- Static assets: `assets/` (JS, CSS)
- Config: `config/*.exs` (compile-time in config.exs, runtime in runtime.exs)
