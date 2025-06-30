# Code Coverage Analysis

**Current Coverage: 74.96%**
**Target Coverage: 80%**

## Missing Model Tests

1. **EmailVerificationToken** - Token generation and validation
2. **Event** - User activity tracking  
3. **PasswordResetToken** - Token generation and expiry
4. **Session** - Session management and sudo functionality
5. **Current** - Thread-local storage model
6. **ApplicationRecord** - Base model (may not need direct tests)

## Missing Controller Tests

1. **ApplicationQuestionnairesController** - May be covered by mentee_questionnaires_controller_test
2. **DashboardsController** - Dashboard rendering logic
3. **HomeController** - Homepage functionality
4. **MasqueradesController** - Admin impersonation feature
5. **Sessions::OmniauthController** - GitHub OAuth login
6. **Sessions::SudosController** - Sudo mode functionality
7. **Authentications::EventsController** - Authentication event tracking

## Priority Areas for Testing

### High Priority (Authentication & Security)
- EmailVerificationToken model
- PasswordResetToken model  
- Session model
- Sessions::OmniauthController
- Sessions::SudosController
- MasqueradesController

### Medium Priority (Core Features)
- Event model
- DashboardsController
- Authentications::EventsController

### Low Priority
- Current model (utility class)
- ApplicationRecord (base class)
- HomeController (mostly static content)

## Recommended Next Steps

1. Add tests for authentication token models (EmailVerificationToken, PasswordResetToken)
2. Add tests for Session model including sudo functionality
3. Add controller tests for OAuth and sudo sessions
4. Add tests for dashboard functionality
5. Consider integration tests for critical user flows