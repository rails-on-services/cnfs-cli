# frozen_string_literal: true

module OneStack
  class PlansController < ApplicationController
    def execute(cmd = command)
      context.plans.group_by(&:provisioner).each do |provisioner, plans|
        provisioner.execute(cmd.to_sym, plans: plans)
      end
    end
  end
end
