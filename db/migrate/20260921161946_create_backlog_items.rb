class CreateBacklogItems < ActiveRecord::Migration[8.1]
  def change
    create_table :backlog_items do |t|
      t.timestamps
    end
  end
end
