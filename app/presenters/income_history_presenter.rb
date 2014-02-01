class IncomeHistoryPresenter < MovementHistoryPresenter
  def movement
    'Ingreso'
  end

  def details
    income_details
  end

  def details_col
    :income_details
  end

  def inventory_operation
    get_inventory_operation  if inventory_operation?
  end

  def inventory_operation?
    history_data_raw['income_details'].blank? &&
    extras.is_a?(Hash) &&
    balance_inventory('from').to_s != balance_inventory('to').to_s

  end

  def get_inventory_operation
    from = balance_inventory('from').to_s.to_d
    to = balance_inventory('to').to_s.to_d

    if from > to
      'Entrega de inventario'
    elsif to > from
      'Devolución inventario'
    end
  end
end
