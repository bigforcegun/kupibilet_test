bundle install

cp ./config/config.example.yml ./config/config.yml

setup config.yml

bundle exec ruby application.rb
RACK_ENV=production bundle exec ruby application.rb

