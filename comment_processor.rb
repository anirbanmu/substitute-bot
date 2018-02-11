require 'redd'
require 'sucker_punch'
require_relative 'globals'
require_relative 'reply_store'

class CommentProcessor
  include SuckerPunch::Job
  workers 4

  def perform(comment_id, comment_body)
    begin
      self.class.handle_new_comment(comment_id, comment_body)
    rescue Redd::Errors::APIError => e
      error = e.response.body[:json][:errors][0]
      raise unless error[0].downcase == 'ratelimit'
      self.class.reschedule_after_ratelimit(comment_id, comment_body, error[1])
    end
  end

  private

  @@reddit_session = Concurrent::ThreadLocalVar.new(nil)

  def self.reddit_session
    @@reddit_session.value ||= Redd.it(reddit_session_params)
  end

  def self.handle_new_comment(comment_id, comment_body)
    command = scan_for_substitute_command(comment_body)
    return unless command

    comment = reddit_session.from_ids(comment_id).first
    requester = comment.author
    parent = get_parent_comment(comment)
    return unless parent

    # Don't respond to self comments
    return unless should_respond(reddit_session_params[:username], requester.name.downcase, parent.author.name.downcase)

    substituted = substitute(parent.body, command[0], "**#{command[1]}**")
    return unless substituted

    reply = comment.reply(substituted + blurb)
    puts "Posted reply. id: #{reply.name}"

    ReplyStore::save_reply_details(reply.name,
                                   id: reply.id,
                                   created_at: reply.created_at.to_i,
                                   body_html: reply.body_html,
                                   requester: requester.name,
                                   link_id: reply.link.id)
  end

  def self.get_parent_comment(comment)
    parent = comment.parent
    parent.is_a?(Redd::Models::Comment) ? parent : nil
  end

  def self.should_respond(bot_user, comment_author, parent_comment_author)
    comment_author != bot_user && parent_comment_author != bot_user
  end

  def self.reschedule_after_ratelimit(comment_id, comment_body, message)
    time = message.match(/\b(\d+)\s+(seconds|minutes|hours)/i).captures
    seconds = Integer(time[0])
    seconds *= 60 if time[1].downcase.start_with?('minute')
    seconds *= 60 * 60 if time[1].downcase.start_with?('hour')
    seconds += 5 # Add 5 seconds for good measure

    puts "Hit ratelimit error. Rescheduling to run in #{seconds} seconds. id: #{comment_id}"

    CommentProcessor::perform_in(seconds, comment_id, comment_body)
  end

  def self.blurb
    "\n\n This was posted by a bot. Upvote me if you like what I did. [Source](#{bot_config[:source_url]})".gsub(/ /, ' ^^')
  end

  def self.scan_for_substitute_command(text)
    return nil if !text
    text.match(/\As([\/#])(.+)\1(.*)$/) { |m| return m.captures[1..2] }
    nil
  end

  def self.substitute(original, search, replacement)
    modified = original.gsub(Regexp.new(search), replacement)
    return nil if modified == original
    modified
  end
end
