json.array!(@reports) do |report|
  json.extract! report, :id, :report_name, :server_name, :server_port, :login, :password, :organization_id, :report_format, :report_output_file_name, :path_to_report, :report_id
  json.url report_url(report, format: :json)
end
