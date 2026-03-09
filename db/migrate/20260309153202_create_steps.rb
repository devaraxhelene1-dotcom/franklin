class CreateSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :steps do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :day
      t.text :generated_content
      t.string :status

      t.timestamps
    end
  end
end
