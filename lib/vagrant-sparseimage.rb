require 'pp'

begin
	require 'vagrant'
rescue LoadError
	raise 'The Vagrant SparseImage plugin must be run within Vagrant.'
end

module SparseImage
	VERSION = "0.1.2"

	class ImageConfig
		# Configuration for a single sparse image
		# Not exposed to vagrant.

		attr_accessor :volume_name, :vm_mountpoint, :image_filename, :image_size, :image_fs, :image_type, :nfs_options, :auto_unmount

		def auto_unmount; 	@auto_unmount.nil? 	? true 	: @auto_unmount end
		def image_type; 	@image_type.nil? 	? false	: @image_type end

		def volume_name
			return nil if !@volume_name || @volume_name == :auto
			@volume_name
		end

		def vm_mountpoint
			return nil if !@vm_mountpoint || @vm_mountpoint == :auto
			@vm_mountpoint
		end

		def image_filename
			return nil if !@image_filename || @image_filename == :auto
			@image_filename
		end

		def image_size
			return nil if !@image_size || @image_size == :auto
			@image_size
		end

		def image_fs
			return nil if !@image_fs || @image_fs == :auto
			@image_fs
		end

		def nfs_options
			return nil if !@nfs_options || @nfs_options == :auto
			@nfs_options
		end

		def to_hash
			{
				:volume_name     => @volume_name,
				:vm_mountpoint   => @vm_mountpoint,
				:image_filename  => @image_filename,
				:image_size      => @image_size,
				:image_fs        => @image_fs,
				:nfs_options     => @nfs_options,
				:image_type      => @image_type,
				:auto_unmount    => @auto_unmount
			}
		end
	end

	class Mount
		def initialize(app, env)
			@app = app
			@env = env
		end

		def call(env)
			pp env
			@app.call(env)
			return
			Config.images.each do |options|
				if File.exists?("#{options[:image_filename]}.#{options[:image_type]}")
					env[:machine].ui.info "Found sparse disk image: #{options[:image_filename]}.#{options[:image_type]}"
				else
					env[:machine].ui.info "Creating #{options[:image_size]}GB sparse disk image with " +
						"name #{options[:image_filename]}.#{options[:image_type]} ..."
					command = "hdiutil create -type #{options[:image_type]} " +
						   "-size #{options[:image_size]}g " +
						   "-fs #{options[:image_fs]} " +
						   "-volname #{options[:volume_name]} " +
						   "#{opts[:image_file]}"
					system(command)
					env[:machine].ui.info "... done!"
				end

				env[:machine].config.env[:machine].share_folder(opts[:volume_name], opts[:vm_mountpoint],
						"#{env[:root_path]}/#{options[:volume_name]}", :nfs => options[:nfs_options])
			end

			@app.call(env)
		end
	end

	class Unmount
		def initialize(app, env)
			@app = app
			@env = env
		end
		def call(env)
			# TODO - read from the instantiated version not the global
			@app.call(env)
			return

			Config.images.each do |options|
				if options[:auto_unmount]
					env[:machine].ui.info "Unmounting disk image #{options[:image_filename]}.#{options[:image_type]} ..."
					system("hdiutil detach -quiet ./#{options[:volume_name]}")
					env[:machine].ui.info "... done!"
				end
			end
			@app.call(env)
		end
	end

	class Destroy
		def initialize(app, env)
			@app = app
			@env = env
		end
		def call(env)
			# TODO - read from the instantiated version not the global
			@app.call(env)
			return

			Config.images.each do |options|
				env[:machine].ui.info "Unmounting disk image #{options[:image_filename]}.#{options[:image_type]} ..."
				system("hdiutil detach -quiet ./#{options[:volume_name]}")
				env[:machine].ui.info "... done!"
				
				# TODO - Missing the removal of the disk image
				# although the name of the file I'm not so sure about now
				#system("rm -rf #{opts[:image_file]}")
				
			end
			@app.call(env)
		end
	end

	class Config < Vagrant.plugin("2", :config)
		# Singleton
		attr_accessor :images

		def initialise
			puts "Config got initialised."
			super
		end

		def add_image
			if @images.nil?
				@images = []
			end
			if not block_given?
				# TODO - improve this
				raise 'Must take a block.'
			end
			image = ImageConfig.new
			yield image
			@images.push(image)
		end

		def finalise!
		end

		def to_hash
			return { :images => @images }
		end
	end

	class Plugin < Vagrant.plugin("2")
		# The actual vagrant plugin
		# This is here for two reasons:
		#	* to yield a Config object to the Vagrantfile
		#	* to 
		name "vagrant sparse image support"
		description "A vagrant plugin to create a mount sparse images into the guest VM"

		config :sparseimage do
			# Yield a config object to the vagrant file.
			# Vagrant should handle persisting the state of this object.
			Config.new
		end

		action_hook(self::ALL_ACTIONS) do |hook|
			hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, Mount)
			hook.after(Vagrant::Action::Builtin::GracefulHalt, Unmount)
			hook.after(Vagrant::Action::Builtin::DestroyConfirm, Destroy)

			#hook.after(VagrantPlugins::ProviderVirtualBox::Action::ForwardPorts, Mount)
			#hook.after(VagrantPlugins::ProviderVirtualBox::Action::ForcedHalt, Unmount)
			# TODO - confirm that Destroy is not called when confirm is declined
		end
	end
end
