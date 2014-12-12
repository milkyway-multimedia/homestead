class Milkystead
  def Milkystead.configure(config, settings)

    config.landrush.enabled = true
    config.landrush.tld = 'dev'

    # Run some files to configure before configuring milkyway sites
    Dir.foreach(File.join(Dir.pwd, '/configure')) do |script|
      next if script == '.' or script == '..'
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/configure/" + script
      end
    end

    # Install all the configured Milkyway Sites
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
