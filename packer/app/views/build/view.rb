# frozen_string_literal: true

class Build::View < Cnfs::TTY::Prompt
  include ViewHelper

  def create
    collect_model do
      key(:name).ask('Name:')
      key(:builders).values { create_child(self, :builder, :create) } while @prompt.yes?('Add builder?')
      key(:provisioners).values { create_child(self, :provisioner, :create) } while @prompt.yes?('Add provisioner?')
      key(:post_processors).values { create_child(self, :post_processor, :create) } while @prompt.yes?('Add post-processor?')
    end
  end

  def create_child(prompt, view_for, method)
    index_name = "@#{view_for}_index"
    index = instance_variable_get(index_name) || instance_variable_set(index_name, 0)
    index = instance_variable_set(index_name, index + 1)

    prompt.key(:name).ask('Name:')
    prompt.answer_set(:order, index)

    child_model_type = prompt.key(:type).enum_select('Type:', list_types(view_for))
    child_model = child_model_type.safe_constantize.new(build: model)
    # This sets model to model for Builder::VirtualboxOvf
    child_model.view_class.new(prompt: prompt, model: child_model).send(method)
  end

  def update
    collect_model do
      key(:builders).values { update_child(self, :builder, :update) } while @prompt.has_next?(:builders)
      key(:provisioners).values { update_child(self, :provisioner, :update) } while @prompt.has_next?(:provisioners)
      key(:post_processors).values { update_child(self, :post_processor, :update) } while @prompt.has_next?(:post_processors)
    end
  end

  def update_child(prompt, view_for, method)
    prompt.answer_set(:build, model)
    child_model = next_record(view_for.to_s.pluralize)
    prompt.assign_answers(child_model, :name, :order, :type)
    child_model.view_class.new(prompt: prompt, model: child_model).send(method)
  end
end
