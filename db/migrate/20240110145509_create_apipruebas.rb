class CreateApipruebas < ActiveRecord::Migration[7.1]
  def change
    create_table :apipruebas do |t|
      t.string :username
      t.string :string

      t.timestamps
    end
  end
end
