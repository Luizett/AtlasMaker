class CreateAtlases < ActiveRecord::Migration[8.0]
  def change
    create_table :atlases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.json :coords

      t.timestamps
    end
  end
end
