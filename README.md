# substitute-bot

A [Reddit](https://www.reddit.com/) bot that provides the ability to search and replace parent comments. Supports Ruby regular expression syntax.

## Setup
- Clone this repo
- `gem install bundler`
- `bundle install`

### Bot
- `ruby bot.rb`

### Web
- `ruby web.rb`

## Deployment on Heroku
- `heroku create`
- `heroku addons:create heroku-redis:hobby-dev`
- Set environment variables for Reddit integrations
  - `heroku config:set REDDIT_CLIENT_ID=<YOUR_CLIENT_ID>`
  - `heroku config:set REDDIT_CLIENT_SECRET=<YOUR_CLIENT_SECRET>`
  - `heroku config:set REDDIT_BOT_USERNAME=<YOUR_BOTS_USERNAME>`
  - `heroku config:set REDDIT_BOT_PASSWORD=<YOUR_BOTS_PASSWORD>`
- `git push heroku master`

## Gems
### Bot
- sucker_punch (for threaded handling of comments)
- Redd (Reddit API wrapper)
- RSpec (for tests)
- redis-namespace

### Web
- Sinatra
- Haml
- Sass

## Testing
- `bundle exec rspec`

## Live
You can check out the live running web frontend @ [https://substitute-bot.herokuapp.com/](https://substitute-bot.herokuapp.com/)