# Test helpers for working with prefixed IDs

module PrefixedIdHelpers
  # Helper to get a model instance by its prefixed ID from fixtures
  # Example: find_by_prefixed_id(users(:basic))
  def find_by_prefixed_id(record)
    record.class.find(record.to_param)
  end

  # Helper to assert a prefixed ID has the correct format
  # Example: assert_prefixed_id_format(user, "usr")
  def assert_prefixed_id_format(record, expected_prefix)
    prefixed_id = record.to_param
    assert prefixed_id.start_with?("#{expected_prefix}_"),
      "Expected #{record.class.name} prefixed ID to start with '#{expected_prefix}_', got '#{prefixed_id}'"
    assert_match(/^#{expected_prefix}_[a-zA-Z0-9]+$/, prefixed_id,
      "Expected #{record.class.name} prefixed ID to match format, got '#{prefixed_id}'")
  end

  # Helper to assert finding by prefixed ID works
  # Example: assert_findable_by_prefixed_id(user)
  def assert_findable_by_prefixed_id(record)
    found = record.class.find(record.to_param)
    assert_equal record, found,
      "Expected to find #{record.class.name} by prefixed ID '#{record.to_param}'"
  end

  # Helper to test relationships work with prefixed IDs
  # Example: assert_relationship_with_prefixed_ids(mentorship, :mentor, users(:mentor))
  def assert_relationship_with_prefixed_ids(parent_record, association_name, expected_record)
    associated = parent_record.send(association_name)
    assert_equal expected_record, associated,
      "Expected #{association_name} relationship to work with prefixed IDs"
    assert_respond_to associated, :to_param,
      "Expected associated #{association_name} to respond to to_param"
  end

  # Helper to generate a path with prefixed ID
  # Example: path_with_prefixed_id(user_path, user)
  def path_with_prefixed_id(path_method, record)
    send(path_method, record.to_param)
  end

  # Helper to assert a collection of records all have prefixed IDs
  # Example: assert_collection_has_prefixed_ids(User.all, "usr")
  def assert_collection_has_prefixed_ids(collection, expected_prefix)
    collection.each do |record|
      assert_prefixed_id_format(record, expected_prefix)
    end
  end

  # Helper to find multiple records by their prefixed IDs
  # Example: find_all_by_prefixed_ids(User, [user1.to_param, user2.to_param])
  def find_all_by_prefixed_ids(model_class, prefixed_ids)
    prefixed_ids.map { |pid| model_class.find(pid) }
  end

  # Helper to assert prefixed ID uniqueness
  # Example: assert_prefixed_id_uniqueness([user1, user2, user3])
  def assert_prefixed_id_uniqueness(records)
    prefixed_ids = records.map(&:to_param)
    assert_equal prefixed_ids.uniq.length, prefixed_ids.length,
      "Expected all prefixed IDs to be unique"
  end

  # Helper to test prefixed ID persistence across database operations
  # Example: assert_prefixed_id_persistent(user) { user.update!(name: "New Name") }
  def assert_prefixed_id_persistent(record)
    original_prefixed_id = record.to_param
    yield if block_given?
    record.reload
    assert_equal original_prefixed_id, record.to_param,
      "Expected prefixed ID to remain consistent after database operation"
  end
end