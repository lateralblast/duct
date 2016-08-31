#!/usr/bin/env ruby

# Name:         DUCT (DC Utilisation / Capacity Tool) 
# Version:      0.1.3
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  DC Utilisation / Capacity Tool

# Load methods

if File.directory?("./methods")
  file_list = Dir.entries("./methods")
  for file in file_list
    if file =~ /rb$/
      require "./methods/#{file}"
    end
  end
end

# Install required gems if required

begin
  require 'getopt/long'
rescue LoadError
  install_gem("getopt")
end

begin
  require 'nokogiri'
rescue LoadError
  install_gem("nokogiri")
end

# Get command line arguments
# Print help if given none

if !ARGV[0]
  print_usage()
end

# Process options

include Getopt

begin
  option = Long.getopts(
    [ "--mos",      "-m", BOOLEAN ],  # Import from MOS CSV extract
    [ "--maskmos",  "-x", BOOLEAN ],  # Mask MOS CSV extract
    [ "--input",    "-i", REQUIRED ], # Input file
    [ "--format",   "-f", REQUIRED ], # Output format
    [ "--report",   "-r", REQUIRED ], # Report type
    [ "--client",   "-c", REQUIRED ], # Client
    [ "--model" ,   "-m", REQUIRED ], # Search model
    [ "--search" ,  "-s", REQUIRED ], # Search for a parameter
    [ "--vendor",   "-d", REQUIRED ], # Import
    [ "--htmldir",  "-w", REQUIRED ], # HTML directory
    [ "--workdir",  "-W", REQUIRED ], # Work directory
    [ "--output",   "-o", REQUIRED ], # Export
    [ "--help",     "-h", BOOLEAN ],  # Display usage information
    [ "--verbose",  "-v", BOOLEAN ],  # Display usage information
    [ "--quiet",    "-q", BOOLEAN ],  # Display usage information
    [ "--version",  "-V", BOOLEAN ]   # Display version information
  )
rescue
  print_usage()
  exit
end

# Set global cars

set_global_vars()

# Print version

if option["version"]
  print_version()
  exit
end

# Print usage

if option["help"]
  print_usage()
  exit
end

# Set input file

if option["input_file"]
  input_file = option["input"]
else
  input_file = ""
end

# Set output

if option["output"]
  output_file = option["output"]
else
  output_file = ""
end

# Set output format

if option["format"]
  $output_format = option["format"].downcase
else
  $output_format = $default_output_format.downcase
end

# Search model

if option["model"]
  search_model = option["model"]
else
  search_model = "all"
end

# Search string

if option["search"]
  search_string = option["search"]
else
  search_string = "all"
end

# Handle verbose message

if option["verbose"]
  $verbose_mode = true
else
  if option["quiet"]
    $verbose_mode = false
  else
    $verbose_mode = $default_verbose_mode
  end
end

# Handle htmldir

if option["htmldir"]
  html_dir = option["htmldir"]
else
  html_dir = $default_html_dir
end

# Handle workdir

if option["workdir"]
  work_dir = option["workdir"]
else
  work_dir = $default_work_dir
end

# handle report

if option["report"]
  report = option["report"]
else
  report = ""
end

# handle report

if option["client"]
  client = option["client"]
else
  client = "test"
end

# Handle import

if option["vendor"]
  import = option["vendor"]
  if import.match(/sun|oracle/)
    vendor = "sun"
    if !output_file.match(/[A-Z,a-z,0-9]/)
      puts "No output file specified"
      puts "Sending output to console"
    end
    case report.gsub(/\s+/,"").downcase
    when /mos/
      import_sun_hw_info(html_dir,output_file,work_dir,search_model,search_string)
    when /rackunits|rus/
      units_file = "./data/sun/rack_units.csv"
      input_file = "./clients/sun/"+client+".csv"
      units_type = "RUs"
      all_models_by_unit,series_by_umit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit = import_mos_unit_info(input_file,units_file,units_type)
      handle_units_output(all_models_by_unit,series_by_umit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit,units_type)
    when /rack/
      units_file = "./data/sun/rack_units.csv"
      input_file = "./clients/sun/"+client+".csv"
      units_type = "Racks"
      all_models_by_unit,series_by_umit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit = import_mos_unit_info(input_file,units_file,units_type)
      handle_units_output(all_models_by_unit,series_by_umit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit,units_type)
    end
  end
end


# Mask MOS CSV

if option["maskmos"]
  if !input_file.match(/[A-Z,a-z,0-9]/)
    puts "Input file not specified"
    exit
  else
    if !File.exist?(input_file)
      puts "Input file does not exist"
      exit
    end
  end
  if !output_file.match(/[A-Z,a-z,0-9]/) 
    puts "Output file not specified"
    exit
  end
  mask_mos_csv_file(input_file,output_file)
end

# Handle MOS data

if option["mos"]
  if option["input"]
    input_file = option["input"]
    if !File.exist?(input_file)
      puts "Input file \"#{input_file}\" does not exist"
      exit
    else
      import_mos_info(input_file)
    end
  else
    puts "Input file not specified"
    exit
  end
end

