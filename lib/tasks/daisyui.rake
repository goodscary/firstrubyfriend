require "net/http"
require "uri"
require "timeout"

namespace :daisyui do
  desc "Install or update DaisyUI plugin"
  task :install do
    puts "railstemplates.org"
    puts "🌼 Installing DaisyUI..."

    # Ensure directory exists
    FileUtils.mkdir_p("app/assets/tailwind")

    # Download DaisyUI plugin
    download_daisyui_files

    # Update Tailwind config
    update_tailwind_config

    # Build CSS
    puts "🔨 Building CSS..."
    system("bin/rails tailwindcss:build")

    puts "✅ DaisyUI installation complete!"
    puts "You can now use DaisyUI components like:"
    puts '  <button class="btn btn-primary">Click me</button>'
    puts '  <div class="card bg-base-100 shadow-xl">...</div>'
    puts "\nDocs: https://daisyui.com/"
  end

  desc "Download DaisyUI plugin from CDN"
  task :download do
    puts "railstemplates.org"
    puts "📥 Downloading DaisyUI plugin..."

    FileUtils.mkdir_p("app/assets/tailwind")
    download_daisyui_files
  end

  desc "Show DaisyUI installation status"
  task :status do
    puts "railstemplates.org"
    puts "🌼 DaisyUI Status"

    # Check plugin file
    plugin_path = "app/assets/tailwind/daisyui.js"
    if File.exist?(plugin_path) && File.read(plugin_path).include?("daisyUI")
      puts "✅ Plugin: #{plugin_path} (#{File.size(plugin_path)} bytes)"
    else
      puts "❌ Plugin not found or invalid"
    end

    # Check Tailwind config
    config_path = "app/assets/tailwind/application.css"
    if File.exist?(config_path) && File.read(config_path).include?('@plugin "./daisyui.js"')
      puts "✅ Tailwind config includes DaisyUI"
    else
      puts "❌ DaisyUI not configured in Tailwind"
    end

    puts "\nTo install/update: rake daisyui:install"
  end

  desc "Install DaisyUI form builder"
  task :form_builder do
    puts "railstemplates.org"
    puts "📝 Installing DaisyUI form builder..."

    # Ensure app/forms directory exists
    FileUtils.mkdir_p("app/forms")

    # Download the form builder file
    form_builder_url = "https://railstemplates.org/daisyui/daisy_ui_form_builder"
    form_builder_path = "app/forms/daisy_ui_form_builder.rb"
    config_path = "app/assets/tailwind/application.css"

    begin
      puts "📥 Downloading form builder from #{form_builder_url}..."
      uri = URI(form_builder_url)
      form_builder_content = fetch_with_redirects(uri)

      # Write the form builder file
      File.write(form_builder_path, form_builder_content)
      puts "✅ Downloaded and saved to #{form_builder_path}"

      # Update Tailwind config to include forms directory
      if File.exist?(config_path)
        content = File.read(config_path)
        lines = content.lines
        insert_index = lines.rindex { |line| line.strip.start_with?("@source") } ||
          lines.find_index { |line| line.strip.start_with?("@import") }

        new_content = <<~CSS
          @source "../../../app/forms/**/*.rb";
        CSS

        if insert_index && !content.include?("app/forms/**/*.rb")
          lines.insert(insert_index + 1, new_content)
          File.write(config_path, lines.join)
          puts "✅ Updated Tailwind v4 config to include formbuilder"
        end
      end
    rescue => e
      puts "❌ Failed to download form builder: #{e.message}"
      puts "   You can manually download from: #{form_builder_url}"
      puts "   And save it to: #{form_builder_path}"
      exit 1
    end

    # Ask if user wants to configure ApplicationController
    puts "\n❓ Configure ApplicationController to use DaisyUI form builder by default? (y/n)"
    print "   This will add 'default_form_builder DaisyUiFormBuilder' to ApplicationController: "

    response = STDIN.gets.chomp.downcase
    if response == "y" || response == "yes"
      controller_path = "app/controllers/application_controller.rb"
      if File.exist?(controller_path)
        content = File.read(controller_path)
        if content.include?("default_form_builder")
          puts "⚠️  ApplicationController already has a default_form_builder configured"
        else
          # Add the configuration after the class definition
          updated_content = content.sub(
            /(class ApplicationController < ActionController::Base\n)/,
            "\\1  default_form_builder DaisyUiFormBuilder\n"
          )
          File.write(controller_path, updated_content)
          puts "✅ Added default_form_builder to ApplicationController"
        end
      else
        puts "❌ ApplicationController not found at #{controller_path}"
      end
    end

    puts "\n✅ DaisyUI form builder installation complete!"
    puts "Usage:"
    puts "  <%= form_with model: @user do |f| %>"
    puts '    <%= f.text_field :name, class: "input-bordered", placeholder: "Enter name" %>'
    puts '    <%= f.submit "Save", class: "btn-success" %>'
    puts "  <% end %>"
  end

  private

  def download_daisyui_files
    plugin_path = "app/assets/tailwind/daisyui.js"
    theme_plugin_path = "app/assets/tailwind/daisyui-theme.js"

    begin
      puts "📥 Downloading DaisyUI plugin..."
      uri = URI("https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js")
      content = fetch_with_redirects(uri)
      File.write(plugin_path, content, mode: "wb")
      puts "✅ Downloaded DaisyUI plugin (#{File.size(plugin_path)} bytes)"
      puts "📥 Downloading DaisyUI theme plugin..."
      uri = URI("https://github.com/saadeghi/daisyui/releases/latest/download/daisyui-theme.js")
      content = fetch_with_redirects(uri)
      File.write(theme_plugin_path, content, mode: "wb")
      puts "✅ Downloaded DaisyUI theme plugin (#{File.size(theme_plugin_path)} bytes)"
    rescue Net::HTTPError, Timeout::Error, SocketError => e
      puts "❌ Download failed: #{e.message}"
      puts "   Manual download: https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js"
      puts "   Save as: #{plugin_path}"
    end
  end

  def fetch_with_redirects(uri, limit = 5)
    raise "Too many redirects" if limit == 0

    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = response["location"]
      new_uri = URI.join(uri.to_s, location)
      fetch_with_redirects(new_uri, limit - 1)
    else
      raise Net::HTTPError.new("HTTP error: #{response.code}", response)
    end
  end

  def update_tailwind_config
    config_path = "app/assets/tailwind/application.css"

    unless File.exist?(config_path)
      puts "❌ Tailwind config not found: #{config_path}"
      return
    end

    content = File.read(config_path)

    if content.include?('@plugin "./daisyui.js"')
      puts "✅ DaisyUI already configured"
      return
    end

    puts "⚙️  Adding DaisyUI to Tailwind config..."

    if content.include?('@import "tailwindcss"')
      # Tailwind v4 - add after @source lines or @import
      lines = content.lines
      insert_index = lines.rindex { |line| line.strip.start_with?("@source") } ||
        lines.find_index { |line| line.strip.start_with?("@import") }

      new_content = <<~CSS
        @source "../../../public/*.html";
        @source "../../../app/helpers/**/*.rb";
        @source "../../../app/javascript/**/*.js";
        @source "../../../app/views/**/*";

        @plugin "./daisyui.js";

        /* Optional for custom themes – Docs: https://daisyui.com/docs/themes/#how-to-add-a-new-custom-theme */
        @plugin "./daisyui-theme.js"{
          /* custom theme here */
        }
      CSS

      if insert_index
        lines.insert(insert_index + 1, new_content)
        File.write(config_path, lines.join)
        puts "✅ Updated Tailwind v4 config"
      end
    else
      puts "❌ Tailwind config error. Maybe not v4?"
    end
  end
end
