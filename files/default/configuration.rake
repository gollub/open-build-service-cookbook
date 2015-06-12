task :load_configuration_xml, [:file] => :environment do |t, args|
  args.with_defaults(:file => '/srv/obs/configuration.xml')
  puts "Reading file: #{args.file}"
  xml = Xmlhash.parse(File.read(args.file)) || {}
  attribs = {}

  # scheduler architecture list
  archs = Hash.new
  if xml["schedulers"] and xml["schedulers"].class == Xmlhash::XMLHash
    xml["schedulers"]["arch"].each do |a|
      archs[a] = 1
    end
  end
  Architecture.all.each do |arch|
    arch.available = (archs[arch.name] == 1)
    arch.save!
  end

  # standard values as defined in model
  ::Configuration::OPTIONS_YML.keys.each do |k|
    value = xml[k.to_s]
    if value and not value.blank?
      v = ::Configuration::map_value( k, value )
      ov = ::Configuration::map_value( k, ::Configuration::OPTIONS_YML[k] )
      if ov != v and not ov.blank?
        puts "The api has a different value for #{k.to_s} configured in options.yml file."
        next
      end
      attribs[k] = value
    end
  end

  @configuration = ::Configuration.first
  ret = @configuration.update_attributes(attribs)
  if ret
    puts "success"
    @configuration.save!
  else
    puts @configuration.errors
  end
end
