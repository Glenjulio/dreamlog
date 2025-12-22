class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :context # Pour stocker le contexte global de la conversation (optionnel)
      t.boolean :archived, default: false

      t.timestamps
    end

    add_index :conversations, [:user_id, :created_at]
    add_index :conversations, :archived
  end
end
