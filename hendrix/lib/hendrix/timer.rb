# frozen_string_literal: true

module Cnfs
  class << self
    def timers() = @timers ||= {}

    def with_timer(title = '', _level = :info)
      t_hash = Timer.append(title: title, start: Time.now).last
      # logger.send(level, "Start #{title} at #{t_hash[:start_time]}")
      result = yield
      t_hash[:end] = Time.now
      # logger.send(level, "Completed #{title} in #{t_hash[:end] - t_hash[:start]} seconds")
      result
    end
  end

  class Timer
    class << self
      # Kernel.at_exit { Cnfs.logger.info(Cnfs::Timer.table.join("\n")) }
      def timer() = @timer ||= []

      def append(**kwargs) = timer.append(kwargs)

      def diff
        timer.each do |t|
          t[:end] ||= Time.now

          t[:elapsed] = (t[:end] - t[:start]).round(2)
        end
      end

      def t_format(title, elapsed, percent = '', p_tot = '')
        title = title[0..59]
        percent = "#{percent}%" unless percent.blank?
        p_tot = "#{p_tot}%" unless p_tot.blank?
        "#{title}:#{' ' * (60 - title.length)}#{elapsed}s#{' ' * (10 - elapsed.to_s.length)}#{percent}" \
          "#{' ' * (10 - percent.to_s.length)}#{p_tot}"
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def table
        diff
        main = timer.shift
        total = main[:elapsed]
        p_tot = 0
        e_tot = 0
        t_ary = timer.each_with_object([]) do |timing, ary|
          title = timing[:title]
          elapsed = timing[:elapsed]
          e_tot += elapsed
          percent = (elapsed / total * 100).round(2)
          p_tot = (p_tot + percent).round(2)
          ary.append(t_format(title, elapsed, percent, p_tot))
        end
        str = t_format('Untracked', (total - e_tot).round(2), (100 - p_tot).round(2), '100')
        t_ary.append(str)
        t_ary.unshift(t_format(main[:title], main[:elapsed]))
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
