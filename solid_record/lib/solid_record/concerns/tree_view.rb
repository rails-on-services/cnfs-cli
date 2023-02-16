# frozen_string_literal: true

module SolidRecord
  module TreeView
    extend ActiveSupport::Concern

    def to_tree = puts(TTY::Tree.new(tree_label => as_tree).render)

    def as_tree
      send(tree_assn).each_with_object([]) do |item, ary|
        ary.append(item.send(tree_assn).empty? ? item.tree_label : { item.tree_label => item.as_tree })
      end
    end
  end
end
