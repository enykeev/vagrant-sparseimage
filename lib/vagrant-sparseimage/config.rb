class VagrantPlugins::SparseImage::SingleImageConfig
	# The config for a single image
	# This is not exposed to the vagrant file configuration.
	module Attributes
		attr_accessor :volume_name, :vm_mountpoint, :image_filename, :image_size, :image_fs, :image_type, :nfs_options, :auto_unmount
	end
	class << self
		include Attributes

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
	end

	include Attributes

	def auto_unmount; 	@auto_unmount.nil? 	? self.class.auto_unmount 	: @auto_unmount end
	def image_type; 	@image_type.nil? 	? self.class.image_type 	: @image_type end

	def volume_name
		return self.class.volume_name if !@volume_name | @volume_name == :auto
		@volume_name
	end

	def vm_mountpoint
		return self.class.vm_mountpoint if !@vm_mountpoint | @vm_mountpoint == :auto
		@vm_mountpoint
	end

	def image_filename
		return self.class.image_filename if !@image_filename | @image_filename == :auto
		@image_filename
	end

	def image_size
		return self.class.image_size if !@image_size | @image_size == :auto
		@image_size
	end

	def image_fs
		return self.class.image_fs if !@image_fs | @image_fs == :auto
		@image_fs
	end

	def nfs_options
		return self.class.nfs_options if !@nfs_options | @nfs_options == :auto
		@nfs_options
	end

	def to_hash
		{
			:volume_name 		=> @volume_name,
			:vm_mountpoint		=> @vm_mountpoint,
			:image_filename		=> @image_filename,
			:image_size			=> @image_size,
			:image_fs			=> @image_fs,
			:nfs_options		=> @nfs_options,
			:image_type			=> @image_type,
			:auto_unmount		=> @auto_unmount
		}
	end
end

class VagrantPlugins::SparseImage::Config < Vagrant.plugin("2", :config)
	module Attributes 
		attr_accessor :images
	end

	def initialise
		@images = []
	end

	def validate(env, errors)
		@images.each do |i|
			errors.add("vm_mountpoint cannot be empty.") if i.vm_mountpoint.nil?
			errors.add("image_size cannot be empty.") if i.image_size.nil?
			errors.add("image_filename cannot be empty.") if i.image_filename.nil?
			errors.add("volume_name cannot be empty.") if i.volume_name.nil?
			errors.add("image_type cannot be empty.") if i.image_type.nil?

			if not ['SPARSEBUNDLE', 'SPARSE'].include? i.image_type
				errors.add('invalid value for image_type')
			end
		end
	end

	def finalise!
	end

	# Create a new config for a single image and yield it to the vagrant file
	# This is the only exposed configuration method.
	def add_image(&block)
		image = ImageConfig.new
		yield image

		# Set the defaults if the properties aren't set
        if !image_fs || image_fs.empty? || image_fs == :auto
            image_fs = "JHFS+X"
        en

        if !nfs_options || nfs_options.empty? || nfs_options == :auto
            nfs_options = true
        end

		@images.push image
	end

	def to_hash
		{ :images => @images.map do |i| i.to_hash end }
	end
end
