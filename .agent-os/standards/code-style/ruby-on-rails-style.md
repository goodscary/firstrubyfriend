# Ruby Style Guide

Write Ruby like poetry - every line essential, every construct purposeful.

## Structure Rules
- Use 2 spaces for indentation
- Use idiomatic Enumerable methods where you can.

## Formatting
- Run `rubocop -A` to automatically format code.

## Rails Patterns

### Model Organization
- **Fat models, skinny controllers** - Business logic lives in models
- **Namespaced concerns** - Organize related behavior under model namespace (`User::Avatar`, `Book::Accessable`) 
- **No service objects** - Keep logic in models and controllers, avoid extra abstraction layers
- **Polymorphic interfaces** - Use single interface for related concepts (`leafable`, `messageable`)

```ruby
# YES: Rich domain model with focused concerns
class User < ApplicationRecord
  include Avatar, Role, Searchable
  
  def deactivate
    update(deactivated_at: Time.current)
  end
  
  def initials
    name.scan(/\b\w/).join
  end
end

# NO: Anemic models with service objects
class UserService
  def deactivate_user(user)
    # business logic in service layer
  end
end
```

### Business Logic Placement
- **Domain methods on models** - `book.press(content)`, `user.deactivate`, `room.receive(message)`
- **Controller concerns for cross-cutting behavior** - `Authentication`, `Authorization`, `RoomScoped`
- **Callbacks for workflows** - Use model callbacks for complex state transitions
- **Current pattern for global state** - `Current.user`, `Current.account` over dependency injection

### Application Structure
- **Nested controllers by domain** - `Books::BookmarksController`, `Rooms::MessagesController`
- **STI for type variations** - `Room` base class with `Rooms::Open`, `Rooms::Direct` subclasses
- **Minimal ApplicationController** - Just authentication and shared concerns

## Code Style & Conventions

### Method Naming
- **Domain-driven names** - `press()`, `receive()`, `grant_access()` over generic `create()`, `update()`
- **Predicate methods** - Heavy use of `?` methods: `signed_in?`, `editable?`, `current?`
- **Inquiry methods** - Use `.inquiry` on string enums for predicate methods

```ruby
# YES: Domain-driven, terse naming
def signed_in?
  Current.user.present?
end

def title
  [name, bio].compact_blank.join(" – ")
end

enum :theme, %w[black blue green].index_by(&:itself), suffix: true
# Automatically creates: black_theme?, blue_theme?, green_theme?

# NO: Verbose, procedural naming
def check_if_user_is_currently_signed_in
  if Current.user && Current.user.present?
    return true
  else
    return false
  end
end
```

### Rails Idioms Over Custom Code
- **`presence` for fallbacks** - `params[:role].presence_in(%w[member admin]) || "member"`
- **`blank?` and `present?` checks** - Use liberally instead of custom nil checks
- **`compact_blank` for hashes/arrays** - Remove nil and empty values
- **`tap` for side effects** - Chain operations with side effects

```ruby
# YES: Idiomatic Rails patterns
body.to_plain_text.presence || attachment&.filename&.to_s || ""
users.partition { |u| selected_ids.include?(u.id) }

# NO: Manual nil checking and verbose conditionals
if body.to_plain_text && !body.to_plain_text.empty?
  body.to_plain_text
elsif attachment && attachment.filename
  attachment.filename.to_s
else
  ""
end
```

### Guard Clauses and Early Returns
- **Controller guards** - `head :forbidden unless @book.editable?`
- **Method guards** - `return if content.blank?`
- **Positive flow preference** - Keep main logic unindented

### Memoization
- **Simple memoization** - `@platform ||= ApplicationPlatform.new(request.user_agent)`
- **Use sparingly** - Only for expensive operations

## Testing Philosophy

### Test Structure
- **Integration-focused** - Prefer `ActionDispatch::IntegrationTest` over unit tests
- **Fixture-driven** - Use fixtures over factories: `users(:david)`, `rooms(:designers)`
- **Simple setup blocks** - Minimal test setup, rely on fixtures

```ruby
class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in :kevin
  end
  
  test "index lists user's books" do
    get root_url
    assert_response :success
    assert_select "h2", text: "Handbook"
  end
end
```

### System Test Patterns
- **Multi-session testing** - `using_session("Kevin") do ... end`
- **Custom assertion helpers** - `assert_message_text`, `assert_book_listed`
- **Behavior-driven scenarios** - Test user workflows, not implementation

## Frontend Integration

### Stimulus Controller Patterns
- **Single responsibility** - One behavior per controller
- **Clear static declarations** - `static targets = ["dialog"]`, `static values = { url: String }`
- **Lifecycle methods** - Use `connect()`, `disconnect()` consistently

```javascript
export default class extends Controller {
  static targets = ["field", "output"]
  static values = { url: String }
  
  connect() {
    this.update()
  }
  
  update() {
    // single responsibility behavior
  }
}
```

### Turbo Usage
- **Turbo Streams for updates** - `format.turbo_stream { render }`
- **Progressive enhancement** - JavaScript enhances existing HTML
- **Broadcasting for real-time** - `turbo_stream_from @room, :messages`

### ERB Template Organization
- **Minimal view logic** - Logic in helpers or models, not templates
- **Semantic partials** - Name partials after domain concepts: `_message.html.erb`
- **Content blocks** - `content_for :sidebar` for layout sections

## Key Anti-Patterns to Avoid

### Over-Abstraction
- **Avoid service objects** - Business logic belongs in models
- **No form objects** - Use strong parameters and model validations
- **No presenter objects** - Use helpers and model methods
- **No command objects** - Use model methods and callbacks

### Verbose Code
- **No explicit boolean returns** - Use predicate methods that return truthy/falsy
- **No unnecessary conditionals** - Leverage Rails idioms like `presence`
- **No defensive programming** - Trust Rails conventions and validations

### Testing Anti-Patterns
- **No factory complexity** - Use simple fixtures
- **No over-mocking** - Test real integrations
- **No testing implementation details** - Test behavior, not internals

## Configuration & Conventions

### File Organization
- **Group by domain** - Related controllers, models, concerns together
- **Namespace concerns** - `User::Avatar` not `AvatarConcern`
- **STI in subdirectories** - `rooms/open.rb`, `rooms/direct.rb`

### Database Patterns
- **Sensible defaults** - `default: -> { Current.user }` in migrations
- **Enum with suffix** - `enum :level, %w[reader editor], suffix: true`
- **Polymorphic associations** - For flexible content types

### Security Patterns
- **Role-based authorization** - Simple role enums on user model
- **Current user checks** - `Current.user.can_administer?(@resource)`
- **Guard clauses** - Fail fast with `head :forbidden`

## Summary

Good Rails applications prioritize:
- **Terseness** - Express ideas in minimal, clear code
- **Domain focus** - Business concepts drive naming and structure  
- **Rails idioms** - Leverage framework patterns over custom abstractions
- **Pragmatism** - Choose simple solutions over architectural purity
- **Integration** - Test behavior, not implementation details
