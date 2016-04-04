#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "net/http"
require "rexml/document"

REPORT_NAME = 'single_point_of_contact_report'
REPORT_GROUP = "samples"
SERVER_ROOT = "reporttest.mtc.ca.gov" #Your Jasper Server Address
#SERVER_PORT = 8080 #Port of Jasper Server
SERVER_USER = "ylee" #Jasper Server Admin
SERVER_PASSWORD = "password" #JasperServer Password
ORGANIZATION_UNIT = "mtc_pa"
USER_LOGIN = "${SERVER_USER}|${ORGANIZATION_UNIT}"
FORMAT = "PDF" #Format of output
FILE_NAME = "report.pdf" #Name of output file


#REPORT_PATH = "http://#{SERVER_ROOT}:#{SERVER_PORT}/jasperserver/rest/report"

REPORT_PATH = "http://#{SERVER_ROOT}/jasperserver-pro/rest/report"
#REPORT_PATH = "http://#{SERVER_ROOT}/jasperserver-pro/rest_v2/reports/"

def to_ms(time)
  start = Time.new(1970,1,1)
  ((time.to_f - start.to_f) * 1000.0).to_i
end

#Examples of params, change for your report
PARAMS = {:start_time=>to_ms(Time.new(2011,01,01)), :end_time=>to_ms(Time.new(2014,01,01))}


REPORT_TO_PATH = "/fms/production/reports/public/#{REPORT_NAME}"

def build_xml_request
  #url_string = "/fms/production/reports/public/#{REPORT_NAME}"
  
  request_body = "<resourceDescriptor name='#{REPORT_NAME}' wsType='reportUnit' uriString='#{REPORT_TO_PATH}' isNew='false'><label>null</label>"
  puts "creating url for : #{REPORT_TO_PATH} "
  PARAMS.each do|k,v| 
    request_body += "<parameter name='#{k}'>#{v.to_s}</parameter>"
    puts "parameter send: #{k}=#{v.to_s}; "
  end
  request_body += "</resourceDescriptor>"
end

def get_uuid_and_cookie

  body = ""
  cookie = ""
  puts "FULL URL: #{"#{REPORT_PATH}#{REPORT_TO_PATH}"}"
  
  uri = URI.parse("#{REPORT_PATH}#{REPORT_TO_PATH}")
  
  http = Net::HTTP.new(uri.host, uri.port)
  
  http.start do |_http|
    req = Net::HTTP::Put.new(uri.path + "?RUN_OUTPUT_FORMAT=#{FORMAT}")
    puts "send data for: #{uri.path}?RUN_OUTPUT_FORMAT=#{FORMAT}"
    req.basic_auth(USER_LOGIN, SERVER_PASSWORD)
    req.body = build_xml_request
    resp = _http.request(req)
    body = resp.body
    puts "body is #{body}"
    puts "COOKIE received: #{resp['Set-Cookie']}"   
    cookie = resp['Set-Cookie']
  end

  xml = REXML::Document.new(body)
  puts "\n\n XML \n #{xml} \n\n"
  uuid_xml = xml.elements["report/uuid"]
  
  if uuid_xml
    uuid = uuid_xml.text
    puts "UUID received: #{uuid}" 
    return uuid,cookie
  else
    puts "Problem with UUID. Response: #{uuid_xml}" 
    return false,false
  end
end

def get_file
  body_get = nil
  uuid,cookie = get_uuid_and_cookie
  
  if uuid
    uri_get = URI.parse("#{REPORT_PATH}/#{uuid}")
    puts "Report URL: #{uri_get}"
    http_get = Net::HTTP.new(uri_get.host, uri_get.port)

    http_get.start do |http|
      req = Net::HTTP::Get.new(uri_get.path + "?file=report")   
      puts "REQ: #{req.path}"
      req.basic_auth(USER_LOGIN, SERVER_PASSWORD)
      req['cookie'] = cookie
      resp = http.request(req)
      body_get = resp.body    
    end
  end
  body_get
end


file = get_file
if file 
  #puts file
  f = File.new(FILE_NAME, 'wb')
  f.write(file)
  f.close
else
  puts "Ops, report file don't saved!"
end 
