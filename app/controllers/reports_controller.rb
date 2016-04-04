class ReportsController < ApplicationController
  #before_action :set_report, only: [:show, :edit, :update, :destroy]
  
  # for working with RESTul services
  require 'rest_client'
  
  # for base64 encoding
  require 'base64'
  
  # for escaping chars in URL
  require 'uri'
  
  
  
  #define constants
  COUNTY_CODE = :COUNTY_CDE
  STATUS_CODE = :statusCdes
  SPONSOR_CODE = :sponsorCdes
  


  # GET /reports
  # GET /reports.json
  def index
    # @reports = Report.all
    
    redirect_to '/'
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    redirect_to '/'
  end

  # GET /reports/new
  def new
    
    redirect_to '/'
    
    #@report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    
    redirect_to '/'
    
=begin   
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
    
=end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    
    redirect_to '/'
    
=begin
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
    
=end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    
    
    redirect_to '/'
    
=begin
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
    
=end
  end
  
  
  def run   
     @report = Report.new
  end
  
  def generate_report
    
    #init variables
    @county = nil
    county_str = ""
    
    @sponsor = nil
    sponsor_str = ""
    
    @status = nil
    status_str = ""
    
    
    
    # retrieve the parameters from input field
    retrieve_params(params)
    
    
    #if there is no repeort name to run, just return
    if @path_to_report.empty?
      render :text => "No report name specified, nothing to run".html_safe
      return
    end
    
    #print some for debugging output
    #Rails.logger.info "Report_id is #{@report_id}"
    #Rails.logger.info "server_name is #{@server_name}"
    
  
    # encode the report's user name and password in HTTP header for basic authentication
    user_auth_str = "#{@login}|#{@organization_id}"        
    auth = "Basic " + Base64::strict_encode64("#{user_auth_str}:#{@password}") 
    
    
    #build the county param query string
    if @county != nil
      
      county_str = build_query_string(@county, COUNTY_CODE)
      
      Rails.logger.debug "*************County_str is #{county_str}"
      
    end
        
    
    if @sponsor != nil
      
      sponsor_str = build_query_string(@sponsor, SPONSOR_CODE)
      
      Rails.logger.debug "*************Sponsor_str is #{sponsor_str}"
      
    end
    
    
    if @status != nil
      
      status_str = build_query_string(@status, STATUS_CODE)
      
      Rails.logger.debug "*************Status_str is #{status_str}"
      
    end
    
    
=begin    
    #determine the output format for the report
    output_format = ""
    
    if @report_format == "pdf"
      #generate output in html format, then use pdfkit converts the output back to pdf. This is because pdfkit's limitation.
      #output_format = 'html'
      output_format = @report_format
    else
      output_format = @report_format
    end
=end
   
    # build the report URL
    report_url =  "http://#{@server_name}/jasperserver-pro/rest_v2/reports#{@path_to_report}.#{@report_format}"
    
    #append the starting character to the URL if there is any query parameters
    if (!county_str.empty? || !sponsor_str.empty? || !status_str.empty?)
      report_url += '?'
    end
    
    #append the county str to the report URL
    if !county_str.empty?
      report_url += county_str
    end
    
    if !sponsor_str.empty?
      report_url += sponsor_str
    end
    
    if !status_str.empty?
      report_url += status_str
    end
    
    #remove the last extra character
    if (!county_str.empty? || !sponsor_str.empty? || !status_str.empty?)
      report_url.chop!
    end
    
    #sanitize the report URL - to replace the space with %20, for example
    report_url = URI.escape(report_url)
    
    Rails.logger.info "Report path is: #{report_url}"
    
    begin
      #run the report
      response = RestClient.get("#{report_url}", :authorization=>auth)
      #response = RestClient.post("#{report_url}", :authorization=>auth)
    rescue Exception => exception
      
      Rails.logger.info "Got exception when report was running: #{exception.message}"
      render plain: "Error! Got exception when report was running: #{exception.message}"
      return
    end
    
    case @report_format
    when "pdf"
      Rails.logger.debug "render pdf" 
      send_data response, :filename => "#{@report_output_file_name}.#{@report_format}", :type => "application/pdf"
    
      #send_file(pdf, :filename => "#{@report_output_file_name}.#{@report_format}", :disposition => 'inline', :type => "application/pdf")
     ##       :disposition  => "inline" # either "inline" or "attachment"
      return
    when "xml"
      Rails.logger.debug "render xml"
      render xml: response
      return
    when "html"
      Rails.logger.debug "render html"
      render :text => response.html_safe
      return
    else
      Rails.logger.debug "Don't know what to render. Use html format"
      render :text => response.html_safe
      return
    end
    
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:report_name, :server_name, :server_port, :login, :password, :organization_id, :report_format, :report_output_file_name, :path_to_report, :report_id)
    end
    
    # retrieve the parameters from input field
    def retrieve_params(params)
      
      
=begin
       = params[:report][]
       = params[:report][]
        = params[:report][]
        = params[:report][]
        
        
=end
      
      @report_id = params[:report][:report_id]
      @server_name = params[:report][:server_name]
      @server_port = params[:report][:server_port]
      @login = params[:report][:login]
      @password = params[:report][:password]
      @organization_id = params[:report][:organization_id]
      @report_format = params[:report_format]
      @report_output_file_name = params[:report][:report_output_file_name]
      @path_to_report = params[:report][:path_to_report]
      
      
      if params[COUNTY_CODE] != nil
        @county = params[COUNTY_CODE]
      end
      
      if params[SPONSOR_CODE] != nil
        @sponsor = params[SPONSOR_CODE]
      end
      
      if params[STATUS_CODE] != nil
        @status = params[STATUS_CODE]
      end
      
      if @path_to_report.empty? && params[:report_path_selection] != nil
        @path_to_report = params[:report_path_selection]
        
        Rails.logger.debug "*********** Get report path value from selection box: #{@path_to_report}"
      end
      
      
      
    end
    
    
    
    def build_query_string(query_param, code)
      
      qry_str = ""
      
      query_param.each do |ct|
        qry_str += "#{code}=#{ct}&" 
      end
      
      #remove the last extra char
      #qry_str.chop!
      
      return qry_str
      
    end
    
    
    
    
end
