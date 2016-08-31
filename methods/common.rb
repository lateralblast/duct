# Common code

require 'rubygems'
require 'csv'
require 'securerandom'
require 'date'

# Routine to install 

def install_gem(gem_name)
  puts "Information:\tInstalling #{gem_name}"
  %x[gem install #{gem_name}]
  Gem.clear_paths
end

begin
  require 'multiset'
rescue LoadError
  install_gem("multiset")
end

begin
  require 'faker'
rescue LoadError
  install_gem("faker")
end

# Extend hash to allow searching of keys

class Hash
  def grep(pattern)
    inject([]) do |res, kv|
      res << kv if kv[0] =~ pattern or kv[1] =~ pattern
      res
    end
  end
end

# Extend Enumerable to provide grep -v like capabilty

module Enumerable
  def grepv(condition)
    if block_given?
      each do |item|
        yield item if not condition === item
      end
    else
      inject([]) do |memo, item|
        memo << item if not condition === item
        memo
      end
    end
  end
end

# Set defaults

def set_global_vars()
  $default_html_dir 		 = "/Volumes/8TB/Data/Documents/HW"
  $default_work_dir 		 = Dir.pwd
  $default_output_format = "text"
  $output_text           = []
  $default_verbose_mode  = false
  return
end

# Get version

def get_version()
  file_array = IO.readlines $0
  version    = file_array.grep(/^# Version/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  packager   = file_array.grep(/^# Packager/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  name       = file_array.grep(/^# Name/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  return version,packager,name
end

# Print script version information

def print_version()
  (version,packager,name) = get_version()
  handle_output("#{name} v. #{version} #{packager}")
  return
end

# Print script usage information

def print_usage()
  $output_format = "text"
  switches       = []
  long_switch    = ""
  short_switch   = ""
  help_info      = ""
  handle_output("")
  handle_output("Usage: #{$script}")
  handle_output("")
  file_array  = IO.readlines $0
  option_list = file_array.grep(/\[ "--/)
  option_list.each do |line|
    if !line.match(/file_array/)
      help_info    = line.split(/# /)[1]
      switches     = line.split(/,/)
      long_switch  = switches[0].gsub(/\[/,"").gsub(/\s+/,"")
      short_switch = switches[1].gsub(/\s+/,"")
      if long_switch.gsub(/\s+/,"").length < 7
        handle_output("#{long_switch},\t\t\t#{short_switch}\t#{help_info}")
      else
        if long_switch.gsub(/\s+/,"").length < 15
          handle_output("#{long_switch},\t\t#{short_switch}\t#{help_info}")
        else
          handle_output("#{long_switch},\t#{short_switch}\t#{help_info}")
        end
      end
    end
  end
  handle_output("")
  return
end

# Handle output

def handle_output(text)
  if $output_format.match(/html/)
    if text == ""
      text = "<br>"
    end
  end
  if $output_format.match(/text/)
    puts text 
  end
  $output_text.push(text)
  return
end

# Set MOS model header

def set_mos_model_header(model)
	if model.match(/^[0-9]50$|^[0-9][0-9]K|^[2,4]80R$|^[3,4,6]8[0,1]0/)
    model = "E"+model
  end
  if model.match(/^[1,2,4,8][1,2,4,8]0$/)
    model = "V"+model
  end
  if model.match(/^6000$/)
    model = "B"+model
  end
  if model.match(/^7/)
    model = "Z"+model
  end
  return model
end

# Get models from MOS extract

def get_mos_extract_model(model)
  model = model.gsub(/SUN |FIRE |NETRA |SPARC |ENTERPRISE /,"")
  model = model.gsub(/S[A-Z]/,"").gsub(/^\s+/,"")
  model = model.split(/\:| |,|\/|1X/)[0]
  model = model.gsub(/NETRA/,"N")
  model = model.gsub(/ULTRA/,"U")
  model = set_mos_model_header(model)
  return model
end

# Get model from MOS HTML

def get_mos_html_model(model)
  model = model.gsub(/SPARC Enterprise/,"")
  model = model.gsub(/Enterprise /,"E")
  model = model.gsub(/SPARC/,"")
  model = model.gsub(/Sun Fire/,"V")
  model = model.gsub(/Ultra/,"U")
  model = model.gsub(/Sun|Server|Fire|Oracle|In-Memory|Machine|Hardware|Specifications|Module|Modular|System|Workstation|Fujitsu|ZFS|Storage|Medium|Small|Appliance|Racked|Java|Unified|Model/,"")
  model = model.gsub(/ PCI Expansion Unit/,"IOU")
  model = model.gsub(/ Expansion Rack/,"ER")
  model = model.gsub(/ Upgrade/,"U")
  model = model.gsub(/Private Cloud Appliance /,"PCA")
  model = model.gsub(/Private Cloud /,"PCA")
  model = model.gsub(/Virtual Compute Appliance /,"VCA")
  model = model.gsub(/Virtual Compute /,"VCA")
  model = model.gsub(/Advanced Support Gateway /,"ASG")
  model = model.gsub(/Database Appliance /,"DA")
  model = model.gsub(/Database /,"DA")
  model = model.gsub(/Backup/,"ZFSBA")
  model = model.gsub(/Exalytics /,"XA")
  model = model.gsub(/MiniCluster /,"MC")
  model = model.gsub(/\-\-|\- \-/,"-").gsub(/\s+/," ")
  model = model.gsub(/^\s+|\s+$|\-$/,"")
  model = model.gsub(/T4 1B/,"T4-1B")
  model = model.gsub(/T3 1B/,"T3-1B")
  model = model.gsub(/ \- $/,"")
  model = model.gsub(/V |\)|\(/,"")
  model = model.gsub(/ M/,"M")
  model = model.gsub(/ P/,"P")
  model = model.gsub(/ U/,"U")
  model = model.gsub(/Netra /,"N")
  model = model.gsub(/Blade /,"B")
  model = model.gsub(/PCA /,"PCA")
  model = model.gsub(/VCA /,"VCA")
  model = model.gsub(/ASG /,"ASG")
  model = model.gsub(/DA /,"DA")
  model = model.gsub(/XA /,"XA")
  model = model.gsub(/U /,"U")
  model = model.gsub(/\s+/,"")
  if model.match(/post| 2100/)
  	model = model.split(/\s+/)[0]+"R2"
  	if model.match(/post/)
	  	model = model.split(/post/)[0]+"R2"
  	end
  end
  model = set_mos_model_header(model)
	return model
end

# Import MOS extract and mask data

def mask_mos_csv_file(input_file,output_file)
  mos_info   = CSV.read(input_file)
  output_csv = CSV.open(output_file,"wb")
  output_row = []
  input_row  = []
  support_id = Faker::Number.number(8)
  company    = Faker::Company.name
  contact    = Faker::Name.name
  date_today = Time.new
  date_today = date_today.strftime("%d-%b-%Y")
  mos_info.each_with_index do |input_row, index|
    output_row = input_row
    if index > 0
      if index % 10 == 0
        contact = Faker::Name.name
      end
      output_row[0] = Faker::Code.asin
      output_row[2] = support_id
      output_row[3] = company
      output_row[6] = contact
      output_row[8] = date_today
    end
    output_csv << output_row
  end
  output_csv.close
  return
end


# Import MOS extract

# Serial Number,Asset Type,Support Identifier,Organization,Product Name,HW Description,Contact Name,ASR Status,Entitlement End Date,Contract Type
#             0,         1,                 2,           3,           4,             5,           6,         7,                   8,            9

# Import MOS server info

def import_mos_server_info(input_file)
  mos_info   = CSV.read(input_file)
  raw_models = []
  mos_info.each do |row|
    desc  = row[4]
    model = desc.upcase
    info  = row[5]
    if model.match(/SUN FIRE|SF|[0-9][0-9][0-9]R|X[0-9]|NETRA|M[0-9]|E[0-9][0-9][0-9]|T[0-9]/) and !model.match(/JBOD|STOR|RAID|WS|G2|RR|LTO/)
      model = get_mos_extract_model(model)
      if model.match(/GHZ|MHZ/)
        model = get_mos_extract_model(info)
      end
      raw_models.push(model)
    end
  end
  raw_hgram        = Multiset.new(raw_models)
  all_models_by_no = raw_hgram.to_hash
  b_models_by_no	 = all_models_by_no.grep(/^B/)
  c_models_by_no	 = all_models_by_no.grep(/^C/)
  e_models_by_no   = all_models_by_no.grep(/^E/)
  m_models_by_no   = all_models_by_no.grep(/^M/)
  n_models_by_no   = all_models_by_no.grep(/^N/)
  s_models_by_no   = all_models_by_no.grep(/^S/)
  t_models_by_no   = all_models_by_no.grep(/^T/)
  u_models_by_no   = all_models_by_no.grep(/^U/)
  v_models_by_no   = all_models_by_no.grep(/^V/)
  x_models_by_no   = all_models_by_no.grep(/^X/)
  z_models_by_no   = all_models_by_no.grep(/^Z/)
  b_models_total   = raw_models.grep(/^B/).length
  c_models_total   = raw_models.grep(/^C/).length
  e_models_total   = raw_models.grep(/^E/).length
  m_models_total   = raw_models.grep(/^M/).length
  n_models_total   = raw_models.grep(/^N/).length
  s_models_total   = raw_models.grep(/^S/).length
  t_models_total   = raw_models.grep(/^T/).length
  u_models_total   = raw_models.grep(/^U/).length
  v_models_total   = raw_models.grep(/^V/).length
  x_models_total   = raw_models.grep(/^X/).length
  z_models_total   = raw_models.grep(/^Z/).length
  series_by_no     = { "Blade Chassis" => b_models_total, "C Series" 		 => c_models_total,
  						 				 "E Series" 		 => e_models_total, "M Series" 		 => m_models_total,
  						         "Netra Series"  => n_models_total, "S Series"     => s_models_total,
                       "T Series"      => t_models_total, "Ultra Series" => u_models_total,
  						         "V Series" 		 => v_models_total, "X Series" 		 => x_models_total,
                       "Z Series"      => z_models_total
		  				        }
  return all_models_by_no,series_by_no,b_models_by_no,c_models_by_no,e_models_by_no,m_models_by_no,n_models_by_no,s_models_by_no,t_models_by_no,u_models_by_no,v_models_by_no,x_models_by_no,z_models_by_no
end

# Import file into hashed array

def import_csv_file_to_hash(input_file)
  units_by_model = {}
  unit_info      = File.readlines(input_file)
  unit_info.each do |line|
    line  = line.chomp
    info  = line.parse_csv
    model = info[0]
    units = info[1]
    if units
      units = units.gsub(/W/,"")
    else
      units = "0"
    end
    units_by_model[model] = units
  end
  return units_by_model
end

# Handle units reports

def handle_units_output(all_models_by_unit,series_by_unit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit,units_type)
  series_by_unit.each do |model, value|
    puts "Model:\t"+model
    puts units_type+":\t"+value.to_s
  end
end

# Import MOS unit information

def import_mos_unit_info(input_file,units_file,units_type)
  mos_info   = CSV.read(input_file)
  raw_models = []
  mos_info.each do |row|
    desc  = row[4]
    model = desc.upcase
    info  = row[5]
    if model.match(/SUN FIRE|SF|[0-9][0-9][0-9]R|X[0-9]|NETRA|M[0-9]|E[0-9][0-9][0-9]|T[0-9]/) and !model.match(/JBOD|STOR|RAID|WS|G2|RR|LTO/)
      model = get_mos_extract_model(model)
      if model.match(/GHZ|MHZ/)
        model = get_mos_extract_model(info)
      end
      raw_models.push(model)
    end
  end
  units_by_model     = import_csv_file_to_hash(units_file)
  all_models_by_unit = {}
  raw_hgram          = Multiset.new(raw_models)
  all_models_by_no   = raw_hgram.to_hash
  b_models_total     = 0
  c_models_total     = 0
  e_models_total     = 0
  m_models_total     = 0
  n_models_total     = 0
  s_models_total     = 0
  t_models_total     = 0
  u_models_total     = 0
  v_models_total     = 0
  x_models_total     = 0
  z_models_total     = 0
  case units_type.gsub(/\s+/,"").downcase
  when /ru|rackunit/
    multiple = 1.to_f
  when /rack/
    multiple = (1.to_f/42.to_f).to_f
  else
    multiple = 1.to_f
  end
  all_models_by_no.each do |model, number|
    if units_by_model[model]
      if units_by_model[model].match(/[0-9]/)
        number = number.to_i
        units  = units_by_model[model].to_i
        total  = number*units
        all_models_by_unit[model] = (total * multiple).round(1)
        case model
        when /^B/
          b_models_total = b_models_total + total
        when /^C/
          c_models_total = c_models_total + total
        when /^E/
          e_models_total = e_models_total + total
        when /^M/
          m_models_total = m_models_total + total
        when /^N/
          n_models_total = n_models_total + total
        when /^S/
          s_models_total = s_models_total + total
        when /^T/
          t_models_total = t_models_total + total
        when /^U/
          u_models_total = u_models_total + total
        when /^V/
          v_models_total = v_models_total + total
        when /^X/
          x_models_total = x_models_total + total
        when /^Z/
          z_models_total = z_models_total + total
        end
      end
    end
  end
  b_models_total   = (b_models_total * multiple).round(1)
  c_models_total   = (c_models_total * multiple).round(1)
  e_models_total   = (e_models_total * multiple).round(1)
  m_models_total   = (m_models_total * multiple).round(1)
  n_models_total   = (n_models_total * multiple).round(1)
  s_models_total   = (s_models_total * multiple).round(1)
  t_models_total   = (t_models_total * multiple).round(1)
  u_models_total   = (u_models_total * multiple).round(1)
  v_models_total   = (v_models_total * multiple).round(1)
  x_models_total   = (x_models_total * multiple).round(1)
  z_models_total   = (z_models_total * multiple).round(1)
  b_models_by_unit = all_models_by_unit.grep(/^B/)
  c_models_by_unit = all_models_by_unit.grep(/^C/)
  e_models_by_unit = all_models_by_unit.grep(/^E/)
  m_models_by_unit = all_models_by_unit.grep(/^M/)
  n_models_by_unit = all_models_by_unit.grep(/^N/)
  s_models_by_unit = all_models_by_unit.grep(/^S/)
  t_models_by_unit = all_models_by_unit.grep(/^T/)
  u_models_by_unit = all_models_by_unit.grep(/^U/)
  v_models_by_unit = all_models_by_unit.grep(/^V/)
  x_models_by_unit = all_models_by_unit.grep(/^X/)
  z_models_by_unit = all_models_by_unit.grep(/^Z/)
  series_by_unit   = { "Blade Chassis" => b_models_total, "C Series"     => c_models_total,
                       "E Series"      => e_models_total, "M Series"     => m_models_total,
                       "Netra Series"  => n_models_total, "S Series"     => s_models_total,
                       "T Series"      => t_models_total, "Ultra Series" => u_models_total,
                       "V Series"      => v_models_total, "X Series"     => x_models_total,
                       "Z Series"      => z_models_total
                      }
  return all_models_by_unit,series_by_unit,b_models_by_unit,c_models_by_unit,e_models_by_unit,m_models_by_unit,n_models_by_unit,s_models_by_unit,t_models_by_unit,u_models_by_unit,v_models_by_unit,x_models_by_unit,z_models_by_unit
end

# split MOS models where multiple models are present in the one string

def split_mos_models(model)
	models = []
	if model.match(/E12K\-15K/)
		model = "E25K - E15K"
	end
	if model.match(/\-X/)
		model = model.gsub(/\-X/," - X")
	end
	if model.match(/\-N/)
		model = model.gsub(/\-N/," - N")
	end
	if model.match(/\-W/)
		model = model.gsub(/\-W/," - W")
	end
	if model.match(/ \- /)
		if model.match(/ \- /)
			models = model.split(/ \- /)
		end
	else
		models[0] = model
	end
	return models
end

# Routine to import Sun System Hardware information 

def import_sun_hw_info(html_dir,output_file,work_dir,search_model,search_string)
  file_list = Dir.entries(html_dir)
  html_list = file_list.grep(/htm$/)
  html_list = html_list.grepv(/Xterminal|SPARCstation/)
  prefix    = ""
  param     = ""
  value     = ""
  model     = ""
  params    = []
  models    = []
  cores     = ""
  params.push("Model")
  data = Hash.new{|hash, key| hash[key] = Hash.new{|hash, key| hash[key] = Array.new}}
  html_list.each do |file_name|
    input_file = html_dir+"/"+file_name
    if file_name.match(/^System/)
      model = file_name.split(/-|_/)[1..-1].join("-").split(/\./)[0]
    else
      case file_name
      when /Netra Modular System/
        model = "NB6000"
      when /Ultra 450/
        model = "E450"
      when /Cray Superserver|SPARCcenter|SPARCserver/
        model = "E"+file_name.split(/ /)[-1].gsub(/\.htm/).to_s
      else
        model = file_name.split(/-|_/)[0..-2].join("-")
      end
    end
    model  = get_mos_html_model(model)
    models = split_mos_models(model)
    models.each do |model|
      if !model.match(/[0-9]/)
        model = get_mos_html_model(model)
      end
      if $verbose_mode == true
        puts "Model: "+model
        puts "File:  "+file_name
      end
      file_type = %x[file -b "#{input_file}"].chomp
      if file_type.match(/HTML|html/) and model.match(/[A-Z]|[a-z]|[0-9]/)
      	if search_model.downcase.match(/#{model.downcase}/) or search_model.match(/all/)
  	      doc   = Nokogiri::HTML(File.open(input_file))
  	      table = 3
  	      if !doc.css("table")[table].to_s.match(/colspan/)
  	      	table = 4
  	      end
  	      if doc.css("table")[table]
  	        doc.css("table")[table].search("tr").each do |tr|
  	          cell = tr.search("td").map(&:text)
  	          if !cell[1] and tr.to_s.match(/caption/)
  	            prefix = cell[0].gsub(/\s+/," ").gsub(/\n/,"")
  	          else
  	            if !cell[1]
  	              if cell[0]
  	                value = cell[0].gsub(/\s+/," ").gsub(/\n|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	                param = prefix
  	              end
  	            else
  	              if cell[1]
  	                if prefix.match(/Processor/)
  	                  param = prefix+" "+cell[0].gsub(/\s+/," ").gsub(/\n|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	                else
  	                  param = cell[0].gsub(/\s+/," ").gsub(/\n|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	                end
  	                value = cell[1..-1].join(" ").gsub(/\s+/," ").gsub(/\n|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	              end
  	            end
  	            param = param.gsub(/^\s+|\s+$/,"").gsub(/\n/,"").gsub(/\s+/," ").gsub(/\"|\'|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	            value = value.gsub(/^\s+|\s+$/,"").gsub(/\n/,"").gsub(/\s+/," ").gsub(/\"|\'|\(|\)|\+|\*/,"").gsub(/\@/,"at")
  	            param = param.gsub(/ meets or exceeds the following requirements/,"")
  	            param = param.downcase
  	            if param.match(/rack units/)
  	            	value = value.split(/\s+|\,/)[0].gsub(/RU$|U$/,"")
  	            	if value.match(/n\/a|N\/A|ull/) and !model.match(/^U|^W/)
  	            		value = "42"
  	            	end
  	            	if model.match(/N6000/)
  	            		value = "10"
  	            	end
  	            end
                if param.match(/power/)
                  if param.match(/^power consumption$/)
                    if value.to_s.match(/W/)
                      value  = value.gsub(/\s+W/,"W").gsub(/^\s+|\s+$/,"")
                      if value.match(/\s+/)
                        values = value.split(/\s+/)
                        value  = values.grep(/W/)[0]
                      end
                      if value.class == Array
                        value = value.join.gsub(/[a-z]/,"")
                      else
                        value = value.gsub(/[a-z]|\,|\./,"")
                      end
                    end
                  else
                    params.push("power consumption")
                    if !data[model]["power consumption"].to_s.match(/W/) or data[model]["power consumption"].to_s.match(/calculator/)
                      if value.to_s.match(/W/)
                        value  = value.gsub(/\s+W/,"W").gsub(/^\s+|\s+$/,"")
                        if value.match(/\s+/)
                          values = value.split(/\s+/)
                          value  = values.grep(/W/)[0]
                        end
                        if value.class == Array
                          value = value.join.gsub(/[a-z]|\,|\./,"")
                        else
                          value = value.gsub(/[a-z]|\,|\./,"")
                        end
                        data[model]["power consumption"] = value
                      end
                    end
                  end
                end
  	            if param.match(/processor number/)
  	            	value = value.downcase
  	            	value = value.gsub(/one|single/,"1")
  	            	value = value.gsub(/two|dual/,"2")
  	            	value = value.gsub(/four|quad/,"4")
  	            	value = value.gsub(/eight/,"8")
  	            	value = value.gsub(/sixteen/,"16")
  	            	value = value.gsub(/up to 2/,"1,2")
  	            	value = value.gsub(/up to 4/,"2,4")
  	            	value = value.gsub(/up to 8/,"2,4,8")
  	            	value = value.gsub(/ or | to /,",")
  	            	value = value.gsub(/\, |\,\,/,",")
  	            	if value.match(/\ /)
  		            	info  = value.split(/\ /)
  		            	value = info[0]
  		            	cores = info[1..-1]
  		            	cores = cores.grep(/[0-9]\-core/).join
  		           		cores = cores.gsub(/[a-z],\-/,"")
  		           		cores = cores.split(/\,/)
  		           		ctemp = []
  		           		cores.each do |core|
  		           			if core.match(/^1$/) or core.match(/core/)
  		           				core = core.gsub(/\-core/,"")
  			           			ctemp.push(core)
  			           		end
  		           		end
  		           		cores = ctemp.join(",")
  		           		cores = cores.gsub(/\-core:[0-9]|\-core/,"")
  		           	else
  		           		cores = ""
  		           	end
  	           		value = value+":"+cores
  	           		value = value.gsub(/4\,2/,"4:2")
  	           		value = value.gsub(/::/,"")
  	           		if model.match(/^W11/)
  	           			value = "1:"
  	           		end
  	           		if model.match(/^W11/)
  	           			value = "2:"
  	           		end
  	            end
  	          end
  	          if !param.match(/height 2 rack units/)
  		          if param.match(/[a-z]/) and !param.match(/mounting|racks|[0-9][0-9][0-9]/)
  		          	if search_string.match(/\,/)
  		          		search_string.split(/\,/).each do |temp_string|
  				            data[model]["Model"] = model
  				            params.push(param)
  				            if !data[model][param].to_s.match(/#{value}/)  and !value.match(/[O,o]nline/)
  				              data[model][param] = value
                      end
  		          		end
  		          	else
  			          	if param.downcase.match(/#{search_string.downcase}/) or search_string.match(/all/)
					            data[model]["Model"] = model
					            params.push(param)
					            if !data[model][param].to_s.match(/#{value}/) and !value.match(/[O,o]nline/)
					              data[model][param] = value
  				            end
  				          end
  		            end
  		          end
              end
	          end
          end
        end
      end
    end
  end
  if output_file.match(/[A-Z,a-z,0-9]/)
	  file = File.open(output_file, "w")
	end
	params = params.uniq
	params[0..-2].each do |param|
	 	if output_file.match(/[A-Z,a-z,0-9]/)
	    file.print "\"#{param}\","
	  else
	    print "\"#{param}\","
	  end
	end
	if output_file.match(/[A-Z,a-z,0-9]/)
	  file.print "\"#{params[-1]}\"\n"
	else
	  print "\"#{params[-1]}\"\n"
	end
  data.each do |model, info|
    values = []
    param  = ""
    smodel = model.gsub(/Small|Silver/,"S").gsub(/X4\-4X4\-4/,"X4-4")
    values.push("\"#{smodel}\"")
    params.each do |param|
      if !param.match(/Model/)
        if data[model][param]
          value = data[model][param]
          if value.class == Array
            value = value.join(" ")
          end
        else
          value = ""
        end
        svalue = "\"#{value}\""
        values.push(svalue)
      end
    end
	  if output_file.match(/[A-Z,a-z,0-9]/)
	    file.print values.join(",")
	    file.print("\n")
	  else
	    print values.join(",")
	    print("\n")
	  end
  end
  if output_file.match(/[A-Z,a-z,0-9]/)
    file.close
  end
end
