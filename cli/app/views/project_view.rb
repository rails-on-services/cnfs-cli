# frozen_string_literal: true

class ProjectView < ApplicationView
  def create
    raise Cnfs::Error, 'Create can only be called on new instances' if model.persisted?

    model.name = ask('name', value: '') if model.name.nil?
    load_components(model, [], 'project') if yes?('My project has components?')
    model.x_components = all_selected.uniq.each_with_object([]) { |key, ary| ary.append({ name: key }) }
    model.root_tree
    return unless yes?("\nSave changes?")
  end

  def all_selected
    @all_selected ||= []
  end

  def load_components(obj, selected, title)
    available = components(selected)
    c_name = available.size.eql?(1) ? available.pop : select('Component type', available, filter: true)
    selected << c_name
    all_selected << c_name
    multi_select('name', send(c_name.to_sym)).each do |name|
      new_obj = Component.new(name: name, c_name: c_name)
      obj.components << new_obj
      if available.size.positive? && yes?("Does the #{title}'s #{name} #{c_name} have components?")
        load_components(new_obj, selected.dup, "#{name} #{c_name}")
      end
    end
    selected
  end

  def edit
    # model.name = view_select('name', %w[data this that], 'this')
    # ask_hash(:paths)
    model.x_components = model.x_components.each_with_object([]) do |comp, ary|
      ab = comp.each_with_object({}) do |(key, value), hash|
        hash[key] = ask(key, value: value)
      end
      ary.append(ab)
    end
    # binding.pry
  end

  private

	def components(selected)
    %w[environment namespace stack target] - selected
    # %w[environment namespace stack target].each_with_object([]) do |key, ary|
    #   hash = { name: key }
    #   hash.merge!(disabled: '(already selected)') if selected.include?(key)
    #   ary.append(hash)
    # end
  end

	def environment
    %w[development test staging production]
  end

	def namespace
    %w[default other]
  end

	def stack
    %w[backend frontend pipeline warehouse]
  end

	def target
    %w[cluster instance local]
  end
end
