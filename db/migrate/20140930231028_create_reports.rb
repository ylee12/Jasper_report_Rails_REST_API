class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :report_name
      t.string :server_name
      t.integer :server_port
      t.string :login
      t.string :password
      t.string :organization_id
      t.string :report_format
      t.string :report_output_file_name
      t.string :path_to_report
      t.string :report_id

      t.timestamps
    end
  end
end
