In this article we will show you how to start you development using  [Faalis](https://github.com/Yellowen/Faalis) platform.

## Dependencies

* Add this to your Gemfile:

```ruby
group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem "capybara"
  gem "factory_girl_rails", "~> 4.0", :require => false
  gem "database_cleaner"
  gem "email_spec"
  gem "cucumber-rails", :require => false
end
```

## Installation

1. First add `faalis` to your `Gemfile` like

```ruby
# Make sure to add this source to you Gemfile
source 'http://rails-assets.org'

gem "faalis"
```
**Note**: Make sure to add `source 'http://rails-assets.org'` to your `Gemfile`.

2. Iinstall your project dependencies using `bundle`

```ruby
bundle install
```

3. Add this to your `config/environments/development.rb`

```ruby
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
```

In production, `:host` should be set to the actual host of your application.

4. Ensure you have flash messages in `app/views/layouts/application.html.erb`.
For example (Only if you want to change default layout):

```rhtml
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```
5. Perfrom `rails generate faalis:install_all` to copy necessary files.
6. Perform `rake db:migrate` and enjoy Faalis
