# frozen_string_literal: true

class Aws::ProviderView < OneStack::ProviderView
  def modify
    super
    mask_attr(:access_key_id)
    mask_attr(:secret_access_key)
    ask_attr(:account_id)
    enum_select_attr(:region, choices: model.regions)
  end
end
