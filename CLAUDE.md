# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Franklin is a Ruby on Rails 8.1 application for B2B outbound marketing campaign management with AI-assisted chat. Uses PostgreSQL, Hotwire (Turbo + Stimulus), Bootstrap 5, and Devise authentication.

## Common Commands

```bash
bin/dev                          # Start dev server (localhost:3000)
bin/rails test                   # Run all tests
bin/rails test test/models       # Run model tests only
bin/rails test test/models/user_test.rb          # Run a single test file
bin/rails test test/models/user_test.rb:10       # Run a single test by line
rails db:migrate                 # Run pending migrations
rails db:seed                    # Load seed data
bin/rubocop                      # Lint (Omakase style)
bin/brakeman                     # Security scan
```

## Architecture

### Domain Model

- **User** → has_many campaigns, chats (Devise auth with username field)
- **Campaign** → belongs_to user, has_many steps, has_one_attached image
  - Attributes: title, icp, status (draft/active/completed), angles, channels, doc_content
- **Step** → belongs_to campaign (day-based outreach sequence)
  - Attributes: day, status (pending/done), generated_content
- **Chat** → belongs_to user, has_many messages
- **Message** → belongs_to chat (role: user/assistant)

### Key Patterns

- `authenticate_user!` in ApplicationController; home page (`pages#home`) skips auth
- Active Storage with Cloudinary in production, local disk in dev/test
- Import maps for JS (no bundler), SCSS via Sprockets
- Simple Form with Bootstrap integration
- Kamal for Docker deployment

### Important Paths

- `config/routes.rb` — all routing (Devise + app routes)
- `db/schema.rb` — current database structure
- `config/storage.yml` — Active Storage backends (local/cloudinary/s3)
- `.github/workflows/ci.yml` — CI pipeline
