%w[noaa15 noaa18 noaa19].each do |satellite|
  steps = {}
  # Set up steps
  steps[:arrival] = Step.where( 
    name: "#{satellite.capitalize}Arrival").first_or_create(processing_level: ProcessingLevel.where(name: 'raw').first_or_create)

  steps[:hrptin] = Step.where( name: "#{satellite.capitalize}Hrptin").first_or_create(
    processing_level: ProcessingLevel.where(name: 'level0').first_or_create,
    queue: 'terascan',
    sensor: Sensor.where(name: 'avhrr').first_or_create,
    command: 'avhrr_l0.rb -t {{workspace}} {{job.input_file}} {{job.output_path}}',
    enabled: false,
    parent: steps[:arrival]
  )

  steps[:l1] = Step.where(name: "#{satellite.capitalize}L1").first_or_create(
    processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
    queue: 'aapp',
    sensor: Sensor.where(name: 'avhrr').first_or_create,
    command: 'noaa_poes_l1.rb -t {{workspace}} {{job.input_file}} {{job.output_path}}',
                                                        parent: steps[:arrival])

  # for noaa18 && noaa19, do mirs
  if %w[noaa18 noaa19].include?(satellite)
    steps[:mirsl1] = Step.where(name: "#{satellite.capitalize}MirsL2").first_or_create(
      processing_level: ProcessingLevel.where(name: 'mirs_level2').first_or_create,
      queue: 'cspp_extras',
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: "mirs_l0.rb -s #{satellite} -t {{workspace}} {{job.input_path}} {{job.output_path}}",
      enabled: false,
      parent: steps[:l1])
    steps[:mirsawips] = Step.where(name: "#{satellite.capitalize}MirsAWIPS").first_or_create(
      processing_level: ProcessingLevel.where(name: 'awips').first_or_create,
      queue: 'polar2grid',
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: 'mirs_awips.rb -s amsu -t {{workspace}} {{job.input_path}} {{job.output_path}}',
      enabled: false,
      parent: steps[:mirsl1])
    steps[:mirs_scmi] = Step.where(name: "#{satellite.capitalize}MirsSCMI").first_or_create({
      processing_level: ProcessingLevel.where(name: 'mirs_scmi').first_or_create,
      queue: 'polar2grid',
      enabled: false,
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: "awips_scmi.rb -m mirs -t {{workspace}} {{job.input_path}} {{job.output_path}}",
      parent: steps[:mirsl1]
    })
    steps[:mirsiscmildm] = Step.where(name: "#{satellite.capitalize}MirsSCMILDMInject").first_or_create(
      command: 'pqinsert.rb -t . {{job.input_path}}',
      queue: 'ldm',
      producer: false,
      parent: steps[:mirs_scmi],
      enabled: false)

    steps[:mirsldm] = Step.where(name: "#{satellite.capitalize}MirsLDMInject").first_or_create(
      command: 'pqinsert.rb -t . {{job.input_path}}',
      queue: 'ldm',
      producer: false,
      parent: steps[:mirsawips],
      enabled: false)

    steps[:mirsawips].requirements = %w[polar2grid2].map do |requirement|
      Requirement.where(name: requirement).first_or_create
    end

    steps[:mirsl1].requirements = %w[cspp_extras].map do |requirement|
      Requirement.where(name: requirement).first_or_create
    end

    steps[:mirsldm].requirements = %w[ldm].map do |requirement|
      Requirement.where(name: requirement).first_or_create
    end

    steps[:geotiff_l1] = Step.where(name: "#{satellite.capitalize}GeoTiff_l1").first_or_create(
      processing_level: ProcessingLevel.where(name: 'geotiff_l1').first_or_create,
      queue: 'polar2grid',
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: "p2g_geotif.rb -p 2 -m avhrr -t {{workspace}} {{job.input_path}} {{job.output_path}}",
      parent: steps[:l1])
    steps[:geotiff_l2] = Step.where(name: "#{satellite.capitalize}GeoTiff_l2").first_or_create(
      processing_level: ProcessingLevel.where(name: 'geotiff_l2').first_or_create,
      queue: 'geotiff',
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: "feeder_geotif.rb -m #{satellite} -t {{workspace}} {{job.input_path}} {{job.output_path}}",
      parent: steps[:geotiff_l1])

    steps[:geotiff_l1].requirements = %w[polar2grid].map do |requirement|
      Requirement.where(name: requirement).first_or_create
    end

    steps[:geotiff_l2].requirements = %w[geotiff].map do |requirement|
      Requirement.where(name: requirement).first_or_create
    end

  end

  steps[:awips] = Step.where(name: "#{satellite.capitalize}AWIPS").first_or_create(
    processing_level: ProcessingLevel.where(name: 'awips').first_or_create,
    queue: 'avhrr',
    sensor: Sensor.where(name: 'avhrr').first_or_create,
    command: 'avhrr_awips.rb -t {{workspace}} -d {{job.facility_name}} {{job.input_path}} {{job.output_path}}',
    enabled: false,
    parent: steps[:hrptin])
  steps[:ldm] = Step.where(name: "#{satellite.capitalize}LDMInject").first_or_create(
    command: 'pqinsert.rb -t . {{job.input_path}}',
    queue: 'ldm',
    producer: false,
    parent: steps[:awips],
    enabled: false)

   steps[:awips_scmi] = Step.where(name: "#{satellite.capitalize}AWIPSSCMI").first_or_create({
      processing_level: ProcessingLevel.where(name: 'scmi').first_or_create,
      queue: 'polar2grid',
      enabled: true,
      sensor: Sensor.where(name: 'avhrr').first_or_create,
      command: "awips_scmi.rb -m avhrr  -t {{workspace}} {{job.input_path}} {{job.output_path}}",
      parent: steps[:l1]
    })
    steps[:awips_scmi_ldm] = Step.where(name: "#{satellite.capitalize}AWIPSCMILDMInject").first_or_create(
      command: 'pqinsert.rb -t . {{job.input_path}}',
      queue: 'ldm',
      producer: false,
      parent: steps[:awips_scmi],
      enabled: true)


  #Clavrx
  steps[:clavrx] = Step.where(name: "#{satellite.capitalize}_CLAVRX_Job").first_or_create({
    enabled: false,
    queue: 'cloud',
    command: 'clavrx_l2.rb -m avhrr -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "avhrr").first_or_create,
    processing_level: ProcessingLevel.where(name: 'clavrx_level2').first_or_create,
    parent: steps[:l1]
    })

  steps[:clavrx_geotiff] = Step.where(name: "#{satellite.capitalize}_CLAVRX_GEOTIFF_Job").first_or_create({
    enabled: true,
    queue: 'polar2grid',
    command: 'p2g_geotif.rb -p 8 -m avhrr_clavrx -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "avhrr").first_or_create,
    processing_level: ProcessingLevel.where(name: 'clavrx_geotiff_l1').first_or_create,
    parent: steps[:clavrx]
    })
  steps[:clavrx_awips] = Step.where(name: "#{satellite.capitalize}_CLAVRX_SCMI_Job").first_or_create({
    enabled: true,
    queue: 'polar2grid',
    command: 'awips_scmi.rb -m clavrx -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "avhrr").first_or_create,
    processing_level: ProcessingLevel.where(name: 'clavrx_scmi').first_or_create,
    parent: steps[:clavrx]
    })

  steps[:clavrx_scmi_ldm] = Step.where(name: "#{satellite.capitalize}_CLAVRX_SCMI_LDM_Job").first_or_create({
    command: 'pqinsert.rb -t . {{job.input_path}}',
    queue: 'ldm',
    producer: false,
    parent: steps[:clavrx_awips],
    enabled: false
   })


  # Set up requirements
  steps[:l1].requirements = %w[aapp].map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:hrptin].requirements = %w[terascan].map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end
  steps[:awips].requirements = %w[terascan polar2grid gdal].map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end
  steps[:ldm].requirements = %w[ldm].map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  # Bind workflows to satellite
  sat = Satellite.friendly.find(satellite)
  sat.workflows << steps[:arrival] unless sat.workflows.include?(steps[:arrival])
end
