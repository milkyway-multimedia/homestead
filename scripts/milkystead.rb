class Milkystead
  def Milkystead.configure(config, settings)

    config.landrush.enabled = true
    config.landrush.tld = 'dev'

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
