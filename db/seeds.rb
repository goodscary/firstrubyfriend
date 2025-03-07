# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "faker"

common_languages = %w[English Spanish French Portuguese Russian Chinese Hindi Arabic German Japanese]

file_path = Rails.root.join("lib", "data", "iso_languages.txt")
File.readlines(file_path).each do |line|
  alpha3, alpha2, _, english_name, french_name = line.strip.split("|")

  if common_languages.include?(english_name)
    Language.find_or_create_by(iso639_alpha3: alpha3) do |language|
      language.iso639_alpha2 = alpha2
      language.english_name = english_name
      language.french_name = french_name
      puts "Created #{english_name} language."
    end
  end
end

puts "Creating users..."
50.times do |i|
  User.create!(
    email: Faker::Internet.unique.email,
    password: "Secret1*3*5*",
    verified: [true, false].sample,
    city: Faker::Address.city,
    country_code: Faker::Address.country_code,
    lat: Faker::Address.latitude,
    lng: Faker::Address.longitude,
    demographic_year_of_birth: rand(1970..2000),
    demographic_year_started_ruby: rand(2005..2023),
    demographic_year_started_programming: rand(2000..2020),
    demographic_underrepresented_group: [true, false].sample
  )
  puts "Created user #{i + 1}"
end

# Select 30 users to be applicants
applicant_users = User.all.sample(30)
puts "Creating applicant questionnaires..."

applicant_users.each do |user|
  ApplicantQuestionnaire.create!(
    respondent_id: user.id,
    name: Faker::Name.name,
    work_url: Faker::Internet.url,
    currently_writing_ruby: [true, false].sample,
    where_started_coding: ["bootcamp", "self-taught", "university", "work"].sample,
    twitter_handle: "@#{Faker::Internet.username}",
    github_handle: Faker::Internet.username,
    personal_site_url: Faker::Internet.url,
    previous_job: Faker::Job.title,
    mentorship_goals: Faker::Lorem.paragraph,
    looking_for_career_mentorship: [true, false].sample,
    looking_for_code_mentorship: [true, false].sample,
    self_description: Faker::Lorem.paragraph,
    wnbrb_member: [true, false].sample
  )
  user.update!(requested_mentorship_at: Faker::Time.between(from: 6.months.ago, to: Time.now))
end

# Select 20 users to be mentors
mentor_users = (User.all - applicant_users).sample(20)
puts "Creating mentor questionnaires..."

mentor_users.each do |user|
  MentorQuestionnaire.create!(
    respondent_id: user.id,
    name: Faker::Name.name,
    company_url: Faker::Internet.url,
    twitter_handle: "@#{Faker::Internet.username}",
    github_handle: Faker::Internet.username,
    personal_site_url: Faker::Internet.url,
    previous_workplaces: Faker::Company.name,
    has_mentored_before: [true, false].sample,
    mentoring_reason: Faker::Lorem.paragraph,
    preferred_style_career: [true, false].sample,
    preferred_style_code: [true, false].sample
  )
  user.update!(available_as_mentor_at: Faker::Time.between(from: 6.months.ago, to: Time.now))
end

# Create mentorships with different states
puts "Creating mentorships..."
mentorship_states = ["active", "ended"]

15.times do
  mentor = mentor_users.sample
  applicant = applicant_users.sample

  # Skip if mentorship already exists for this pair
  next if Mentorship.exists?(mentor_id: mentor.id, applicant_id: applicant.id)

  standing = mentorship_states.sample

  Mentorship.create!(
    mentor_id: mentor.id,
    applicant_id: applicant.id,
    standing: standing,
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now),
    # Add email sent timestamps for some mentorships
    applicant_month_1_email_sent_at: (standing != "active") ? Faker::Time.between(from: 5.months.ago, to: 4.months.ago) : nil,
    mentor_month_1_email_sent_at: (standing != "active") ? Faker::Time.between(from: 5.months.ago, to: 4.months.ago) : nil
  )
end

puts "Seed completed successfully!"
puts "Created:"
puts "- #{User.count} users"
puts "- #{ApplicantQuestionnaire.count} applicants"
puts "- #{MentorQuestionnaire.count} mentors"
puts "- #{Mentorship.count} mentorships"

User.create!(
  email: "andy@goodscary.com",
  password: "Secret1*3*5*",
  city: "Brighton",
  country_code: "GB",
  lat: 50.827778,
  lng: -0.152778,
  demographic_year_started_ruby: 2023,
  demographic_year_started_programming: 2022,
  demographic_underrepresented_group: false,
  verified: true
)
