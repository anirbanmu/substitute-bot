# substitute-bot

A [Reddit](https://www.reddit.com/) bot that provides the ability to search and replace parent comments. Supports Ruby regular expression syntax.

## Setup
- Clone this repo
- `gem install bundler`
- `bundle install`
- `ruby bot.rb`

## Gems
### Bot
- sucker_punch (for threaded handling of comments)
- Redd (Reddit API wrapper)
- RSpec (for tests)
- redis-namespace

### Web
- Sinatra
- Haml

## Testing
- `bundle exec rspec`
