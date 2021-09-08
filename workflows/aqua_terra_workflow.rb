%w{aqua terra}.each do |satellite|
  steps = Hash.new
  steps[:arrival] = Step.where(name: "#{satellite.capitalize}Arrival").first_or_create({
    processing_level: ProcessingLevel.where(name: 'raw').first_or_create
  })

  platform = "#{satellite[0]}1" #Scripts expect a1,t1 for platform, not aqua terra :()
  steps[:rtstps] = Step.where(name: "#{satellite.capitalize}Rtstps").first_or_create({
    command: "rtstps.rb -p #{platform} -t {{workspace}} {{job.input_file}} {{job.output_path}}",
    queue: 'rtstps',
    processing_level: ProcessingLevel.where(name: 'level0').first_or_create,
    parent: steps[:arrival]
  })
  steps[:rtstps].requirements = %w{rt-stps}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:seadas] = Step.where(name: "#{satellite.capitalize}Seadas").first_or_create({
    command: "terra_and_aqua_l1.rb -p #{platform} -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'seadas',
    processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:rtstps]
    })
  steps[:seadas].requirements = %w{seadas}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:modis_geotiff] = Step.where(name: "#{satellite.capitalize}GeoTiff").first_or_create({
    command: "p2g_geotif.rb -p 8 -m modis -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'polar2grid',
    processing_level: ProcessingLevel.where(name: 'geotiff_l1').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:seadas]
    })
  steps[:modis_geotiff].requirements = %w{polar2grid}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:modis_feeder] = Step.where(name: "#{satellite.capitalize}Feeder").first_or_create({
    command: "feeder_geotif.rb -m #{platform} -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'geotiff',
    processing_level: ProcessingLevel.where(name: 'geotiff_level2').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:modis_geotiff],
    enabled: false,
    producer: false
    })
  steps[:modis_feeder].requirements = %w{polar2grid}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  #SST
  steps[:sst] = Step.where(name: "#{satellite.capitalize}ACSPOL2").first_or_create({
    command: "acspo_level2.rb -p #{satellite} -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'cspp_extras',
    processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:seadas]
    })
  steps[:sst].requirements = %w{cspp_extras}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:sst_awips] = Step.where(name: "#{satellite.capitalize}ACSPOAWIPS").first_or_create({
    command: "acspo_awips.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'polar2grid',
    processing_level: ProcessingLevel.where(name: 'acspo_awips').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:sst]
    })
  steps[:sst_awips].requirements = %w{polar2grid}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:sst_geotif] = Step.where(name: "#{satellite.capitalize}ACSPOGEOTIF").first_or_create({
    command: "acspo_geotif.rb -m modis -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'polar2grid',
    processing_level: ProcessingLevel.where(name: 'acspo_awips').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:sst]
    })
  steps[:sst_geotif].requirements = %w{polar2grid}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end


  #firepoints..
  steps[:mod14] = Step.where(name: "#{satellite.capitalize}MOD14").first_or_create({
    command: "modis_mod14.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'cspp_extras',
    processing_level: ProcessingLevel.where(name: 'mod14').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:seadas]
  })
  steps[:mod14].requirements = %w{cspp_extras}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end



  steps[:sport] = Step.where(name: "#{satellite.capitalize}SPORTSLICE").first_or_create({
    command: "sport_slice.rb -m modis -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'polar2grid',
    processing_level: ProcessingLevel.where(name: 'binary_slice').first_or_create,
    sensor: Sensor.where(name: 'modis').first_or_create,
    parent: steps[:seadas]
  })
  steps[:sport].requirements = %w{polar2grid}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end


  #SCMI
  steps[:modis_scmi] = Step.where(name: "#{satellite.capitalize}ModisSCMI").first_or_create({
    command: "awips_scmi.rb -m modis -t {{workspace}} {{job.input_path}} {{job.output_path}}",
    queue: 'polar2grid',
    sensor: Sensor.where(name: 'modis').first_or_create,
    processing_level: ProcessingLevel.where(name: 'scmi').first_or_create,
    parent: steps[:seadas]
                            })
  steps[:modis_scmi].requirements = %w{polar2grid-2}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  steps[:scmi_ldm] = Step.where(name: "#{satellite.capitalize}ModisScmiLDMInsert").first_or_create({
    command: "pqinsert.rb -t {{workspace}} {{job.input_path}}",
    queue: 'ldm',
    parent: steps[:modis_scmi],
    enabled: false,
    producer: false
  })


  # CLOUD
  steps[:clavrx] = Step.where(name: "#{satellite.capitalize}_CLAVRX_Job").first_or_create({
    enabled: true,
    queue: 'cloud',
    command: 'clavrx_l2.rb -m modis -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "modis").first_or_create,
    processing_level: ProcessingLevel.where(name: 'clavrx_level2').first_or_create,
    parent: steps[:seadas]
  })

  steps[:clavrx_geotiff] = Step.where(name: "#{satellite.capitalize}_CLAVRX_GEOTIFF_Job").first_or_create({
    enabled: true,
    queue: 'polar2grid',
    command: 'p2g_geotif.rb -p 8 -m modis_clavrx -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "modis").first_or_create,
    processing_level: ProcessingLevel.where(name: 'clavrx_geotiff_l1').first_or_create,
    parent: steps[:clavrx]
  })
  steps[:clavrx_awips] = Step.where(name: "#{satellite.capitalize}_CLAVRX_SCMI_Job").first_or_create({
    enabled: true,
    queue: 'polar2grid',
    command: 'awips_scmi.rb -m clavrx -t {{workspace}} {{job.input_path}} {{job.output_path}}',
    sensor: Sensor.where(name: "modis").first_or_create,
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
  steps[:scmi_ldm].requirements = %w{ldm}.map do |requirement|
    Requirement.where(name: requirement).first_or_create
  end

  sat = Satellite.friendly.find(satellite)
  sat.workflows << steps[:arrival] unless sat.workflows.include?(steps[:arrival])
end
