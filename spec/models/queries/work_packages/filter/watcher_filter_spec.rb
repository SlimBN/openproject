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

require 'spec_helper'
require_relative 'shared'

describe Queries::WorkPackages::Filter::WatcherFilter, type: :model do
  let(:user) { FactoryGirl.build_stubbed(:user) }

  it_behaves_like 'work package query filter' do
    let(:order) { 15 }
    let(:type) { :list }
    let(:class_key) { :watcher_id }

    let(:principal_loader) do
      loader = double('principal_loader')
      allow(loader)
        .to receive(:user_values)
        .and_return([])

      loader
    end

    before do
      allow(Queries::WorkPackages::Filter::PrincipalLoader)
        .to receive(:new)
        .with(project)
        .and_return(principal_loader)
    end

    describe '#available?' do
      it 'is true if the user is logged in' do
        allow(User)
          .to receive_message_chain(:current, :logged?)
          .and_return true

        expect(instance).to be_available
      end

      it 'is true if the user is allowed to see watchers and if there are users' do
        allow(User)
          .to receive_message_chain(:current, :logged?)
          .and_return false

        allow(User)
          .to receive_message_chain(:current, :allowed_to?)
          .and_return true

        allow(principal_loader)
          .to receive(:user_values)
          .and_return([user])

        expect(instance).to be_available
      end

      it 'is false if the user is allowed to see watchers but there are no users' do
        allow(User)
          .to receive_message_chain(:current, :logged?)
          .and_return false

        allow(User)
          .to receive_message_chain(:current, :allowed_to?)
          .and_return true

        allow(principal_loader)
          .to receive(:user_values)
          .and_return([])

        expect(instance).to_not be_available
      end

      it 'is false if the user is not allowed to see watchers but there are users' do
        allow(User)
          .to receive_message_chain(:current, :logged?)
          .and_return false

        allow(User)
          .to receive_message_chain(:current, :allowed_to?)
          .and_return false

        allow(principal_loader)
          .to receive(:user_values)
          .and_return([user])

        expect(instance).to_not be_available
      end
    end

    describe '#values' do
      context 'contains the me value if the user is logged in' do
        before do
          allow(User)
            .to receive_message_chain(:current, :logged?)
            .and_return true

          expect(instance.values)
            .to match_array [[I18n.t(:label_me), 'me']]
        end
      end

      context 'contains the user values loaded if the user is allowed to see them' do
        before do
          allow(User)
            .to receive_message_chain(:current, :logged?)
            .and_return true

          allow(User)
            .to receive_message_chain(:current, :allowed_to?)
            .and_return true

          allow(principal_loader)
            .to receive(:user_values)
            .and_return([user])

          expect(instance.values)
            .to match_array [[I18n.t(:label_me), 'me'],
                             [user.name, user.id.to_s]]
        end
      end
    end
  end
end
