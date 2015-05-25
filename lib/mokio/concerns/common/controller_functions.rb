module Mokio
  module Concerns #:nodoc:
    module Common #:nodoc:
      #
      # Additional CommonController methods
      #
      module ControllerFunctions
        extend ActiveSupport::Concern

        included do

          after_action :back_to_edit, only: [:create, :update]
          after_action :meta_info, only: [:create, :update]

        end

         private
          #
          # <b>after_action</b>, Info message about autocompleted meta tags
          #
          def meta_info #:doc:
            if flash[:notice].present?
              flash[:notice] += " #{t("meta.auto_completed")}" if obj.respond_to?(:empty_meta) && obj.empty_meta && obj.id
            end
          end

          #
          # <b>after_action</b>, Info message about possible back to edit
          #
          def back_to_edit #:doc:
            if flash[:notice].present?
              flash[:notice] += " #{t("backend.back_to_edit", url: obj_edit_url(obj))}" if obj.id
            end
          end

          def build_enabled(obj)
            obj.build_gmap if obj.class.has_gmap_enabled?
            obj.build_meta if obj.class.has_meta_enabled?
          end

          # @TODO - move here data_files_attributes ?

          #
          # Additional parameters to premit
          #
          def extended_parameters #:doc:
            parameters = {}
            parameters[:gmap_attributes] = Mokio::Gmap.gmap_attributes if @obj_class.has_gmap_enabled?
            parameters[:meta_attributes] = Mokio::Meta.meta_attributes if @obj_class.has_meta_enabled?

            parameters
          end


        def mokio_gems_parameters
          parameters = []
          c_name = self.controller_name.to_sym

          Mokio.mokio_gems_parameters.each do |g,v|
            v.each do |par,val|
              if par == c_name || par == :contents && CONTENT_TYPES.include?("#{controller_path.classify.constantize.name}")
                  parameters += val
              end
            end
          end
          parameters
        end

          #
          # Returns obj index url
          #
          def obj_index_url #:doc:
            send("#{self.controller_name.demodulize}_url") # call your_controller index path 
          end

          #
          # Returns obj edit url
          #
          def obj_edit_url(obj) #:doc:
            Mokio::Content.subclasses.each do |s|
              if "mokio/#{obj_name}" == s.to_s.tableize.singularize
                return send("edit_content_path", obj)
              end
            end
            return "#{Mokio::Engine.routes.url_helpers.root_path}#{obj.class.to_s.tableize.gsub("mokio/", "")}/#{obj.id}/edit"
          end

          #
          # Returns obj new url
          #
          def obj_new_url(obj) #:doc:
            send("new_#{self.controller_name.demodulize.singularize}_path", obj) # call your_controller edit path for obj
          end
      end
    end
  end
end