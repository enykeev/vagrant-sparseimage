class VagrantPlugins::SparseImage::Action::CreateAndMount
	# Hooked to `vagrant start`
	# Create the sparse image / bundle if it does not exist.
	# Mount the image in the host environment, using hdutil.
	def initialise(app, env)
		@app = app
		@env = env
	end

	def call(env)
		env[:vm]config.sparseimage.to_hash[:images].each do |options|
			volume_name 	= options[:volume_name]
			vm_mountpoint	= options[:vm_mountpoint]
			image_filename	= options[:image_filename]
			image_size		= options[:image_size]
			image_fs		= options[:image_fs]
			nfs_options		= options[:nfs_options]
			type			= options[:image_type]

			if File.exists?("#{image_filename}.#{image_type}")
				vm.ui.info "Found sparse disk image: #{image_filename}.#{image_type}"
			else
				vm.ui.info "Creating #{image_size}GB sparse disk image with " +
					"name #{image_filename}.#{image_type} ..."

				system("hdiutil create -type #{type} " +
					   "-size #{image_size}g " +
					   "-fs #{image_fs} " +
					   "-volname #{volume_name} " +
					   "#{image_filename}"
					  );
					  vm.ui.info "... done!"
			end
		end	
		@app.call(env)
	end
end
