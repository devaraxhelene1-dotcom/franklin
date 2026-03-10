class AdjustDocFields < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :doc_content
    remove_column :users, :description_ai
    add_column :campaigns, :doc_content, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
