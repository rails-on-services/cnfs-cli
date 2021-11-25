# frozen_string_literal: true

module Cnfs
  class Timer
    class << self
      def timer
        @timer ||= []
      end

      def append(**kwargs) = timer.append(kwargs)

      def diff
        timer.each do |t|
          t[:end] ||= Time.now

          t[:elapsed] = (t[:end] - t[:start]).round(2)
        end
      end

      def format(k, e, p = '', p_tot = '')
        k = k[0..59]
        p = "#{p}%" unless p.blank?
        p_tot = "#{p_tot}%" unless p_tot.blank?
        "#{k}:#{' ' * (60 - k.length)}#{e}s#{' ' * (10 - e.to_s.length)}#{p}#{' ' * (10 - p.to_s.length)}#{p_tot}"
      end

      def table
        diff
        main = timer.shift
        total = main[:elapsed]
        p_tot = 0
        e_tot = 0
        ary = timer.each_with_object([]) do |timing, ary|
          title = timing[:title]
          elapsed = timing[:elapsed]
          e_tot += elapsed
          percent = (elapsed / total * 100).round(2)
          p_tot = (p_tot + percent).round(2)
          ary.append(format(title, elapsed, percent, p_tot))
        end
        ary.append(format('Untracked', (total - e_tot).round(2), (100 - p_tot).round(2), '100'))
        ary.unshift(format(main[:title], main[:elapsed]))
      end
    end

  end
  class << self
    def with_timer(title = '', level = :info)
      t_hash = Timer.append(title: title, start: Time.now).last
      # logger.send(level, "Start #{title} at #{t_hash[:start_time]}")
      result = yield
      t_hash[:end] = Time.now
      # logger.send(level, "Completed #{title} in #{t_hash[:end] - t_hash[:start]} seconds")
      result
    end

    def with_profiling
      unless ENV['CNFS_PROF']
        yield
        return
      end

      require 'ruby-prof'
      RubyProf.start
      yield
      results = RubyProf.stop
      File.open("#{Dir.home}/cnfs-cli-prof.html", 'w+') { |file| RubyProf::GraphHtmlPrinter.new(results).print(file) }
    end

    # Cnfs.logger.compare_levels(:info, :debug) => :gt
    def silence_output(unless_logging_at = :debug)
      rs = $stdout
      $stdout = StringIO.new if logger.compare_levels(config.logging, unless_logging_at).eql?(:gt)
      yield
      $stdout = rs
    end

    def cli_mode
      @cli_mode ||= set_cli_mode
    end

    def set_cli_mode
      mode = config.dev ? 'development' : 'production'
      ActiveSupport::StringInquirer.new(mode)
    end
  end
end
