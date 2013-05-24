class VagrantPlugins::SparseImage::Action::Destroy
	def initialise(app, env)
		@app = app
		@env = env
	end

	def call(env)
		env[:vm].config.sparseimage.images.each do |options|
			volume_name = options[:volume_name]
			image_filename	= options[:image_filename]
			image_type = options[:image_type]
			vm.ui.info "Unmounting disk image #{image_filename}.#{image_type} ..."
			system("hdiutil detach -quiet ./#{volume_name}")
			vm.ui.info "... done!"
		end
	end
end
