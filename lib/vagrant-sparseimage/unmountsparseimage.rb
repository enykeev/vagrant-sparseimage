module VagrantSparseimage
    class UnmountSparseImage
        def initialize(app, env)
            @app = app
            @env = env
        end

        def call(env)
            @env 	= env
            vm		= env[:vm]
            options	= vm.config.sparseimage.to_hash

            if options[:enabled] && options[:auto_unmount]

                volume_name = options[:volume_name]
                image_filename	= options[:image_filename]
                image_bundle = options[:image_bundle] ? "sparsebundle" : "sparseimage"

                # Set the defaults if the properties aren't set
                if !volume_name || volume_name.empty? || volume_name == :auto
                    volume_name = File.basename(env[:root_path]) + "-image"
                end

                if !image_filename || image_filename.empty? || image_filename == :auto
                    image_filename = ".#{vm.config.vm.name}"
                end

                vm.ui.info "Unmounting disk image #{image_filename}.#{image_bundle} ..."
                system("hdiutil detach -quiet ./#{volume_name}")
                vm.ui.info "... done!"
            end

            @app.call(env)
        end
    end
end

