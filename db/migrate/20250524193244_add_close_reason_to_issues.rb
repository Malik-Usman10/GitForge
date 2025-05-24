class AddCloseReasonToIssues < ActiveRecord::Migration[8.0]
  def change
    add_column :issues, :close_reason, :text
  end
end
