# Product Mission

## Pitch
First Ruby Friend is a mentorship matching platform that helps Ruby developers seeking guidance connect with experienced Ruby mentors by providing an intelligent, geography-aware matching system that considers language preferences, timezone compatibility, and mentoring style alignment.

## Users

### Primary Customers
- **Ruby Learners**: Developers new to Ruby or seeking to advance their Ruby skills who need personalized guidance
- **Ruby Mentors**: Experienced Ruby developers who want to give back to the community and help others grow
- **Platform Administrators**: Community organizers who facilitate and manage mentorship relationships

### User Personas

**Aspiring Ruby Developer** (20-35 years old)
- **Role:** Self-taught developer, bootcamp graduate, or career switcher
- **Context:** Learning Ruby on Rails, may be working on personal projects or looking for their first Ruby role
- **Pain Points:** Struggles to find experienced guidance, unsure about best practices, lacks professional network in Ruby community, needs career advice
- **Goals:** Build confidence in Ruby skills, learn industry best practices, get career guidance, connect with experienced professionals

**Experienced Ruby Mentor** (30-50 years old)
- **Role:** Senior developer, engineering lead, or technical director at a company using Ruby
- **Context:** Has years of Ruby experience, wants to contribute to the community, remembers how valuable mentorship was early in their career
- **Pain Points:** Wants to mentor but doesn't know where to find mentees, limited time availability, wants to mentor people who match their expertise and availability
- **Goals:** Help others succeed in Ruby, give back to the community, connect with motivated learners, make efficient use of limited mentoring time

**Community Administrator** (25-45 years old)
- **Role:** Ruby community organizer, meetup coordinator, or program manager
- **Context:** Manages mentorship programs for Ruby communities, conferences, or organizations
- **Pain Points:** Manual matching process is time-consuming, difficult to ensure quality matches, hard to track mentorship progress
- **Goals:** Facilitate successful mentorships, maximize match quality, track program effectiveness, reduce administrative overhead

## The Problem

### Finding Quality Mentorship is Difficult and Inefficient
Ruby developers seeking mentorship face significant barriers: they don't know where to find mentors, cold outreach rarely works, and generic matching platforms ignore critical factors like timezone compatibility, language barriers, and specific mentoring needs (career vs. technical guidance). Meanwhile, experienced developers willing to mentor struggle to find committed mentees who match their availability and expertise areas. This mismatch results in missed opportunities for knowledge transfer and community growth.

**Our Solution:** First Ruby Friend uses an intelligent matching algorithm that considers multiple dimensions - geographic proximity for timezone alignment, spoken language compatibility, mentoring style preferences (career guidance vs. code review), and availability status - to connect mentors and mentees who are most likely to form productive, long-lasting relationships. The platform handles the logistics of matching, allowing both parties to focus on what matters: learning and growth.

## Differentiators

### Intelligent Geographic and Timezone Matching
Unlike generic mentorship platforms, we use geographic data and distance calculations to prioritize matches within compatible timezones. This means mentors and mentees can easily schedule synchronous calls without timezone friction. Our algorithm awards higher match scores for same-country pairs and those within 300-1000km (same or adjacent timezones), while still supporting remote mentorship when local matches aren't available.

### Ruby-Specific Community Focus
Rather than being a general mentorship platform for all technologies, First Ruby Friend is purpose-built for the Ruby community. This focus ensures that every mentor has relevant Ruby expertise, questionnaires capture Ruby-specific context (years in Ruby, career stage), and the community understands the unique challenges of Ruby development and career growth.

### Dual Mentoring Style Preferences
We recognize that mentorship isn't one-size-fits-all. Our platform explicitly distinguishes between career mentorship (navigating job searches, professional growth, workplace dynamics) and code mentorship (technical skills, code review, best practices). Both mentors and applicants specify their preferences, and our matching algorithm considers both dimensions, resulting in better alignment and satisfaction.

### Data-Driven Match Scoring
Instead of presenting random or alphabetical mentor lists, our system calculates a match score (0-100) based on weighted factors: country match (40 points), geographic distance and timezone (up to 30 points), and aligned mentoring preferences (up to 30 points). This transparency helps administrators make informed decisions and ensures the best matches rise to the top.

## Key Features

### Core Features
- **User Authentication & Profiles:** Secure email/password and GitHub OAuth authentication, allowing users to create profiles with location, language preferences, and demographic information
- **Mentor Questionnaires:** Detailed intake forms capturing mentor background, company information, mentoring experience, preferred mentoring styles (career/code), and motivations
- **Applicant Questionnaires:** Comprehensive forms capturing applicant background, current Ruby experience, learning journey, mentorship goals, and preferred mentoring styles
- **Intelligent Match Scoring Algorithm:** Multi-factor scoring system that evaluates country alignment, geographic distance, timezone compatibility, language overlap, and mentoring style preferences to generate ranked match lists

### Matching & Management Features
- **Match Discovery Interface:** Visual dashboard showing unmatched applicants with detailed profiles, allowing administrators to explore potential matches
- **Match Review & Approval:** Detailed match view displaying side-by-side profiles, match scores with explanations, shared attributes, and one-click approval workflow
- **Mentorship Tracking:** Active mentorship records with standing status (active/ended), relationship timeline, and participant information
- **Match History:** Browse all mentors, applicants, and active mentorships to track program engagement and outcomes

### Supporting Features
- **Multi-Language Support:** Users can specify multiple spoken languages, and the matching algorithm requires at least one shared language for a valid match
- **Geographic Awareness:** Automatic geocoding of user locations (city + country) to enable distance calculations and timezone-aware matching
- **Session Management:** Track user sessions with device and IP information for security
- **Event Logging:** Audit trail of authentication events, email verifications, and password changes for security and debugging
