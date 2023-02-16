module SolidRecord
  class << self
    def a() = Association

    def di() = Dir

    def do() = Document

    def ds() = DataStore

    def me() = ModelElement

    def p() = Path

    def re() = RootElement

    def se() = Segment

    def tree(id = 1) = se.find(id).to_tree
  end
end
