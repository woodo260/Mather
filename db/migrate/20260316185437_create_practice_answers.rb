class CreatePracticeAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_answers do |t|
      t.string  :session_token, null: false
      t.string  :question_type, null: false
      t.integer :difficulty,    null: false, default: 0
      t.boolean :correct,       null: false
      t.integer :time_taken_ms
      t.text    :prompt

      t.timestamps
    end

    add_index :practice_answers, :session_token
    add_index :practice_answers, [ :session_token, :created_at ]
  end
end
