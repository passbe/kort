class ExecutionLogsComponent < ViewComponent::Base

  def initialize(execution)
    @execution = execution
  end

  def logs
    File.foreach(@execution.log_file, chomp: true).each_with_index do |line, index|
      yield index, *parse(line)
    end
  end

  def log_exist?
    @execution.log_file.exist?
  end

  # Take [time][severity] message and parse
  # If parsing fails, fallback to time=nil, severity=nil, message=full line
  def parse(line)
    matches = line.match(/\A\[(.*)\]\[(.*)\]\s(.*)\z/)
    if matches and matches.length == 4
      return matches.match(1), matches.match(2), matches.match(3)
    end
    return nil, nil, line
  end

  def log_line_css(severity)
    [
      "flex flex-row space-x-4 py-[1px] hover:bg-neutral-500/40",
      {
        "bg-red-900/25": ["ERROR", "FATAL"].include?(severity),
        "bg-orange-900/25": ["ANY", "WARN"].include?(severity)
      }
    ]
  end

end
