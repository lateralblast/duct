#!/usr/bin/env ruby

# Name:         DUCT Webserver 
# Version:      0.0.6
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Webserver for DC Utilisation / Capacity Tool 

# Load methods

if File.directory?("./methods")
  file_list = Dir.entries("./methods")
  for file in file_list
    if file =~ /rb$/
      require "./methods/#{file}"
    end
  end
end

require 'tilt/erb'

# Install required gems if required

begin
  require 'sinatra'
rescue LoadError
  install_gem("sinatra")
end

begin
  require 'chartkick'
rescue LoadError
  install_gem("chartkick")
end

# Set global vars

before do
  set_global_vars()
end

# Handle requests

get '/sun' do
  if params["report"]
    @report = params["report"]
  else
    @report = "servers"
  end
  if params["vendor"]
    vendor = params["vendor"]
  else
    vendor = "sun"
  end
  if params["client"]
    client = params["client"]
  else
    client = "test"
  end
  case @report
  when /racks|rack$/
    units_file = "./data/sun/rack_units.csv"
    input_file = "./clients/sun/"+client+".csv"
    units_type = "Racks"
    @all_models,@series,@b_models,@c_models,@e_models,@m_models,@n_models,@s_models,@t_models,@u_models,@v_models,@x_models,@z_models = import_mos_unit_info(input_file,units_file,units_type)
  when /rackunits|rus/
    units_file = "./data/sun/rack_units.csv"
    input_file = "./clients/sun/"+client+".csv"
    units_type = "RUs"
    @all_models,@series,@b_models,@c_models,@e_models,@m_models,@n_models,@s_models,@t_models,@u_models,@v_models,@x_models,@z_models = import_mos_unit_info(input_file,units_file,units_type)
  when /power/
    units_file = "./data/sun/power_units.csv"
    input_file = "./clients/sun/"+client+".csv"
    units_type = "Watts"
    @all_models,@series,@b_models,@c_models,@e_models,@m_models,@n_models,@s_models,@t_models,@u_models,@v_models,@x_models,@z_models = import_mos_unit_info(input_file,units_file,units_type)
  else
    input_file = "./clients/"+vendor+"/"+client+".csv"
    @all_models,@series,@b_models,@c_models,@e_models,@m_models,@n_models,@s_models,@t_models,@u_models,@v_models,@x_models,@z_models = import_mos_server_info(input_file)
  end
  erb :sun_units
end

# Redirect Oracle to Sun

get '/oracle' do
  redirect '/sun'
end
