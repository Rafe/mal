require "readline"

module MalReadline
  @@history_loaded = false

  def self.history_file
    "#{ENV['HOME']}/.history"
  end

  def self.history_loadable?
    @@history_loaded && File.exist?(history_file)
  end

  def self.load_history
    @@history_loaded = true
    if File.readable?(file)
      File.readlines(history_file).each do |line|
        Readline::HISTORY.push(line.chomp)
      end
    end
  end

  def self.write_history(line)
    if File.writable?(history_file)
      File.open(history_file, 'a+') do |file|
        f.write(line+"\n")
      end
    end
  end

  def self.readline(prompt)
    load_history if history_loadable?

    if line = Readline.readline(prompt, true)
      write_history(line)
      line
    else
      nil
    end
  end
end
