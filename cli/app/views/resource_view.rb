# frozen_string_literal: true

class ResourceView < ApplicationView
  extend Forwardable

  def create
    raise Cnfs::Error, 'Create can only be called on new instances' if model.persisted?

    model.name = ask('name', value: '') if model.name.nil?
  end

  # def_delegator :model, :blueprint
  # %i[builder environment provider runtime].each do |meth|
  #   def_delegator :blueprint, meth
  # end

  # def render(obj)
  #   @obj = obj
  #   obj.class.stored_attributes.keys.each_with_object({}) do |key, hash|
  #     hash[key] = obj.class.stored_attributes[key].each_with_object({}) do |q, sub_hash|
  #       sub_hash[q] = ask(q)
  #     end
  #   end
  # end

  # def attributes
  #   obj.class.stored_attributes[:config]
  # end
end
