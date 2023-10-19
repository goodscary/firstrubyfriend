# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

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
