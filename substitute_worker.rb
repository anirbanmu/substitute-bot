require 'workers'
require 'redd'
require_relative 'config'

class SubstituteWorker < Workers::Worker
  private

  def event_handler(event)
    case event.command
    when :new_comment
      handle_new_comment event.data
    else
      super(event)
    end
  end

  def reddit_session
    @reddit_session ||= Redd.it(reddit_session_params)
  end

  def handle_new_comment(data)
    command = self.class.scan_for_substitute_command(data[:body])
    return unless command

    comment = reddit_session.from_ids(data[:id]).first
    parent = comment.parent
    return unless parent.is_a?(Redd::Models::Comment)

    substituted = self.class.substitute(parent.body, command[0], "\*\*#{command[1]}\*\*")
    return unless substituted

    reply = comment.reply(substituted +
                          "\n\n This was posted by a bot. Upvote me if you like what I did. [Source](#{bot_config[:source_url]})".gsub(/\s/, ' ^^'))
    puts "Posted reply. id: #{reply.name}"
  end

  def self.scan_for_substitute_command(text)
    return nil if !text
    text.match(/\As[\/#](.+)[\/#](.*)$/){ |m| return m.captures }
    nil
  end

  def self.substitute(original, search, replacement)
    modified = original.gsub(Regexp.new(search), replacement)
    return nil if modified == original
    modified
  end
end
