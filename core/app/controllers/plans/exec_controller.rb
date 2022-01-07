# frozen_string_literal: true

module Plans
  class ExecController
    include Concerns::ExecController

    def execute(cmd = command)
      context.plans.group_by(&:provisioner).each do |provisioner, plans|
        provisioner.execute(cmd.to_sym, plans: plans)
      end
    end
  end
end
