require 'json'
require 'yaml'

VAGRANTFILE_API_VERSION = "2"
confDir = $confDir ||= File.expand_path("~/.homestead")

homesteadYamlPath = confDir + "/Homestead.yaml"
homesteadJsonPath = confDir + "/Homestead.json"
afterScriptPath = confDir + "/after.sh"
aliasesPath = confDir + "/aliases"

require_relative 'scripts/homestead.rb'
require_relative 'scripts/milkystead.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if File.exists? aliasesPath then
    config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
  end
    
  if File.exists? homesteadYamlPath then
    Homestead.configure(config, YAML::load(File.read(homesteadYamlPath)))
    Milkystead.configure(config, YAML::load(File.read(homesteadYamlPath)))
  elsif File.exists? homesteadJsonPath then
    Homestead.configure(config, JSON.parse(File.read(homesteadJsonPath)))
    Milkystead.configure(config, JSON.parse(File.read(homesteadYamlPath)))
  end

  if File.exists? afterScriptPath then
    config.vm.provision "shell", path: afterScriptPath
  end
end
