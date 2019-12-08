# frozen_string_literal: true

module App::Backend
  class StatusController < Cnfs::Command

    def execute
      compile_services
      show_results
    end

    # by layer, by service, etc which can be passed in as an option
    def compile_services
      services = application.layers.each_with_object({}) do |layer, hash|
        hash[layer.name] = []
        layer.services.order(:name).each do |service|
          (service.profiles || %w[server]).sort.each do |profile|
            service_name = profile.eql?('server') ? service.name : "#{service.name}_#{profile}"
            status = runtime.services.include?(service_name.to_s) ? 'Running' : 'Stopped'
            hash[layer.name].append([service_name, status])
          end
        end
      end
      # Format results into an array that TTY::Table can handle
      rows = services.values.max.size
      @result = Array.new(rows) do
        services.keys.each_with_object([]) do |key, ary|
          # pad results with nil if there is no value
          ary.append(services[key].shift || [nil, nil])
        end.flatten
      end
    end

    def show_results
      output.puts(display)
      require 'tty-table'
      header = application.layers.pluck(:name, :id).flatten
      table = TTY::Table.new(header: header, rows: result)

      # output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0])
      output.puts table.render(:basic, alignments: [:left, :left], padding: [0, 4, 0, 0]) do |renderer|
        renderer.border do
          mid          '='
          mid_mid      ' '
        end
      end
      output.puts "\nDeployment: #{deployment.name}\tTarget: #{target.name}\tApplication: #{application.name}"
    end
  end
end
