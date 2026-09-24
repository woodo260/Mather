class CreateCardReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :card_reviews do |t|
      t.string     :session_token,    null: false
      t.references :card,             null: false, foreign_key: true
      t.float      :ease_factor,      null: false, default: 2.5
      t.integer    :interval_days,    null: false, default: 0
      t.integer    :repetitions,      null: false, default: 0
      t.date       :due_on
      t.datetime   :last_reviewed_at

      t.timestamps
    end

    add_index :card_reviews, [ :session_token, :card_id ], unique: true
    add_index :card_reviews, [ :session_token, :due_on ]
  end
end
