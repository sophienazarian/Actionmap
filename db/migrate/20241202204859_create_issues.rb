# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.string :name

      t.timestamps
    end
  end
end
