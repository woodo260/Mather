class CreateDecks < ActiveRecord::Migration[8.1]
  def change
    create_table :decks do |t|
      t.string :name,          null: false
      t.string :slug,          null: false
      t.text   :description
      t.boolean :builtin,      null: false, default: false
      t.string :session_token

      t.timestamps
    end

    add_index :decks, :slug, unique: true
    add_index :decks, :session_token
  end
end
