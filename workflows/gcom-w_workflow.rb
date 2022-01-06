steps = Hash.new
# Set up steps
steps[:arrival] = Step.where(name: "GComWArrival").first_or_create({
  processing_level: ProcessingLevel.where(name: 'raw').first_or_create
  })
steps[:rtstps] = Step.where(name: "GcomwRtstpsJob").first_or_create({
  command: "rtstps.rb -p gcomw -t {{workspace}} {{job.input_file}} {{job.output_path}}",
  queue: 'rtstps',
  processing_level: ProcessingLevel.where(name: 'level0').first_or_create,
  parent: steps[:arrival]
})


#GCOMW Level1 
steps[:level1] = Step.where(name: "Amsr2Level1").first_or_create({
  command: "amsr2_level1.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "cspp_extras",
  processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
  sensor: Sensor.where(name: 'amsr2').first_or_create,
  parent: steps[:rtstps]
})


#GCOM Level2
steps[:level2] = Step.where(name: "Amsr2Level2").first_or_create({
  command: "gaasp_l2.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "cspp_extras",
  processing_level: ProcessingLevel.where(name: 'level2').first_or_create,
  sensor: Sensor.where(name: 'amsr2').first_or_create,
  parent: steps[:level1]
})

#GCOM Level2 LDM inject
steps[:ldm] = Step.where(name: 'Amsr2LdmInject').first_or_create({
  command: 'pqinsert.rb -t . -p UAF_{{job.facility_name.upcase}}_ {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:level2],
 enabled: true
})

#Geotiff
steps[:gtiff_l2] = Step.where(name: "generate_amsr2_geotif").first_or_create({
  command: "generate_amsr2_geotif.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "polar2grid",
  enabled: true,
  processing_level: ProcessingLevel.where(name: 'geotiff_l1').first_or_create,
  sensor: Sensor.where(name: 'amsr2').first_or_create,
  parent: steps[:level2]
})

#Geotiff Feeder..
steps[:gtiff_feeder] = Step.where(name: "Amsr2_Level2_Feeder").first_or_create({
  command: "feeder_geotif.rb -m amsr2_level2 -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "geotiff",
  enabled: true,
  processing_level: ProcessingLevel.where(name: 'geotiff_l2').first_or_create,
  sensor: Sensor.where(name: 'amsr2').first_or_create,
  parent: steps[:gtiff_l2]
})


# Set up requirements
#steps[:rtstps].requirements = %w{aapp}.map do |requirement|
#  Requirement.where(name: requirement).first_or_create
#end
sat = Satellite.friendly.find('gcom-w')
sat.workflows << steps[:arrival] unless sat.workflows.include?(steps[:arrival])
