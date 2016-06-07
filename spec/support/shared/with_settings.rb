#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

def aggregate_mocked_settings(example, settings)
  # We have to manually check parent groups for with_settings:,
  # since they are being ignored otherwise
  example.example_group.parents.each do |parent|
    if parent.respond_to?(:metadata) && parent.metadata[:with_settings]
      settings.reverse_merge!(parent.metadata[:with_settings])
    end
  end

  settings
end

RSpec.configure do |config|
  config.before(:each) do |example|
    settings = example.metadata[:with_settings]
    if settings.present?
      settings = aggregate_mocked_settings(example, settings)

      settings.each do |k, v|
        allow(Setting).to receive(k).and_return(v)
      end
    end
  end
end