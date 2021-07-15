# nrt-stack-workflows
workflows for the nrt NWS processing stack

To deploy, log into the dashboard vm and do:
> wget https://github.com/gina-alaska/nrt-stack-workflows-nws/archive/master.zip
> mkdir tmp
> cd tmp
> unzip ../master.zip
> cd nrt-stack-workflows-nws-master
> cp workflows/* $SANDY_DATA/dist/db/workflows/
> cd $SANDY_DATA/dist
> rake db:seed


