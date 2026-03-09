class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :project, null: false, foreign_key: true
      t.string :status
      t.string :title
      t.string :icp
      t.text :channels
      t.text :angles

      t.timestamps
    end
  end
end
