class CreateTvveets < ActiveRecord::Migration
  def change
    create_table :tvveets do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    add_index :tvveets, [:user_id, :created_at]
  end
end
