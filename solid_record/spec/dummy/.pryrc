# frozen_string_literal: true

module SolidRecord
  class << self
    def a = Association

    def di = Dir

    def ds = DataStore

    def f = File

    def p = Path

    def se = Segment

    def tree(id = 1) = se.find(id).to_tree
  end
end
