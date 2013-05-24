require 'pathname'
require 'vagrant-sparseimage/plugin'

module VagrantPlugins
	module SparseImage
		lib_path = Pathname.new(File.expand_path('../vagrant-sparseimage', __FILE__))

		autoload :Action, lib_path.join("action")
		def self.source_root
			@source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
		end

	end
end

