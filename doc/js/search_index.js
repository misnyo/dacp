var search_data = {"index":{"searchIndex":["dacp","dacpinstance","object","apply_puppet()","copy_file()","init_aws()","init_puppet_drupal()","install_puppet()","new()","parse()","public_dns_name()","run()","run_command()","run_command()","run_enroll_cluster()","run_enroll_db()","run_enroll_vms()","run_enroll_web()","run_init_puppet()","run_list()","run_show_config()","run_start()","run_stop()","start()","stop()","wait_for_start()","wait_for_stop()","config.yaml","config.yaml.sample"],"longSearchIndex":["dacp","dacpinstance","object","dacpinstance#apply_puppet()","dacpinstance#copy_file()","dacp::init_aws()","dacp::init_puppet_drupal()","dacpinstance#install_puppet()","dacpinstance::new()","dacp::parse()","dacpinstance#public_dns_name()","dacp::run()","dacp::run_command()","dacpinstance#run_command()","dacp::run_enroll_cluster()","dacp::run_enroll_db()","dacp::run_enroll_vms()","dacp::run_enroll_web()","dacp::run_init_puppet()","dacp::run_list()","dacp::run_show_config()","dacp::run_start()","dacp::run_stop()","dacpinstance#start()","dacpinstance#stop()","dacpinstance#wait_for_start()","dacpinstance#wait_for_stop()","",""],"info":[["Dacp","","Dacp.html","","<p>Main controller class\n"],["DacpInstance","","DacpInstance.html","","<p>Represents an AWS instance\n"],["Object","","Object.html","",""],["apply_puppet","DacpInstance","DacpInstance.html#method-i-apply_puppet","(file)","<p>Apply local puppet file on server\n"],["copy_file","DacpInstance","DacpInstance.html#method-i-copy_file","(file)","<p>Scp given file to instance home\n"],["init_aws","Dacp","Dacp.html#method-c-init_aws","()","<p>Connection to AWS EC2 client\n"],["init_puppet_drupal","Dacp","Dacp.html#method-c-init_puppet_drupal","()","<p>Initialize puppet drupal parameter template\n"],["install_puppet","DacpInstance","DacpInstance.html#method-i-install_puppet","()","<p>Install puppet\n"],["new","DacpInstance","DacpInstance.html#method-c-new","(ec2, options, name)","<p>Queries instance data from AWS\n"],["parse","Dacp","Dacp.html#method-c-parse","(args)","<p>Parse arguments\n"],["public_dns_name","DacpInstance","DacpInstance.html#method-i-public_dns_name","()",""],["run","Dacp","Dacp.html#method-c-run","()","<p>Runs the command specified in CLI argument\n"],["run_command","Dacp","Dacp.html#method-c-run_command","(command)","<p>Runs function “run_” + command, defaulting to run_list\n"],["run_command","DacpInstance","DacpInstance.html#method-i-run_command","(command)","<p>Run remote command\n"],["run_enroll_cluster","Dacp","Dacp.html#method-c-run_enroll_cluster","()","<p>Enroll whole drupal cluster includes:\n\n<pre class=\"ruby\"><span class=\"ruby-operator\">-</span> <span class=\"ruby-identifier\">run_init_puppet</span>\n<span class=\"ruby-operator\">-</span> <span class=\"ruby-identifier\">run_init_vms</span>\n<span class=\"ruby-operator\">-</span> <span class=\"ruby-identifier\">run_init_db</span>\n<span class=\"ruby-operator\">-</span> <span class=\"ruby-identifier\">run_init_web</span>\n</pre>\n"],["run_enroll_db","Dacp","Dacp.html#method-c-run_enroll_db","()","<p>Enroll database instance(s)\n"],["run_enroll_vms","Dacp","Dacp.html#method-c-run_enroll_vms","()","<p>Create AWS instances for cluster with puppet\n"],["run_enroll_web","Dacp","Dacp.html#method-c-run_enroll_web","()","<p>Enroll web instance(s)\n"],["run_init_puppet","Dacp","Dacp.html#method-c-run_init_puppet","()","<p>Initialize puppet parameter templates\n"],["run_list","Dacp","Dacp.html#method-c-run_list","()","<p>List all instances in configured region\n"],["run_show_config","Dacp","Dacp.html#method-c-run_show_config","()","<p>Show configuration\n"],["run_start","Dacp","Dacp.html#method-c-run_start","()","<p>Start instance specified in options\n"],["run_stop","Dacp","Dacp.html#method-c-run_stop","()","<p>Stop instance specified in options\n"],["start","DacpInstance","DacpInstance.html#method-i-start","()","<p>Start instance\n"],["stop","DacpInstance","DacpInstance.html#method-i-stop","()","<p>Stop instance\n"],["wait_for_start","DacpInstance","DacpInstance.html#method-i-wait_for_start","()","<p>Wait until instance_running\n"],["wait_for_stop","DacpInstance","DacpInstance.html#method-i-wait_for_stop","()","<p>Wait until instance_running\n"],["config.yaml","","dacp/config/config_yaml.html","","<p>AWSCONFIG:\n\n<pre>SECURITY_GROUP: dacp\nAWS_REGION: ap-southeast-1\nIMAGE_ID: ami-8c1607de\nKEY_NAME: cheppers_key ...</pre>\n"],["config.yaml.sample","","dacp/config/config_yaml_sample.html","","<p>AWSCONFIG:\n\n<pre>SECURITY_GROUP: dacp\nAWS_REGION: ap-southeast-1\nIMAGE_ID: ami-8c1607de\nKEY_NAME: dacp\nKEY_LOCATION: ...</pre>\n"]]}}