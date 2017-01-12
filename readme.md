# Dependencies

* Ruby 2.2.4
* Redis
* Rubygems
* Bundler


# Install

```
git clone https://github.com/bigforcegun/kupibilet_test.git
cd ./kupibilet_test
cp ./config/config.example.yml ./config/config.yml
bundle install
```

don't forget setup config/config.yml


# Starting up the server

```
bundle exec ruby application.rb
RACK_ENV=production bundle exec ruby application.rb
```

# Testing

```
# WARNING: The tests call flushdb on db 2 - this clears all keys! You can change test db in config.yml.


bundle exec rspec
```









