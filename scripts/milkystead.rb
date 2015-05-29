class Milkystead
  def Milkystead.configure(config, settings)
    config.landrush.enabled = true
    config.landrush.tld = config.vm.hostname

    # Run some files to configure before configuring milkyway sites
    Dir.foreach(File.join(Dir.pwd, '/configure')) do |script|
      next if script == '.' or script == '..'
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/configure/" + script
      end
    end

    # Install all the configured Milkyway CMS Sites
    if settings.has_key?("cms")
      settings["cms"].each do |site|
        config.vm.provision "shell" do |s|
          s.inline = "bash /vagrant/scripts/serve-cms.sh $1 $2"
          s.args = [site["map"], site["to"]]
        end
      end
    end

    # Install all the Toran Proxy
    if settings.has_key?("toran")
      settings["toran"].each do |site|
        config.vm.provision "shell" do |s|
          s.inline = "bash /vagrant/scripts/serve-toran.sh $1 $2"
          s.args = [site["map"], site["to"]]
        end
      end
    end
  end
end
