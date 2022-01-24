# frozen_string_literal: true

class MainCommand < OneStack::MainCommand
  desc 'tree', 'hello'
  def tree() = puts(SolidRecord::DataPath.first.documents)

  desc 'console', 'console'
  def console() = execute(namespace: Hendrix)
end
