# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-08-24-controller-prefixed-ids/spec.md

> Created: 2025-08-24
> Status: Ready for Implementation

## Tasks

### Task 1: Route and Controller Analysis

**Objective:** Audit current application to identify all places using integer IDs that need conversion to prefixed IDs

1.1 Write tests to document current ID usage patterns in routes and controllers
1.2 Create comprehensive audit of all routes in `config/routes.rb` using integer IDs
1.3 Identify all controller actions (`show`, `edit`, `update`, `destroy`) using `params[:id]`
1.4 Document all model lookups using `find()` method with integer IDs
1.5 Create inventory of URL helpers and link generation using integer IDs
1.6 Identify any API endpoints or JSON responses exposing integer IDs
1.7 Document any third-party integrations or webhooks using integer IDs
1.8 Setup `to_param` methods on all models to automatically provide prefixed_ids
1.8 Verify analysis tests pass and create implementation roadmap

### Task 2: Core Controller Updates

**Objective:** Update primary controllers (UsersController, MentorshipsController) to use prefixed IDs while maintaining functionality

2.1 Write comprehensive controller tests for prefixed ID handling in UsersController
2.2 Update UsersController `show` action to accept and handle prefixed IDs
2.3 Update UsersController `edit`, `update`, `destroy` actions for prefixed ID support
2.4 Write comprehensive controller tests for prefixed ID handling in MentorshipsController
2.5 Update MentorshipsController actions to use prefixed IDs for mentor/applicant lookups
2.6 Update any nested resource controllers to handle parent prefixed IDs correctly
2.7 Add proper error handling for invalid or malformed prefixed IDs
2.8 Verify all controller tests pass with prefixed ID changes

### Task 3: View and Helper Updates

**Objective:** Update all views, forms, and URL generation to use prefixed IDs consistently

3.1 Write tests for view helper methods that generate URLs with prefixed IDs
3.2 Update all `link_to` calls in views to use prefixed IDs instead of integer IDs
3.3 Update form helpers (`form_with`, `form_for`) to handle prefixed IDs in routes
3.4 Update any JavaScript code that constructs URLs or handles ID parameters
3.5 Update email templates and mailer views using user or mentorship URLs
3.6 Create or update view helpers for consistent prefixed ID URL generation
3.7 Update any partials or shared components referencing integer IDs
3.8 Verify all view and helper tests pass with updated ID handling

### Task 4: Error Handling and Security

**Objective:** Implement robust error handling for prefixed IDs and maintain security standards

4.1 Write tests for various invalid prefixed ID scenarios (malformed, wrong prefix, non-existent)
4.2 Implement custom exception handling for invalid prefixed ID formats
4.3 Add proper 404 error handling for non-existent prefixed IDs
4.4 Update strong parameters to validate prefixed ID format where applicable
4.5 Ensure authorization checks work correctly with prefixed ID lookups
4.6 Add logging for invalid prefixed ID access attempts (security monitoring)
4.7 Update any rate limiting or abuse prevention to work with prefixed IDs
4.8 Verify all error handling tests pass and security is maintained

### Task 5: Testing and Integration

**Objective:** Comprehensive testing of all prefixed ID changes and ensure system integration works correctly

5.1 Write integration tests for complete user workflows using prefixed IDs
5.2 Create system tests for mentor-applicant matching flow with prefixed URLs
5.3 Test email sequences and notifications contain correct prefixed ID URLs
5.4 Verify all existing fixtures and test data work with prefixed ID changes
5.5 Run full test suite to ensure no regressions in existing functionality
5.6 Test any third-party integrations (geocoder, email services) still function
5.7 Create performance tests to ensure prefixed ID lookups don't impact speed
5.8 Verify complete test suite passes and all integration points work correctly