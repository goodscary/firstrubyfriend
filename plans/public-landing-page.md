# feat: Public Landing Page for Unauthenticated Users

Build the public "not logged in" landing page based on the existing firstrubyfriend.org website, using DaisyUI components.

## Overview

Create a public-facing landing page that matches the existing firstrubyfriend.org website. Uses DaisyUI (already installed) for components. The page should only be visible to unauthenticated users - authenticated users are redirected to the dashboard.

## Content from firstrubyfriend.org

### Home Page
- **Hero**: "Make your first #rubyfriend today"
- **Subhead**: "Six half-hour calls between early career devs and friendly volunteer mentors"
- **Status**: Programme temporarily closed until 2026
- Logo: Ruby Plus One SVG

### Early Career Devs Page (`/early-career-devs`)
- **Heading**: "Six half-hour calls with a new #rubyfriend"
- **Subhead**: "A space to ask questions about starting a career as a Ruby/Rails software engineer"
- **Who it's for**: First-year programmers, self-taught developers, bootcamp graduates, college-educated professionals
- **Format**: Six monthly half-hour video calls (Zoom, Google Meet, Tuple, FaceTime)
- **Matching**: Geographic location and preferences considered

**FAQ Content**:
- What qualifies someone as early-career?
- What topics can be discussed?
- How does matching work?
- What if compatibility issues arise?

### Mentors Page (`/mentors`)
- **Heading**: "New #rubyfriends need your help"
- **Subhead**: "A tiny offering of your time with a huge impact for them"
- **Pitch**: ~3 hours over 6 months, any experience level welcome
- Junior devs valuable as mentors (recent relevant experience)
- Teaching reinforces learning

**FAQ Content**:
- Do I need to be senior?
- What do we talk about?
- What if we're not compatible?
- What's the time commitment?

### Code of Conduct Page
- **Philosophy**: "Everyone be cool. Seriously."
- **MINASWAN**: Matz Is Nice And So We Are Nice
- Zero tolerance for harassment
- Avoid gatekeeping behaviors
- Contact: andy@goodscary.com

### Footer
- Organized by Andy Croll, CTO at CoverageBook
- Links: One Ruby Thing, Brighton Ruby, Using Rails

## Technical Approach

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `app/views/layouts/marketing.html.erb` | Create | Separate layout for public pages |
| `app/views/home/show.html.erb` | Replace | Landing page content |
| `app/views/pages/early_career.html.erb` | Create | Early career devs info page |
| `app/views/pages/mentors.html.erb` | Create | Mentors info page |
| `app/views/pages/conduct.html.erb` | Create | Code of conduct page |
| `app/controllers/pages_controller.rb` | Create | Serve static pages |
| `config/routes.rb` | Modify | Add page routes |

### DaisyUI Components to Use

```erb
<%# Hero - use DaisyUI hero component %>
<div class="hero min-h-[60vh] bg-base-200">
  <div class="hero-content text-center">
    <div class="max-w-md">
      <h1 class="text-5xl font-bold">...</h1>
      <p class="py-6">...</p>
      <button class="btn btn-primary">Get Started</button>
    </div>
  </div>
</div>

<%# Cards for CTAs %>
<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">...</h2>
    <p>...</p>
    <div class="card-actions justify-end">
      <%= link_to "Apply", path, class: "btn btn-primary" %>
    </div>
  </div>
</div>

<%# Alert for status %>
<div class="alert alert-warning">
  <span>Programme temporarily closed until 2026</span>
</div>

<%# Collapse for FAQ %>
<div class="collapse collapse-arrow bg-base-200">
  <input type="radio" name="faq" />
  <div class="collapse-title text-xl font-medium">Question?</div>
  <div class="collapse-content"><p>Answer</p></div>
</div>

<%# Footer %>
<footer class="footer footer-center bg-base-300 text-base-content p-4">
  <p>Organized by Andy Croll</p>
</footer>
```

### Authentication Fix (from reviewer feedback)

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  skip_before_action :authenticate
  before_action :set_session_if_present

  def show
    redirect_to dashboard_path and return if Current.session
  end

  private

  def set_session_if_present
    if (session_record = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session_record
    end
  end
end
```

### Separate Marketing Layout

```erb
<!-- app/views/layouts/marketing.html.erb -->
<!DOCTYPE html>
<html data-theme="light">
<head>
  <title><%= content_for(:title) || "First Ruby Friend" %></title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>
<body class="min-h-screen flex flex-col">
  <!-- Simple public nav -->
  <div class="navbar bg-base-100 shadow-sm">
    <div class="flex-1">
      <%= link_to root_path do %>
        <%= image_tag "https://firstrubyfriend.org/images/ruby-plus-one.svg",
            alt: "First Ruby Friend", class: "h-8" %>
      <% end %>
    </div>
    <div class="flex-none gap-2">
      <%= link_to "Sign In", sign_in_path, class: "btn btn-ghost" %>
      <%= render "sessions/github_oauth_button" %>
    </div>
  </div>

  <main class="flex-1">
    <%= yield %>
  </main>

  <footer class="footer bg-neutral text-neutral-content p-10">
    <!-- Navigation Links -->
    <nav>
      <h6 class="footer-title">Programme</h6>
      <%= link_to "Home", root_path, class: "link link-hover" %>
      <%= link_to "Early Career Devs", early_career_path, class: "link link-hover" %>
      <%= link_to "Become a Mentor", mentors_path, class: "link link-hover" %>
    </nav>

    <!-- Community Links -->
    <nav>
      <h6 class="footer-title">Community</h6>
      <%= link_to "Code of Conduct", conduct_path, class: "link link-hover" %>
      <%= link_to "Brighton Ruby", "https://brightonruby.com", target: "_blank", class: "link link-hover" %>
      <%= link_to "One Ruby Thing", "https://onerubything.com", target: "_blank", class: "link link-hover" %>
    </nav>

    <!-- About -->
    <nav>
      <h6 class="footer-title">About</h6>
      <%= link_to "Andy Croll", "https://andycroll.com", target: "_blank", class: "link link-hover" %>
      <%= link_to "CoverageBook", "https://coveragebook.com", target: "_blank", class: "link link-hover" %>
      <%= link_to "Using Rails", "https://usingrails.com", target: "_blank", class: "link link-hover" %>
    </nav>
  </footer>
</body>
</html>
```

## Acceptance Criteria

### Functional
- [ ] Unauthenticated users see landing page at root URL
- [ ] Authenticated users redirect to dashboard
- [ ] Hero displays headline, subhead, and logo
- [ ] Status alert shows programme is closed
- [ ] Dual CTAs link to early-career and mentor info pages
- [ ] Early career page shows full info and FAQ
- [ ] Mentors page shows full info and FAQ
- [ ] Code of conduct page displays conduct content
- [ ] Sign in link works
- [ ] GitHub OAuth button works

### Non-Functional
- [ ] Uses DaisyUI components
- [ ] Mobile responsive
- [ ] No custom CSS

## Implementation Plan

### Phase 1: Routes & Controller
- [ ] Create `PagesController` with `skip_before_action :authenticate`
- [ ] Add routes: `/early-career-devs`, `/mentors`, `/conduct`
- [ ] Fix HomeController auth consistency

### Phase 2: Marketing Layout
- [ ] Create `app/views/layouts/marketing.html.erb`
- [ ] Add public navbar with sign-in
- [ ] Add footer with links

### Phase 3: Landing Page
- [ ] Replace `home/show.html.erb` with DaisyUI hero
- [ ] Add status alert
- [ ] Add dual CTA cards
- [ ] Use `layout "marketing"`

### Phase 4: Info Pages
- [ ] Create early career devs page with FAQ collapse
- [ ] Create mentors page with FAQ collapse
- [ ] Create code of conduct page

### Phase 5: Testing
- [ ] System test: unauthenticated sees landing
- [ ] System test: authenticated redirects to dashboard

## MVP Implementation

### app/views/home/show.html.erb

```erb
<% content_for :title, "First Ruby Friend - Make your first #rubyfriend today" %>

<!-- Hero -->
<div class="hero min-h-[60vh] bg-base-200">
  <div class="hero-content text-center">
    <div class="max-w-2xl">
      <%= image_tag "https://firstrubyfriend.org/images/ruby-plus-one.svg",
          alt: "Ruby Plus One", class: "mx-auto h-24 mb-8" %>

      <h1 class="text-5xl font-bold">
        Make your first <span class="text-primary">#rubyfriend</span> today
      </h1>

      <p class="py-6 text-xl">
        Six half-hour calls between early career devs and friendly volunteer mentors.
      </p>

      <!-- Status Alert -->
      <div class="alert alert-warning mb-6">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <span>Programme temporarily closed until 2026</span>
      </div>
    </div>
  </div>
</div>

<!-- Dual CTAs -->
<div class="py-16 px-4">
  <div class="max-w-4xl mx-auto grid md:grid-cols-2 gap-8">

    <!-- Early Career -->
    <%= link_to early_career_path, class: "card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow" do %>
      <div class="card-body">
        <h2 class="card-title text-2xl">Early Career Devs</h2>
        <p>In your first year of programming? Looking for guidance from someone who's been there?</p>
        <div class="card-actions justify-end mt-4">
          <span class="btn btn-primary">Apply here →</span>
        </div>
      </div>
    <% end %>

    <!-- Mentors -->
    <%= link_to mentors_path, class: "card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow" do %>
      <div class="card-body">
        <h2 class="card-title text-2xl">Help Wanted</h2>
        <p>Got programming experience? Want to give back to the Ruby community? We need your help.</p>
        <div class="card-actions justify-end mt-4">
          <span class="btn btn-primary">How can I help? →</span>
        </div>
      </div>
    <% end %>

  </div>
</div>

<!-- Value Prop -->
<div class="bg-base-200 py-16 px-4">
  <div class="max-w-2xl mx-auto text-center">
    <h2 class="text-3xl font-bold mb-4">We are nice</h2>
    <p class="text-lg">
      We pair first year programmers with experienced Rubyists for free mentorship.
      No strings attached, just friendly help from the Ruby community.
    </p>
  </div>
</div>
```

### app/views/pages/early_career.html.erb

```erb
<% content_for :title, "Early Career Developer Mentorship | First Ruby Friend" %>

<div class="max-w-3xl mx-auto py-16 px-4">
  <h1 class="text-4xl font-bold mb-4">
    Six half-hour calls with a new #rubyfriend
  </h1>

  <p class="text-xl text-base-content/70 mb-8">
    A space to ask questions about starting a career as a Ruby/Rails software engineer
  </p>

  <div class="alert alert-warning mb-8">
    <span>Applications are currently closed until 2026</span>
  </div>

  <div class="prose prose-lg max-w-none mb-12">
    <p>
      Experienced Ruby developers volunteer to mentor early-career professionals through
      six monthly half-hour conversations. We welcome those pursuing their first role in
      Ruby/Rails development, including self-taught developers, bootcamp graduates, and
      college-educated professionals.
    </p>

    <h2>How it works</h2>
    <ul>
      <li>Six half-hour calls spanning six months</li>
      <li>Flexible scheduling with your mentor</li>
      <li>Virtual meetings via Zoom, Google Meet, Tuple, or FaceTime</li>
      <li>Matching considers geographic location and preferences</li>
    </ul>
  </div>

  <h2 class="text-2xl font-bold mb-4">Frequently Asked Questions</h2>

  <div class="space-y-2">
    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" checked="checked" />
      <div class="collapse-title text-xl font-medium">
        What qualifies as "early career"?
      </div>
      <div class="collapse-content">
        <p>If you're in your first year of programming professionally, or actively seeking your first Ruby/Rails role, this programme is for you.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        What can we talk about?
      </div>
      <div class="collapse-content">
        <p>You set the agenda! Career advice, code questions, job searching tips, interview prep, or just having someone to talk through problems with. It's your time.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        How does matching work?
      </div>
      <div class="collapse-content">
        <p>We consider geographic location, timezone, and stated preferences to find compatible pairings.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        What if we're not compatible?
      </div>
      <div class="collapse-content">
        <p>Honest communication is encouraged. If either party wishes to discontinue, that's fine. We can try to find a replacement match.</p>
      </div>
    </div>
  </div>

  <div class="mt-12 text-center">
    <%= link_to "Back to Home", root_path, class: "btn btn-outline" %>
  </div>
</div>
```

### app/views/pages/mentors.html.erb

```erb
<% content_for :title, "Become a Mentor | First Ruby Friend" %>

<div class="max-w-3xl mx-auto py-16 px-4">
  <h1 class="text-4xl font-bold mb-4">
    New #rubyfriends need your help
  </h1>

  <p class="text-xl text-base-content/70 mb-8">
    A tiny offering of your time with a huge impact for them
  </p>

  <div class="alert alert-warning mb-8">
    <span>Mentor signup is currently closed until 2026</span>
  </div>

  <div class="prose prose-lg max-w-none mb-12">
    <p>
      We're looking for mentors to contribute approximately three hours over a six-month
      period to guide early-career developers. Your experience level doesn't matter—both
      junior and seasoned engineers can contribute meaningfully.
    </p>

    <h2>Why mentor?</h2>
    <ul>
      <li>Junior developers make great mentors (recent relevant experience!)</li>
      <li>Teaching reinforces your own learning</li>
      <li>Give back to the community that helped you</li>
      <li>Meet new people in the Ruby world</li>
    </ul>
  </div>

  <h2 class="text-2xl font-bold mb-4">Frequently Asked Questions</h2>

  <div class="space-y-2">
    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" checked="checked" />
      <div class="collapse-title text-xl font-medium">
        Do I need to be a senior developer?
      </div>
      <div class="collapse-content">
        <p>No! If you have more than a year of programming experience, you have something valuable to share. Junior devs often make excellent mentors because they remember what it's like to be new.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        What do we talk about?
      </div>
      <div class="collapse-content">
        <p>Let your mentee guide the conversation. They might want career advice, code help, interview prep, or just someone to talk to about the industry.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        What's the time commitment?
      </div>
      <div class="collapse-content">
        <p>Six 30-minute calls over six months. That's about 3 hours total. Scheduling is flexible between you and your mentee.</p>
      </div>
    </div>

    <div class="collapse collapse-arrow bg-base-200">
      <input type="radio" name="faq" />
      <div class="collapse-title text-xl font-medium">
        What if we're not compatible?
      </div>
      <div class="collapse-content">
        <p>That's okay! If things aren't working out, let us know. We can try to rematch either of you with someone else.</p>
      </div>
    </div>
  </div>

  <div class="mt-12 text-center">
    <%= link_to "Back to Home", root_path, class: "btn btn-outline" %>
  </div>
</div>
```

### app/views/pages/conduct.html.erb

```erb
<% content_for :title, "Code of Conduct | First Ruby Friend" %>

<div class="max-w-3xl mx-auto py-16 px-4">
  <h1 class="text-4xl font-bold mb-8">Code of Conduct</h1>

  <div class="prose prose-lg max-w-none">
    <p class="text-2xl font-medium">
      "Everyone be cool. Seriously."
    </p>

    <p>
      This community prioritizes creating a safe space for new developers through
      respectful, kind treatment of all participants and organizers.
    </p>

    <h2>MINASWAN</h2>
    <p>
      <strong>Matz Is Nice And So We Are Nice.</strong>
    </p>
    <p>
      We emphasize kindness beyond just avoiding harassment. We discourage gatekeeping
      behaviors like unnecessary corrections and subtle discriminatory language that
      may alienate newcomers.
    </p>

    <h2>Harassment Policy</h2>
    <p>
      Zero tolerance for any harassing behavior, including offensive comments about
      identity, unwelcome advances, stalking, or disruptive conduct. Violators face
      immediate removal.
    </p>

    <h2>Making Mistakes</h2>
    <p>
      We recognize that accidental missteps differ from intentional harm. Members who
      say something hurtful should apologize promptly and educate themselves. Single
      incidents receive mediation; repeated or deliberate violations result in removal.
    </p>

    <h2>Reporting</h2>
    <p>
      Report violations to organizer Andy Croll at
      <a href="mailto:andy@goodscary.com">andy@goodscary.com</a>.
      Swift enforcement follows, from mediation to expulsion depending on severity.
    </p>

    <h2>Accessibility</h2>
    <p>
      We commit to accommodating all participants' accessibility needs.
      Requests should go to the same contact email.
    </p>
  </div>

  <div class="mt-12 text-center">
    <%= link_to "Back to Home", root_path, class: "btn btn-outline" %>
  </div>
</div>
```

### app/controllers/pages_controller.rb

```ruby
class PagesController < ApplicationController
  skip_before_action :authenticate
  layout "marketing"

  def early_career
  end

  def mentors
  end

  def conduct
  end
end
```

### config/routes.rb additions

```ruby
# Public marketing pages
get "early-career-devs", to: "pages#early_career", as: :early_career
get "mentors", to: "pages#mentors", as: :mentors
get "conduct", to: "pages#conduct", as: :conduct
```

## References

### Content Sources
- https://firstrubyfriend.org (home)
- https://firstrubyfriend.org/early-career-devs
- https://firstrubyfriend.org/mentors
- https://firstrubyfriend.org/code-of-conduct

### Internal References
- DaisyUI config: `app/assets/tailwind/application.css`
- DaisyUI themes: `app/assets/tailwind/daisyui-theme.js`
- Home controller: `app/controllers/home_controller.rb`
