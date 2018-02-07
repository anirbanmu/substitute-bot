require 'redd'
require 'sucker_punch'
require_relative 'config'

class SubstituteWorker
  include SuckerPunch::Job
  workers 4

  def perform(comment_id, comment_body)
    begin
      handle_new_comment(comment_id, comment_body)
    rescue Redd::Errors::APIError => e
      error = e.response.body[:json][:errors][0]
      raise unless error[0].downcase == 'ratelimit'
      reschedule_after_ratelimit(comment_id, comment_body, error[1])
    end
  end

  def reschedule_after_ratelimit(comment_id, comment_body, message)
    time = message.match(/\b(\d+)\s+(seconds|minutes|hours)/i).captures
    seconds = Integer(time[0])
    seconds *= 60 if time[1].downcase.start_with?('minute')
    seconds *= 60 * 60 if time[1].downcase.start_with?('hour')
    seconds += 5 # Add 5 seconds for good measure

    puts "Hit ratelimit error. Rescheduling to run in #{seconds} seconds. id: #{comment_id}"

    SubstituteWorker::perform_in(seconds, comment_id, comment_body)
  end

  private

  @@reddit_session = Concurrent::ThreadLocalVar.new(nil)

  def reddit_session
    @@reddit_session.value ||= Redd.it(reddit_session_params)
  end

  def handle_new_comment(comment_id, comment_body)
    command = self.class.scan_for_substitute_command(comment_body)
    return unless command

    comment = reddit_session.from_ids(comment_id).first


    parent = comment.parent
    return unless parent.is_a?(Redd::Models::Comment)

    # Don't respond to self comments
    return if reddit_session_params[:username] == comment.author.name.downcase
    return if reddit_session_params[:username] == parent.author.name.downcase

    substituted = self.class.substitute(parent.body, command[0], "**#{command[1]}**")
    return unless substituted

    reply = comment.reply(substituted +
                        "\n\n This was posted by a bot. Upvote me if you like what I did. [Source](#{bot_config[:source_url]})".gsub(/ /, ' ^^'))
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
