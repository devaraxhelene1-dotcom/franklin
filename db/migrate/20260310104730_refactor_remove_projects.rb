class RefactorRemoveProjects < ActiveRecord::Migration[8.1]
  def up
    # Move doc fields from projects to users
    add_column :users, :doc_content, :text
    add_column :users, :description_ai, :text

    # Add user_id to campaigns (replaces project_id)
    add_column :campaigns, :user_id, :bigint
    add_index :campaigns, :user_id
    add_foreign_key :campaigns, :users

    # Remove project_id from campaigns
    remove_foreign_key :campaigns, :projects
    remove_index :campaigns, :project_id
    remove_column :campaigns, :project_id

    # Remove project_id from chats
    remove_foreign_key :chats, :projects
    remove_index :chats, :project_id
    remove_column :chats, :project_id

    # Drop projects table
    drop_table :projects
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
