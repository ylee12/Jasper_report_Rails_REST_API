require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @report = reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post :create, report: { login: @report.login, organization_id: @report.organization_id, password: @report.password, path_to_report: @report.path_to_report, report_format: @report.report_format, report_id: @report.report_id, report_name: @report.report_name, report_output_file_name: @report.report_output_file_name, server_name: @report.server_name, server_port: @report.server_port }
    end

    assert_redirected_to report_path(assigns(:report))
  end

  test "should show report" do
    get :show, id: @report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report
    assert_response :success
  end

  test "should update report" do
    patch :update, id: @report, report: { login: @report.login, organization_id: @report.organization_id, password: @report.password, path_to_report: @report.path_to_report, report_format: @report.report_format, report_id: @report.report_id, report_name: @report.report_name, report_output_file_name: @report.report_output_file_name, server_name: @report.server_name, server_port: @report.server_port }
    assert_redirected_to report_path(assigns(:report))
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, id: @report
    end

    assert_redirected_to reports_path
  end
end
