class AddMissingDatabaseIndexes < ActiveRecord::Migration[8.0]
  def change
    # Mentorship indexes for foreign key lookups
    add_index :mentorships, :mentor_id, if_not_exists: true
    add_index :mentorships, :applicant_id, if_not_exists: true

    # Composite index for uniqueness - one active mentorship per pair
    add_index :mentorships, [:mentor_id, :applicant_id],
      unique: true,
      name: "index_mentorships_on_mentor_and_applicant",
      if_not_exists: true

    # Index for finding active mentorships quickly
    add_index :mentorships, :standing, if_not_exists: true

    # Composite index for finding active mentorships by user
    add_index :mentorships, [:mentor_id, :standing],
      name: "index_mentorships_on_mentor_and_standing",
      if_not_exists: true
    add_index :mentorships, [:applicant_id, :standing],
      name: "index_mentorships_on_applicant_and_standing",
      if_not_exists: true

    # User languages - ensure unique language per user
    add_index :user_languages, [:user_id, :language_id],
      unique: true,
      name: "index_user_languages_on_user_and_language",
      if_not_exists: true

    # Questionnaire indexes for faster lookups
    add_index :mentor_questionnaires, :respondent_id,
      unique: true,
      if_not_exists: true
    add_index :applicant_questionnaires, :respondent_id,
      unique: true,
      if_not_exists: true

    # Events index for user activity queries
    add_index :events, [:user_id, :created_at],
      name: "index_events_on_user_and_created_at",
      if_not_exists: true
    add_index :events, :action, if_not_exists: true

    # Sessions index for active session queries
    add_index :sessions, [:user_id, :created_at],
      name: "index_sessions_on_user_and_created_at",
      if_not_exists: true

    # User indexes for matching queries
    add_index :users, :available_as_mentor_at, if_not_exists: true
    add_index :users, :requested_mentorship_at, if_not_exists: true
    add_index :users, :verified, if_not_exists: true

    # Composite index for geographic queries (already exists but let's ensure)
    # add_index :users, [:lat, :lng] - already exists in schema

    # Index for finding unsubscribed users
    add_index :users, [:unsubscribed_at, :unsubscribed_reason],
      name: "index_users_on_unsubscribed",
      if_not_exists: true
  end
end
