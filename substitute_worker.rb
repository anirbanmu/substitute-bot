require 'workers'

class SubstituteWorker < Workers::Worker
  private

  def event_handler(event)
    case event.command
    when :new_comment
      self.class.handle_new_comment event.data
    else
      super(event)
    end
  end

  def handle_new_comment(data)
  end

  def self.scan_for_substitute_command(text)
    return nil if !text
    text.match(/\As[\/#](.+)[\/#](.*)$/){ |m| return m.captures }
    nil
  end
end
