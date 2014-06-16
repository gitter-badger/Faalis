# -----------------------------------------------------------------------------
#    Faalis - Basic website skel engine
#    Copyright (C) 2012-2014 Yellowen
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# -----------------------------------------------------------------------------

module Faalis
  module Generators
    # Generator Full Faalis scaffold with dashboard
    class ScaffoldGenerator < Rails::Generators::Base
      include Faalis::Generators::Concerns::RequireFields
      include Faalis::Generators::Concerns::Parent
      include Faalis::Generators::Concerns::JsonInput
      include Faalis::Generators::Concerns::ResourceName
      include Faalis::Generators::Concerns::ResourceFields

      desc 'Create full faalis full scaffold'
      class_option :no_model
      class_option :no_route
      class_option :no_controller
      class_option :no_migration

      def create_scaffold
        if options.empty?
        end

        unless options[:no_model]
          create_model
        end
        unless options[:no_route]
          create_route
        end
        unless options[:no_controller]
          #create_controller
        end
        create_list_view
      end

      private

      # Create a dedicated controller, It does not have any relation to Faalis
      # API controller that creates by Faalis:js:js_view generator
      # TODO: fix the `controller` generator name
      def create_controller
        #invoke "controller #{resource_data["name"]}"
      end
      # Create route of the scaffold in config/routes.rb
      def create_route
        route "resources :#{resource_data["name"].pluralize}"
      end

      #Create model of the scaffold with belongs_to support
      #It does not support has_many relation yet
      def create_model
        result = []
        all_fields = []
        relations = "\n"
        fields.each do |name, type, to|

          case type
          when "belongs_to"
            type_ = "integer"
            name_ = "#{to.singularize}_id"
            result << [name_, type_]
            relations << "belongs_to :#{to.singularize}\n"
          when "text", "integer", "string"
            result << [name, type]
          when "in"
            result << [name, "string"]
          end

          all_fields = result.collect do |x|
            x.join(":")
          end

        end
        invoke("active_record:model", [resource_data["name"], *all_fields], {
                 migration: !options[:no_migration], timestamps: true
               })
        if File.exist?("app/models/#{resource_data["name"]}.rb")
          inject_into_file "app/models/#{resource_data["name"]}.rb", after: "Base" do
            relations
          end
        else
          puts "Could not find file app/models/#{resource_data["name"]}"
        end
      end

      #Invoke Faalis list view generator
      def create_list_view
        invoke "faalis:js:list_view", [jsonfile]

      end
    end
  end
end