class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.references :deck,     null: false, foreign_key: true
      t.text    :front,       null: false
      t.text    :back,        null: false
      t.integer :position,    null: false, default: 0

      t.timestamps
    end
  end
end
