require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
	module SparseImage
		module Action
			include Vagrant::Action::Builtin
			def self.action_start
				Vagrant::Action::Builder.new.tap do |b|
					b.use Call do |env, b2|
						b2.use CreateAndMount
					end
				end
			end

			def self.action_halt
				Vagrant::Action::Builder.new.tap do |b|
					b.use Call do |env, b2|
						b2.use Unmount
					end
				end
			end

			def self.action_destroy
				Vagrant::Action::Builder.new.tap do |b|
					b.use Call, DestroyConfirm do |env, b2|
						if env[:result]
							b2.use Destroy
						end
					end
				end
			end

			# "The autoload magic"
			action_root = Pathname.new(File.expand_path('../action', __FILE__))
			autoload :CreateAndMount, action_root.join('create')
			autoload :Unmount, action_root.join('unmount')
			autoload :Destroy, action_root.join('destroy')

		end
	end
end
