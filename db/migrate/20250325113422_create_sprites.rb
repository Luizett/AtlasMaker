class CreateSprites < ActiveRecord::Migration[8.0]
  def change
    create_table :sprites do |t|
      t.references :atlas, null: false, foreign_key: true

      t.timestamps
    end
  end
end
