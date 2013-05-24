begin
	require 'vagrant'
rescue LoadError
	raise 'This plugin must be run from within vagrant.'
end

if Vagrant::VERSION < '1.2.0'
	raise 'The sparseimage plugin is only compatible with vagrant 1.2+'
end


module VagrantPlugins
	module SparseImage
		class Plugin < Vagrant.plugin("2")
			name "vagrant sparse image support"
			description "A vagrant plugin to create a mount sparse images into the guest VM"

			config(:sparseimage) do
				require_relative "config"
				Config
			end
		end
	end
end
