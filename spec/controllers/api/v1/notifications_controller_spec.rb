require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  let(:user) { create(:basic_user, :with_notifications) }
  let(:write_token) { create(:write_access_token, resource_owner_id: user.id) }

  describe 'POST#create' do
    let!(:token) { create(:admin_access_token, resource_owner_id: user.id).token }
    it 'should create notification' do
      expect { post :create, access_token: token, notification: attributes_for(:notification) }.to \
        change(Notification, :count).by(1)
    end

    it 'should change user unread notification count' do
      post :create, access_token: token, notification: attributes_for(:notification)
      expect(JSON.parse(response.body)['count']).to eq 6
    end
  end

  describe 'read' do
    it 'changes notification unread status' do
      notification = user.notifications.first
      post :read, access_token: write_token.token, id: notification.id
      expect(notification.reload.unread).to eq false
      expect(user.reload.unread_notifications_count).to eq 4
    end
  end

  describe 'read_all' do
    it 'set all notifications to read' do
      post :read_all, access_token: write_token.token
      expect(user.reload.unread_notifications_count).to eq 0
    end
  end
end
