# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: Ruby on Rails 8.0+
- Language: Ruby 3.4+
- Primary Database: SQLite
- ORM: Active Record
- JavaScript Framework: Stimulus latest
- Build Tool: None
- Import Strategy: Importmaps
- CSS Framework: DaisyUI & TailwindCSS 4.0+
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Paid boxicons (in ~/code/boxicons)
- Application Hosting: Digital Ocean App Platform/Droplets
- Hosting Region: Primary region based on user base
- Database Hosting: SQLite
- Database Backups: Litestream
- Asset Storage: DigitalOcean Spaces
- CDN: Cloudflare
- Asset Access: Private with signed URLs
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to pr or main branch
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch
