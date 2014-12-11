class Milkystead
  def Milkystead.configure(config, settings)

    config.landrush.enabled = true
    config.landrush.tld = 'dev'

     configScriptPath = File.expand_path("/vagrant/configure")

     if File.exists? configScriptPath then
       config.vm.provision "shell", path: configScriptPath
     end

    # Install All The Configured Milkyway Sites
    if settings.has_key?("mwm")
      settings["mwm"].each do |site|
        config.vm.provision "shell" do |s|
          s.inline = "bash /vagrant/scripts/serve-mwm.sh $1 $2"
          s.args = [site["map"], site["to"]]
        end
      end
    end
  end
end
