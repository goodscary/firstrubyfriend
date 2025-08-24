# Spec Requirements Document

> Spec: Controller Prefixed IDs Implementation
> Created: 2025-08-24
> Status: Planning

## Overview

This spec details the implementation of prefixed IDs in the controller layer of First Ruby Friend. Following the completion of the prefixed ID migration work, this spec focuses on updating all controllers to use prefixed IDs for public-facing operations instead of exposing internal database integer IDs.

The current controller layer uses integer IDs in URLs and model lookup operations, which exposes the internal database structure and creates security concerns. This implementation will complete the prefixed ID system by updating the application layer to use the new prefixed ID system consistently.

## User Stories

**As a security-conscious developer**, I want URLs to use non-sequential prefixed IDs so that users cannot easily enumerate resources or guess other resource IDs.

**As a platform user**, I want consistent, opaque identifiers in URLs so that the system feels professional and secure.

**As a developer**, I want all controller operations to use prefixed IDs so that the public API is consistent and doesn't expose internal database structure.

**As a maintainer**, I want backward compatibility where needed so that existing bookmarks and integrations continue to work during the transition period.

## Spec Scope

### Controllers to Update
- **UsersController** - User profile and management operations
- **MentorshipsController** - Mentorship relationship management
- **SessionsController** - Authentication and session management
- **QuestionnairesController** - Questionnaire response handling
- **ApplicationController** - Base controller helper methods
- **Any additional controllers** performing model lookups with integer IDs

### Operations to Update
- **Route parameters** - Change from `:id` to prefixed ID format
- **Model finding** - Replace `find(params[:id])` with `find_by_prefix_id(params[:id])`
- **URL generation** - Update view helpers to generate prefixed ID URLs, using the `to_param` method on each model
- **Form submissions** - Ensure forms use prefixed IDs for model references
- **Redirect operations** - Update redirects to use prefixed IDs
- **Link generation** - Update all link_to and url_for calls

### Security Enhancements
- **Non-sequential IDs** - Prevent resource enumeration attacks
- **Opaque identifiers** - Hide database structure from public interfaces
- **Consistent API** - Ensure all public-facing IDs use the same format

## Out of Scope

- **Database schema changes** - Already completed in previous migration spec
- **Model method implementation** - find_by_prefix_id already exists
- **Internal admin interfaces** - May continue using integer IDs for admin operations
- **Background job processing** - Internal operations can continue using integer IDs
- **Third-party integrations** - External API calls may still use internal IDs

## Expected Deliverable

A fully updated controller layer where:

1. **All public-facing URLs** use prefixed IDs instead of integer IDs
2. **All controller actions** use `find_by_prefix_id` for model lookups
3. **All view helpers** generate URLs with prefixed IDs
4. **All forms and links** reference models using prefixed IDs
5. **Comprehensive test coverage** validates the prefixed ID implementation
6. **Backward compatibility** is maintained where necessary
7. **Error handling** properly manages invalid prefixed ID scenarios

### Success Criteria
- No integer IDs visible in public URLs
- All model lookups in controllers use prefixed IDs
- All tests pass with prefixed ID implementation
- User experience remains unchanged except for URL format
- Security is enhanced through non-sequential ID usage

## Spec Documentation

- Tasks: @.agent-os/specs/2025-08-24-controller-prefixed-ids/tasks.md
- Technical Specification: @.agent-os/specs/2025-08-24-controller-prefixed-ids/sub-specs/technical-spec.md
- Routes Specification: @.agent-os/specs/2025-08-24-controller-prefixed-ids/sub-specs/routes-spec.md
- Testing Specification: @.agent-os/specs/2025-08-24-controller-prefixed-ids/sub-specs/tests.md