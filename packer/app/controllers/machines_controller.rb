# frozen_string_literal: true

class MachinesController < Thor
  include CommandHelper
  include TtyHelper

  cnfs_class_options :dry_run, :logging, :build
  class_before :initialize_project
  # class_before :ensure_valid_project

  desc 'console', 'Access a console on a VM (short-cut: c)'
  map %w[c] => :console
  def console(name = nil)
    execute('vagrant ssh', name: name, pty: true)
  end

  desc 'provision', 'Provision a VM'
  def provision(name = nil)
    execute('vagrant provision', name: name, pty: true)
  end

  private

  def execute(cmd, name: nil, pty: false)
    Dir.chdir(build.execute_path) do
      box_name = name || prompt.enum_select('Choose a box:', boxes.keys)
      raise Cnfs::Error, "Box #{box_name} not found" unless(box = boxes[box_name])

      Dir.chdir(box.path) do
        # on_conflict_paths(box.name)
        pty ? system(cmd) : command.run!({}, cmd)
      end
    end
  end

  # If action is 'up' or 'provision' then test for valid type, conflicting directories and box is available
  def on_conflict_paths(box_name)
    action = :up
    if %i[up provision clean].include?(action)
      conflict_paths(box_name).select(&:exist?).each do |path|
        path.rmtree if action.eql?(:clean) || prompt.yes?("Existing directory (possible confict) at #{path}. Remove?")
      end
    end
  end

  def conflict_paths(box_name)
    [
      "#{Dir.pwd}/.vagrant",
      "#{Dir.home}/.vagrant.d/boxes/#{box_name}",
      "#{Dir.home}/VirtualBox VMs/#{box_name}"
      # "#{Dir.home}/.vagrant.d/boxes/#{box_prefix}-VAGRANTSLASH-#{os_string}"
    ].map{ |path| Pathname.new(path) }
  end

  def boxes
    Dir.glob('**/*.box').each_with_object({}) do |box_path, hash|
      path = Pathname.new(box_path)
      name = path.split.last.to_s.delete_suffix('.box')
      # hash[name] = OpenStruct.new(name: name, path: Pathname.new(box_path).split.first, url: "file://#{Dir.pwd}/#{box_path}")
      hash[name] = OpenStruct.new(name: name, path: path.split.first) # , url: "file://#{path.split.last}")
    end
  end

  def build
    Cnfs.project.build
  end
end
